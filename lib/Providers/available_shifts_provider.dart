import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/Models/available_shifts_model.dart'
    as models; // Ensure this import path is correct
import 'package:peach_iq/constants/api_utils.dart'; // Ensure this import path is correct
import 'dart:convert';

class AvailableShiftsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<models.AvailableShift> _allSchedules = []; // Master list for all shifts
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = false;
  Map<int, int> _pendingUpdates = {}; // Track pending user updates
  Map<int, DateTime> _pendingUpdateTimestamps =
      {}; // Track when updates were made
  Map<int, String> _updateStatus =
      {}; // Track update status: 'sending', 'confirmed', 'failed'
  int _lastKnownActionableCount = 0; // Track expected actionable count
  bool _autoRefreshPaused = false; // Pause auto-refresh during updates

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Getter for the **full list** of shifts (for the 'AvailableShifts' page).
  List<models.AvailableShift> get allSchedules => _allSchedules;

  /// Getter for **only the shifts needing a response** (for the 'HomeScreen').
  List<models.AvailableShift> get actionableSchedules {
    final actionable =
        _allSchedules.where((s) => s.caregiverDecision == 0).toList();

    // Validate state consistency
    if (_validateStateConsistency(actionable)) {
      _lastKnownActionableCount = actionable.length;
      return actionable;
    }

    // If state is inconsistent, return cached count or trigger refresh
    debugPrint(
        '⚠️ State inconsistency detected. Actionable: ${actionable.length}, Expected: $_lastKnownActionableCount');
    return actionable; // Still return current state but log the issue
  }

  bool get hasActionableSchedules => actionableSchedules.isNotEmpty;

  void clear() {
    _allSchedules = [];
    _errorMessage = null;
    _isLoading = false;
    _pendingUpdates.clear();
    _pendingUpdateTimestamps.clear();
    _updateStatus.clear();
    _lastKnownActionableCount = 0;
    _autoRefreshPaused = false;
    stopAutoRefresh();
    notifyListeners();
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_autoRefreshEnabled) return;
    _autoRefreshEnabled = true;
    _refreshTimer?.cancel();
    debugPrint('Starting auto-refresh with ${interval.inSeconds}s interval');
    _refreshTimer = Timer.periodic(interval, (timer) {
      if (_autoRefreshEnabled && !_isLoading && !_autoRefreshPaused) {
        debugPrint('Auto-refreshing available shifts...');
        fetchAvailableShifts(isAutoRefresh: true);
      }
    });
    notifyListeners();
  }

  void stopAutoRefresh() {
    if (!_autoRefreshEnabled) return;
    _autoRefreshEnabled = false;
    _refreshTimer?.cancel();
    _refreshTimer = null;
    debugPrint('Stopped auto-refresh');
    notifyListeners();
  }

  void toggleAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_autoRefreshEnabled) {
      stopAutoRefresh();
    } else {
      startAutoRefresh(interval: interval);
    }
  }

  @override
  void dispose() {
    stopAutoRefresh();
    _pendingUpdates.clear();
    _pendingUpdateTimestamps.clear();
    _updateStatus.clear();
    super.dispose();
  }

  Future<void> fetchAvailableShifts({bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login.');
      }

      final uri = Uri.parse(ApiUrls.availableShifts());
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final availableShiftsResponse =
            models.availableShiftsResponseFromJson(response.body);

        // Smart merge: preserve local changes for pending updates
        final apiData = availableShiftsResponse.data;
        final previousActionableCount = actionableSchedules.length;

        // Clean up expired pending updates before merge
        _cleanupExpiredPendingUpdates();

        final mergedData = _mergeWithPendingUpdates(apiData);

        // Validate the merge result
        if (_validateMergeResult(
            mergedData, apiData, previousActionableCount, isAutoRefresh)) {
          _allSchedules = mergedData;
          debugPrint(
              '✅ Successfully merged ${_allSchedules.length} total shifts. Actionable: ${actionableSchedules.length}');
        } else {
          // If validation fails during auto-refresh, keep current state
          if (isAutoRefresh) {
            debugPrint(
                '⚠️ Auto-refresh validation failed, keeping current state');
            return; // Don't update state, keep current
          } else {
            // For manual refresh, still update but log warning
            _allSchedules = mergedData;
            debugPrint(
                '⚠️ Manual refresh with validation warning. Updated anyway.');
          }
        }
      } else {
        throw Exception(
            'Failed to load shifts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching available shifts: ${e.toString()}');
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      if (!isAutoRefresh) _isLoading = false;
      notifyListeners();
    }
  }

  /// **NEW: Integrated response method that handles the complete flow**
  Future<bool> respondToShift(int notifyId, int status) async {
    final statusText = status == 1
        ? 'INTERESTED'
        : status == -1
            ? 'NOT_INTERESTED'
            : 'UNKNOWN';
    debugPrint(
        '🚀 [SHIFT_RESPONSE_START] NotifyId: $notifyId | Status: $status ($statusText) | Timestamp: ${DateTime.now().toIso8601String()}');

    try {
      // 1. Pause auto-refresh to prevent conflicts
      _pauseAutoRefresh();
      debugPrint(
          '⏸️ [SHIFT_RESPONSE] Auto-refresh paused for NotifyId: $notifyId');

      // 2. Optimistic update - show immediate UI feedback
      _performOptimisticUpdate(notifyId, status);
      debugPrint(
          '🔄 [SHIFT_RESPONSE] Optimistic update applied for NotifyId: $notifyId → $statusText');

      // 3. Send API request
      debugPrint(
          '📡 [SHIFT_RESPONSE] Initiating API call for NotifyId: $notifyId');
      final success = await _sendShiftResponse(notifyId, status);

      // 4. Handle result
      if (success) {
        _confirmUpdate(notifyId, status);
        debugPrint(
            '✅ [SHIFT_RESPONSE_SUCCESS] NotifyId: $notifyId | Status: $statusText | API confirmed successfully');
      } else {
        _rollbackUpdate(notifyId);
        debugPrint(
            '❌ [SHIFT_RESPONSE_FAILED] NotifyId: $notifyId | Status: $statusText | API call failed, state rolled back');
      }

      // 5. Resume auto-refresh after a short delay
      Timer(const Duration(seconds: 3), () {
        _resumeAutoRefresh();
        debugPrint(
            '▶️ [SHIFT_RESPONSE] Auto-refresh resumed after NotifyId: $notifyId response');
      });

      debugPrint(
          '🏁 [SHIFT_RESPONSE_END] NotifyId: $notifyId | Final Result: ${success ? 'SUCCESS' : 'FAILED'}');
      return success;
    } catch (e) {
      debugPrint(
          '💥 [SHIFT_RESPONSE_ERROR] NotifyId: $notifyId | Exception: ${e.toString()} | Timestamp: ${DateTime.now().toIso8601String()}');
      _rollbackUpdate(notifyId);
      _resumeAutoRefresh();
      return false;
    }
  }

  /// Updates a shift's state in the master list for instant UI feedback.
  void updateShiftDecision(int notifyId, int newDecision) {
    final previousActionableCount = actionableSchedules.length;

    // Track this as a pending update with timestamp
    _pendingUpdates[notifyId] = newDecision;
    _pendingUpdateTimestamps[notifyId] = DateTime.now();

    // Apply local update immediately for instant UI feedback
    int index = _allSchedules.indexWhere((s) => s.notifyId == notifyId);
    if (index != -1) {
      final oldDecision = _allSchedules[index].caregiverDecision;
      _allSchedules[index].caregiverDecision = newDecision;

      // Update expected count based on the change
      if (oldDecision == 0 && newDecision != 0) {
        // Shift was actionable, now it's not
        _lastKnownActionableCount = previousActionableCount - 1;
      } else if (oldDecision != 0 && newDecision == 0) {
        // Shift wasn't actionable, now it is
        _lastKnownActionableCount = previousActionableCount + 1;
      }

      debugPrint(
          '✅ Updated shift $notifyId: $oldDecision → $newDecision. Expected actionable: $_lastKnownActionableCount');
      notifyListeners();
    }

    // Clear pending update after 15 seconds (increased from 10 for better reliability)
    Timer(const Duration(seconds: 15), () {
      _pendingUpdates.remove(notifyId);
      _pendingUpdateTimestamps.remove(notifyId);
      debugPrint('🧹 Cleared pending update for shift $notifyId.');
    });
  }

  /// Merges API data with local pending updates
  List<models.AvailableShift> _mergeWithPendingUpdates(
      List<models.AvailableShift> apiData) {
    if (_pendingUpdates.isEmpty) {
      return apiData; // No pending updates, use API data as-is
    }

    // Create a map for faster lookup
    final apiShiftMap = {for (var shift in apiData) shift.notifyId: shift};
    final result = <models.AvailableShift>[];

    // First, add all API shifts with pending updates applied
    for (final apiShift in apiData) {
      if (_pendingUpdates.containsKey(apiShift.notifyId)) {
        final localDecision = _pendingUpdates[apiShift.notifyId]!;

        // Create new shift with local decision but fresh API data for other fields
        result.add(models.AvailableShift(
          id: apiShift.id,
          notifyId: apiShift.notifyId,
          caregiverDecision: localDecision, // Use local state
          displayInstitutionName: apiShift.displayInstitutionName,
          startDate: apiShift.startDate,
          endDate: apiShift.endDate,
          schedulingType: apiShift.schedulingType,
          displayTimeshift: apiShift.displayTimeshift,
          displayWorkshift: apiShift.displayWorkshift,
          category: apiShift.category,
          unitarea: apiShift.unitarea,
        ));
      } else {
        // No pending update, use API data as-is
        result.add(apiShift);
      }
    }

    // Check for orphaned pending updates (shifts that exist locally but not in API)
    final orphanedUpdates = _pendingUpdates.keys
        .where((notifyId) => !apiShiftMap.containsKey(notifyId))
        .toList();

    if (orphanedUpdates.isNotEmpty) {
      debugPrint(
          '⚠️ Found ${orphanedUpdates.length} orphaned pending updates: $orphanedUpdates');

      // Add shifts from current state that have pending updates but aren't in API
      for (final notifyId in orphanedUpdates) {
        final existingShift = _allSchedules.firstWhere(
          (s) => s.notifyId == notifyId,
          orElse: () => models.AvailableShift(
            id: 0,
            notifyId: notifyId,
            caregiverDecision: _pendingUpdates[notifyId]!,
            displayInstitutionName: 'Unknown',
            startDate: DateTime.now(),
            endDate: null,
            schedulingType: 'Once',
            displayTimeshift: 'N/A',
            displayWorkshift: 'N/A',
            category: models.Category(
                id: 0, jobCategory: 'N/A', colorCode: '#000000'),
            unitarea: null,
          ),
        );

        // Only add if it's a real shift (not the fallback)
        if (existingShift.id != 0) {
          result.add(existingShift);
        }
      }
    }

    return result;
  }

  /// Validates that the state is consistent and not corrupted
  bool _validateStateConsistency(List<models.AvailableShift> actionableShifts) {
    // If we have no previous count to compare against, assume valid
    if (_lastKnownActionableCount == 0) return true;

    // If we have pending updates, expect some variance
    if (_pendingUpdates.isNotEmpty) {
      // Allow for reasonable variance when updates are pending
      final variance =
          (actionableShifts.length - _lastKnownActionableCount).abs();
      return variance <= _pendingUpdates.length + 15; // Allow larger buffer for dynamic data
    }

    // Without pending updates, count should be stable or decrease gradually
    final variance =
        (_lastKnownActionableCount - actionableShifts.length).abs();
    return variance <= 15; // Allow larger natural variance for dynamic shift data
  }

  /// Validates the result of merging API data with local updates
  bool _validateMergeResult(
    List<models.AvailableShift> mergedData,
    List<models.AvailableShift> apiData,
    int previousActionableCount,
    bool isAutoRefresh,
  ) {
    final newActionableCount =
        mergedData.where((s) => s.caregiverDecision == 0).length;
    final apiActionableCount =
        apiData.where((s) => s.caregiverDecision == 0).length;

    // Basic sanity checks
    if (mergedData.isEmpty && apiData.isNotEmpty) {
      debugPrint(
          '❌ Merge validation failed: Empty result from non-empty API data');
      return false;
    }

    // Check for dramatic unexpected changes during auto-refresh
    if (isAutoRefresh && _pendingUpdates.isEmpty) {
      final countDifference =
          (newActionableCount - previousActionableCount).abs();
      if (countDifference > 5) {
        // More than 5 shifts changed unexpectedly
        debugPrint(
            '❌ Auto-refresh validation failed: Unexpected count change $previousActionableCount → $newActionableCount');
        return false;
      }
    }

    // Check for duplicate notifyIds
    final notifyIds = mergedData.map((s) => s.notifyId).toList();
    final uniqueNotifyIds = notifyIds.toSet();
    if (notifyIds.length != uniqueNotifyIds.length) {
      debugPrint('❌ Merge validation failed: Duplicate notifyIds detected');
      return false;
    }

    debugPrint(
        '✅ Merge validation passed: API($apiActionableCount) → Merged($newActionableCount), Previous($previousActionableCount)');
    return true;
  }

  /// Cleans up pending updates that are older than 30 seconds
  void _cleanupExpiredPendingUpdates() {
    final now = DateTime.now();
    final expiredKeys = <int>[];

    for (final entry in _pendingUpdateTimestamps.entries) {
      if (now.difference(entry.value).inSeconds > 30) {
        expiredKeys.add(entry.key);
      }
    }

    for (final key in expiredKeys) {
      _pendingUpdates.remove(key);
      _pendingUpdateTimestamps.remove(key);
      debugPrint('🧹 Cleaned up expired pending update for shift $key');
    }
  }

  Future<void> retry() async {
    _errorMessage = null;
    await fetchAvailableShifts();
  }

  /// Forces a fresh fetch, clearing all pending updates and cached state
  Future<void> forceRefresh() async {
    debugPrint('🔄 Force refresh triggered - clearing all cached state');
    _pendingUpdates.clear();
    _pendingUpdateTimestamps.clear();
    _lastKnownActionableCount = 0;
    await fetchAvailableShifts();
  }

  /// Gets debug information about current state
  Map<String, dynamic> getDebugInfo() {
    return {
      'totalShifts': _allSchedules.length,
      'actionableShifts': actionableSchedules.length,
      'lastKnownActionableCount': _lastKnownActionableCount,
      'pendingUpdates': _pendingUpdates.length,
      'pendingUpdateIds': _pendingUpdates.keys.toList(),
      'pendingUpdateDetails': _pendingUpdates,
      'updateStatus': _updateStatus,
      'autoRefreshEnabled': _autoRefreshEnabled,
      'autoRefreshPaused': _autoRefreshPaused,
      'isLoading': _isLoading,
      'hasError': _errorMessage != null,
      'errorMessage': _errorMessage,
    };
  }

  /// Logs current state for debugging
  void logCurrentState([String context = '']) {
    final debug = getDebugInfo();
    debugPrint(
        '📊 AvailableShiftsProvider State ${context.isNotEmpty ? '($context)' : ''}:');
    debugPrint(
        '   Total: ${debug['totalShifts']}, Actionable: ${debug['actionableShifts']}, Expected: ${debug['lastKnownActionableCount']}');
    debugPrint(
        '   Pending: ${debug['pendingUpdates']} updates ${debug['pendingUpdateIds']}');
    debugPrint(
        '   Auto-refresh: ${debug['autoRefreshEnabled']}, Paused: $_autoRefreshPaused, Loading: ${debug['isLoading']}, Error: ${debug['hasError']}');
  }

  // ============================================================================
  // PRIVATE HELPER METHODS FOR INTEGRATED RESPONSE HANDLING
  // ============================================================================

  /// Pauses auto-refresh to prevent conflicts during updates
  void _pauseAutoRefresh() {
    if (!_autoRefreshPaused) {
      _autoRefreshPaused = true;
      debugPrint('⏸️ Auto-refresh paused for update');
    }
  }

  /// Resumes auto-refresh after updates are complete
  void _resumeAutoRefresh() {
    if (_autoRefreshPaused) {
      _autoRefreshPaused = false;
      debugPrint('▶️ Auto-refresh resumed');
    }
  }

  /// Performs optimistic update for immediate UI feedback
  void _performOptimisticUpdate(int notifyId, int newDecision) {
    final statusText = newDecision == 1
        ? 'INTERESTED'
        : newDecision == -1
            ? 'NOT_INTERESTED'
            : 'ACTIONABLE';

    _updateStatus[notifyId] = 'sending';
    _pendingUpdates[notifyId] = newDecision;
    _pendingUpdateTimestamps[notifyId] = DateTime.now();

    debugPrint(
        '🔄 [OPTIMISTIC_UPDATE] NotifyId: $notifyId | Setting status to: sending');

    // Apply to local state immediately
    final index = _allSchedules.indexWhere((s) => s.notifyId == notifyId);
    if (index != -1) {
      final oldDecision = _allSchedules[index].caregiverDecision;
      final oldStatusText = oldDecision == 1
          ? 'INTERESTED'
          : oldDecision == -1
              ? 'NOT_INTERESTED'
              : 'ACTIONABLE';

      _allSchedules[index].caregiverDecision = newDecision;

      // Update expected count
      if (oldDecision == 0 && newDecision != 0) {
        _lastKnownActionableCount = actionableSchedules.length;
        debugPrint(
            '📊 [OPTIMISTIC_UPDATE] NotifyId: $notifyId | Actionable count decreased to: $_lastKnownActionableCount');
      } else if (oldDecision != 0 && newDecision == 0) {
        _lastKnownActionableCount = actionableSchedules.length;
        debugPrint(
            '📊 [OPTIMISTIC_UPDATE] NotifyId: $notifyId | Actionable count increased to: $_lastKnownActionableCount');
      }

      debugPrint(
          '🔄 [OPTIMISTIC_UPDATE] NotifyId: $notifyId | Decision changed: $oldStatusText ($oldDecision) → $statusText ($newDecision)');
      debugPrint(
          '🎯 [OPTIMISTIC_UPDATE] NotifyId: $notifyId | UI will show immediate feedback while API processes');
      notifyListeners();
    } else {
      debugPrint(
          '⚠️ [OPTIMISTIC_UPDATE] NotifyId: $notifyId | Shift not found in local schedules list');
    }
  }

  /// Sends the actual API request to update shift status
  Future<bool> _sendShiftResponse(int notifyId, int status) async {
    final statusText = status == 1
        ? 'INTERESTED'
        : status == -1
            ? 'NOT_INTERESTED'
            : 'UNKNOWN';

    try {
      debugPrint(
          '🔐 [API_AUTH] Getting authentication token for NotifyId: $notifyId');
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        debugPrint(
            '❌ [API_AUTH_ERROR] No authentication token found for NotifyId: $notifyId');
        throw Exception('No authentication token found');
      }
      debugPrint(
          '✅ [API_AUTH] Token retrieved successfully for NotifyId: $notifyId (length: ${token.length})');

      final uri = Uri.parse(ApiUrls.respondToShift());
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token'
      };

      final body = json.encode({
        'notify_id': notifyId,
        'status': status,
      });

      debugPrint('📡 [API_REQUEST] Starting HTTP POST for NotifyId: $notifyId');
      debugPrint('🌐 [API_REQUEST] URL: ${uri.toString()}');
      debugPrint(
          '📋 [API_REQUEST] Headers: Content-Type: application/json, Authorization: Bearer [TOKEN_HIDDEN]');
      debugPrint('📦 [API_REQUEST] Body: $body');
      debugPrint('⏱️ [API_REQUEST] Timeout: 15 seconds | Status: $statusText');
      debugPrint(
          '🎯 [API_REQUEST] Expected API behavior: POST with notify_id=$notifyId, status=$status ($statusText)');

      final stopwatch = Stopwatch()..start();
      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 15));
      stopwatch.stop();

      debugPrint(
          '📨 [API_RESPONSE] Received response for NotifyId: $notifyId in ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('📊 [API_RESPONSE] Status Code: ${response.statusCode}');
      debugPrint('📄 [API_RESPONSE] Body: ${response.body}');

      if (response.statusCode == 200) {
        // Validate response body
        try {
          final responseData = json.decode(response.body);
          debugPrint('🔍 [API_RESPONSE] Parsed JSON: $responseData');

          if (responseData['status'] == 200 ||
              responseData['success'] == true) {
            debugPrint(
                '✅ [API_SUCCESS] NotifyId: $notifyId | Status: $statusText | Server confirmed response successfully');
            debugPrint(
                '🎯 [API_SUCCESS] Response validation passed for NotifyId: $notifyId');
            return true;
          } else {
            final errorMsg = responseData['message'] ?? 'Unknown server error';
            debugPrint(
                '❌ [API_ERROR] NotifyId: $notifyId | Server returned error: $errorMsg');
            debugPrint('📋 [API_ERROR] Full response data: $responseData');
            return false;
          }
        } catch (jsonError) {
          debugPrint(
              '💥 [API_JSON_ERROR] NotifyId: $notifyId | Failed to parse response JSON: $jsonError');
          debugPrint('📄 [API_JSON_ERROR] Raw response body: ${response.body}');
          return false;
        }
      } else {
        debugPrint(
            '❌ [API_HTTP_ERROR] NotifyId: $notifyId | HTTP Status: ${response.statusCode}');
        debugPrint('📄 [API_HTTP_ERROR] Response body: ${response.body}');
        debugPrint(
            '⚠️ [API_HTTP_ERROR] Expected status 200, got ${response.statusCode} for NotifyId: $notifyId');
        return false;
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        debugPrint(
            '⏰ [API_TIMEOUT] NotifyId: $notifyId | Request timed out after 15 seconds');
      } else {
        debugPrint(
            '💥 [API_EXCEPTION] NotifyId: $notifyId | Exception type: ${e.runtimeType}');
        debugPrint(
            '💥 [API_EXCEPTION] NotifyId: $notifyId | Exception details: ${e.toString()}');
      }
      return false;
    }
  }

  /// Confirms the update was successful
  void _confirmUpdate(int notifyId, int status) {
    _updateStatus[notifyId] = 'confirmed';
    // Keep the pending update for a bit longer to prevent auto-refresh conflicts
    Timer(const Duration(seconds: 5), () {
      _pendingUpdates.remove(notifyId);
      _pendingUpdateTimestamps.remove(notifyId);
      _updateStatus.remove(notifyId);
      debugPrint('🧹 Cleaned up confirmed update for shift $notifyId');
    });
  }

  /// Rolls back optimistic update if API call failed
  void _rollbackUpdate(int notifyId) {
    _updateStatus[notifyId] = 'failed';

    // Find the shift and revert to original state
    final index = _allSchedules.indexWhere((s) => s.notifyId == notifyId);
    if (index != -1) {
      // Revert to decision = 0 (actionable) as that's the most likely original state
      _allSchedules[index].caregiverDecision = 0;
      debugPrint('🔄 Rolled back failed update for shift $notifyId');
      notifyListeners();
    }

    // Clean up after rollback
    Timer(const Duration(seconds: 2), () {
      _pendingUpdates.remove(notifyId);
      _pendingUpdateTimestamps.remove(notifyId);
      _updateStatus.remove(notifyId);
    });
  }

  /// Gets the current status of an update
  String? getUpdateStatus(int notifyId) {
    return _updateStatus[notifyId];
  }

  /// Checks if a shift is currently being updated
  bool isShiftUpdating(int notifyId) {
    return _updateStatus[notifyId] == 'sending';
  }

  /// **FOR TESTING: Simulates a shift response without API call**
  void simulateShiftResponse(int notifyId, int status,
      {bool shouldFail = false}) {
    debugPrint(
        '🧪 TESTING: Simulating shift response $notifyId → $status (fail: $shouldFail)');

    if (shouldFail) {
      // Simulate failed response
      _performOptimisticUpdate(notifyId, status);
      Timer(const Duration(seconds: 1), () => _rollbackUpdate(notifyId));
    } else {
      // Simulate successful response
      _performOptimisticUpdate(notifyId, status);
      Timer(const Duration(seconds: 1), () => _confirmUpdate(notifyId, status));
    }
  }
}
