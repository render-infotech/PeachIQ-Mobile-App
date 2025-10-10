import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/Models/work_analysis_model.dart';
import 'package:peach_iq/constants/api_utils.dart';
import 'package:intl/intl.dart';

class WorkAnalysisProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  WorkAnalysisWelcome? _analysisData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WorkAnalysisWelcome? get analysisData => _analysisData;

  int get totalShifts => _analysisData?.data.cards.mtdSchedules.total ?? 0;

  double get totalEarnings {
    final earnings =
        _analysisData?.data.cards.mtdEstimatedEarnings.total ?? 0.0;
    // Truncate the value to 2 decimal places without rounding.
    // e.g., 2442.8898 -> 2442.88
    return (earnings * 100).truncateToDouble() / 100;
  }

  double get totalHours {
    if (_analysisData == null || _analysisData!.data.schedules.isEmpty) {
      return 0.0;
    }
    double total = 0.0;
    final now = DateTime.now();

    final monthToDateSchedules =
        _analysisData!.data.schedules.where((schedule) {
      return !schedule.scheduleStart.isAfter(now);
    }).toList();

    for (var schedule in monthToDateSchedules) {
      total += _calculateHoursFromTimeShift(schedule.timeShift);
    }
    return total;
  }

  // Helper method to calculate hours from time_shift string
  double _calculateHoursFromTimeShift(String timeShift) {
    try {
      // Split the time range: "04:30 PM - 01:20 AM"
      final parts = timeShift.split(' - ');
      if (parts.length != 2) return 0.0;

      final startTimeStr = parts[0].trim(); // "04:30 PM"
      final endTimeStr = parts[1].trim(); // "01:20 AM"

      // Parse start and end times using DateFormat
      final formatter = DateFormat('h:mm a');
      final startTime = formatter.parse(startTimeStr);
      final endTime = formatter.parse(endTimeStr);

      // Handle overnight shifts (end time is next day)
      DateTime adjustedEndTime = endTime;
      if (endTime.isBefore(startTime) || endTime.isAtSameMomentAs(startTime)) {
        // Add 24 hours for overnight shifts
        adjustedEndTime = endTime.add(const Duration(days: 1));
      }

      // Calculate duration in hours
      final duration = adjustedEndTime.difference(startTime);
      final hours = duration.inMinutes / 60.0;

      return hours;
    } catch (e) {
      debugPrint('Error parsing time shift "$timeShift": $e');
      return 0.0;
    }
  }

  Future<void> fetchWorkAnalysis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) throw Exception('Token not found');

      final uri = Uri.parse(ApiUrls.workanAlysis());

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        _analysisData = workAnalysisWelcomeFromJson(response.body);
      } else {
        throw Exception('Failed to load work analysis');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _analysisData = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
