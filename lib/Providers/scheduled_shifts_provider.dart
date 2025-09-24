import 'dart:convert';
import 'dart:async'; // Import for TimeoutException
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

  List<ScheduledShift> get schedules => _schedules;

  List<ScheduledShift> get upcomingSchedules {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final filtered =
        _schedules.where((shift) => !shift.start.isBefore(today)).toList();

    filtered.sort((a, b) => a.start.compareTo(b.start));

    return filtered;
  }

  Future<void> fetchScheduledShifts({DateTime? forDate}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // --- Start of Enhanced Logging ---
    debugPrint('--- [START] Fetching Scheduled Shifts ---');

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found in SharedPreferences.');
      }

      final dateToFetch = forDate ?? DateTime.now();
      final uri = Uri.parse(ApiUrls.scheduledShift(
        month: dateToFetch.month,
        year: dateToFetch.year,
      ));

      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'X-Client-IP': kStaticClientIp,
      };

      // Log the outgoing request
      debugPrint('🌐 REQUEST  => GET $uri');
      debugPrint('📋 HEADERS  => $headers');

      final response = await http
          .get(
            uri,
            headers: headers,
          )
          .timeout(const Duration(seconds: 30));

      // Log the incoming response
      debugPrint('⬅️ RESPONSE => STATUS: ${response.statusCode}');
      debugPrint('📦 BODY     => ${response.body}');

      if (response.statusCode == 200) {
        debugPrint(
            '✅ SUCCESS: Successfully fetched and parsed scheduled shifts.');
        final welcomeResponse = schedulesShiftsWelcomeFromJson(response.body);
        _schedules = welcomeResponse.data;
      } else {
        // Handle non-200 responses as errors
        String serverMsg = response.body;
        try {
          final Map<String, dynamic> jsonMap =
              json.decode(response.body) as Map<String, dynamic>;
          if (jsonMap['message'] != null) {
            serverMsg = jsonMap['message'].toString();
          }
        } catch (_) {
          // If parsing the error body fails, use the raw body.
        }
        throw Exception(
            'API Error (${response.statusCode}): Failed to load scheduled shifts. Server Message: "$serverMsg"');
      }
    } on TimeoutException catch (e) {
      _errorMessage = 'Network timeout: The request took too long to complete.';
      debugPrint('❌ ERROR: Request timed out. $e');
    } on http.ClientException catch (e) {
      _errorMessage = 'Network error: Please check your internet connection.';
      debugPrint('❌ ERROR: ClientException occurred. $e');
    } catch (e) {
      // Catch all other exceptions
      _errorMessage = e.toString();
      debugPrint('❌ ERROR: An unexpected exception occurred. Details: $e');
    } finally {
      _isLoading = false;
      debugPrint('--- [END] Fetching Scheduled Shifts ---');
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
    // The fetch method already handles state, just call it again.
    await fetchScheduledShifts();
  }
}
