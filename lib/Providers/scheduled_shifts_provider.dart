import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/scheduled_shifts_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/constants/api_utils.dart';

class SchedulesShiftsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<ScheduledShift> _schedules = [];
  Timer? _refreshTimer;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<ScheduledShift> get schedules => _schedules;

  List<ScheduledShift> get upcomingSchedules {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final filtered =
        _schedules.where((shift) => !shift.start.isBefore(today)).toList();
    filtered.sort((a, b) => a.start.compareTo(b.start));
    return filtered;
  }

  List<ScheduledShift> get allSchedulesForMonth {
    final sortedList = List<ScheduledShift>.from(_schedules);
    sortedList.sort((a, b) => a.start.compareTo(b.start));
    return sortedList;
  }

  void startAutoRefresh({Duration interval = const Duration(seconds: 60)}) {
    stopAutoRefresh();
    _refreshTimer = Timer.periodic(interval, (timer) {
      fetchScheduledShifts(isAutoRefresh: true);
    });
  }

  void stopAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> fetchScheduledShifts(
      {DateTime? forDate, bool isAutoRefresh = false}) async {
    if (!isAutoRefresh) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }
      final dateToFetch = forDate ?? DateTime.now();
      final uri = Uri.parse(ApiUrls.scheduledShift(
        month: dateToFetch.month,
        year: dateToFetch.year,
      ));
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token'
      };
      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final welcomeResponse = schedulesShiftsWelcomeFromJson(response.body);
        _schedules = welcomeResponse.data;
      } else {
        throw Exception(
            'API Error (${response.statusCode}): Failed to load scheduled shifts.');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (!isAutoRefresh) {
        _isLoading = false;
      }
      notifyListeners();
    }
  }

  // --- ADD THIS NEW METHOD ---
  /// Finds a shift by its ID and updates its status and times.
  void updateShiftStatus(int schedulingId, int newStatus,
      {DateTime? checkInTime, DateTime? checkOutTime}) {
    try {
      final shiftIndex =
          _schedules.indexWhere((s) => s.scheduleId == schedulingId);

      if (shiftIndex != -1) {
        final shift = _schedules[shiftIndex];
        shift.checkInStatus = newStatus;
        if (checkInTime != null) {
          shift.actualCheckIn = checkInTime;
        }
        if (checkOutTime != null) {
          shift.actualCheckOut = checkOutTime;
        }
        debugPrint(
            "✅ Shift $schedulingId status updated in provider to $newStatus.");
        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Error updating shift status in provider: $e");
    }
  }

  void clear() {
    _schedules = [];
    _errorMessage = null;
    _isLoading = false;
    stopAutoRefresh();
    notifyListeners();
  }

  Future<void> retry() async {
    await fetchScheduledShifts();
  }
}
