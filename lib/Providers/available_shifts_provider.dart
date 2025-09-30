import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/Models/available_shifts_model.dart'; // Ensure this import path is correct
import 'package:peach_iq/constants/api_utils.dart'; // Ensure this import path is correct

class AvailableShiftsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<AvailableShift> _allSchedules = []; // Master list for all shifts
  Timer? _refreshTimer;
  bool _autoRefreshEnabled = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Getter for the **full list** of shifts (for the 'AvailableShifts' page).
  List<AvailableShift> get allSchedules => _allSchedules;

  /// Getter for **only the shifts needing a response** (for the 'HomeScreen').
  List<AvailableShift> get actionableSchedules =>
      _allSchedules.where((s) => s.caregiverDecision == 0).toList();

  bool get hasActionableSchedules => actionableSchedules.isNotEmpty;

  void clear() {
    _allSchedules = [];
    _errorMessage = null;
    _isLoading = false;
    stopAutoRefresh();
    notifyListeners();
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 30)}) {
    if (_autoRefreshEnabled) return;
    _autoRefreshEnabled = true;
    _refreshTimer?.cancel();
    debugPrint('Starting auto-refresh with ${interval.inSeconds}s interval');
    _refreshTimer = Timer.periodic(interval, (timer) {
      if (_autoRefreshEnabled && !_isLoading) {
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
            availableShiftsResponseFromJson(response.body);
        // Store the complete, unfiltered list from the API.
        _allSchedules = availableShiftsResponse.data;
        debugPrint('Successfully parsed ${_allSchedules.length} total shifts.');
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

  /// Updates a shift's state in the master list for instant UI feedback.
  void updateShiftDecision(int notifyId, int newDecision) {
    int index = _allSchedules.indexWhere((s) => s.notifyId == notifyId);
    if (index != -1) {
      _allSchedules[index].caregiverDecision = newDecision;
      debugPrint(
          'Updated shift $notifyId decision to $newDecision in master list.');
      notifyListeners();
    }
  }

  Future<void> retry() async {
    _errorMessage = null;
    await fetchAvailableShifts();
  }
}
