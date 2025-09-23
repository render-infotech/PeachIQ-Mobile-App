import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/scheduled_shifts_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/constants/api_utils.dart';

class SchedulesShiftsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<ScheduledShift> _schedules = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Returns the original, unfiltered list of all shifts for the fetched month.
  List<ScheduledShift> get schedules => _schedules;

  /// ✨ NEW: Returns a filtered and sorted list of shifts from today onwards.
  List<ScheduledShift> get upcomingSchedules {
    final now = DateTime.now();
    // Normalize 'today' to midnight to ensure we compare dates correctly.
    final today = DateTime(now.year, now.month, now.day);

    // Filter out any shifts that started before today.
    final filtered =
        _schedules.where((shift) => !shift.start.isBefore(today)).toList();

    // Sort the list to show the soonest shifts first.
    filtered.sort((a, b) => a.start.compareTo(b.start));

    return filtered;
  }

  Future<void> fetchScheduledShifts({DateTime? forDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

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

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final welcomeResponse = schedulesShiftsWelcomeFromJson(response.body);
        _schedules = welcomeResponse.data;
      } else {
        throw Exception(
            'Failed to load scheduled shifts: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching scheduled shifts: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _schedules = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> retry() async {
    await fetchScheduledShifts();
  }
}
