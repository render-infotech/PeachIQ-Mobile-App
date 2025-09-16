import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/Models/available_shifts_model.dart';
import 'package:peach_iq/constants/api_utils.dart';

class AvailableShiftsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<AvailableShift> _schedules = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AvailableShift> get schedules => _schedules;
  bool get hasSchedules => _schedules.isNotEmpty;

  void clear() {
    _schedules = [];
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAvailableShifts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login.');
      }

      final uri = Uri.parse(ApiUrls.availableShifts());
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      debugPrint('Making API request to: ${uri.toString()}');
      debugPrint('Headers: $headers');

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      debugPrint('Response status code: ${response.statusCode}');
      debugPrint('Response headers: ${response.headers}');

      if (response.statusCode == 200) {
        debugPrint('Available shifts API response: ${response.body}');

        try {
          final availableShiftsResponse =
              availableShiftsResponseFromJson(response.body);
          _schedules = availableShiftsResponse.data;
          debugPrint(
              'Successfully parsed ${_schedules.length} available shifts');

          _isLoading = false;
          notifyListeners();
        } catch (parseError) {
          debugPrint('Error parsing available shifts response: $parseError');
          debugPrint('Raw response: ${response.body}');

          try {
            final decodedJson = jsonDecode(response.body);
            List<dynamic> schedulesList = [];

            if (decodedJson is List) {
              schedulesList = decodedJson;
            } else if (decodedJson is Map<String, dynamic>) {
              if (decodedJson['data'] != null &&
                  decodedJson['data'] is Map<String, dynamic>) {
                final data = decodedJson['data'];
                if (data['schedules'] != null && data['schedules'] is List) {
                  schedulesList = data['schedules'];
                }
              } else if (decodedJson['schedules'] != null &&
                  decodedJson['schedules'] is List) {
                schedulesList = decodedJson['schedules'];
              }
            }

            _schedules = schedulesList
                .map((scheduleData) => AvailableShift.fromJson(scheduleData))
                .toList();

            debugPrint('Fallback parsing found ${_schedules.length} schedules');
            _isLoading = false;
            notifyListeners();
          } catch (fallbackError) {
            debugPrint('Fallback parsing also failed: $fallbackError');
            throw Exception('Failed to parse API response: $parseError');
          }
        }
      } else if (response.statusCode == 401) {
        throw Exception('Authentication failed. Please login again.');
      } else if (response.statusCode == 403) {
        throw Exception('Access forbidden. Please check your permissions.');
      } else if (response.statusCode == 404) {
        throw Exception('API endpoint not found. Please contact support.');
      } else if (response.statusCode >= 500) {
        throw Exception('Server error. Please try again later.');
      } else {
        try {
          final errorBody = jsonDecode(response.body);
          throw Exception(errorBody['message'] ??
              'Failed to load shifts. Status code: ${response.statusCode}');
        } catch (e) {
          throw Exception(
              'Failed to load shifts. Status code: ${response.statusCode}');
        }
      }
    } on TimeoutException {
      debugPrint('TimeoutException in fetchAvailableShifts');
      _errorMessage = 'Request timed out. Please check your connection.';
    } on http.ClientException {
      debugPrint('ClientException in fetchAvailableShifts');
      _errorMessage = 'Network error. Please try again.';
    } on FormatException {
      debugPrint('FormatException in fetchAvailableShifts');
      _errorMessage = 'Received an invalid response from the server.';
    } catch (e) {
      debugPrint('Error fetching available shifts: ${e.toString()}');
      debugPrint('Error type: ${e.runtimeType}');

      // Provide more specific error messages
      if (e.toString().contains('401') ||
          e.toString().contains('Unauthorized')) {
        _errorMessage = 'Authentication failed. Please login again.';
      } else if (e.toString().contains('No authentication token')) {
        _errorMessage = 'Please login to view available shifts.';
      } else {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void removeShift(int notifyId) {
    _schedules.removeWhere((schedule) => schedule.notifyId == notifyId);
    notifyListeners();
  }

  Future<void> retry() async {
    _errorMessage = null;
    await fetchAvailableShifts();
  }

  // Debug method to get current API endpoint
  String get apiEndpoint => ApiUrls.availableShifts();

  // Test method to verify API connectivity
  Future<bool> testApiConnection() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        debugPrint('No authentication token available for API test');
        return false;
      }

      final uri = Uri.parse(ApiUrls.availableShifts());
      final response = await http.head(uri, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 10));

      debugPrint('API connectivity test - Status: ${response.statusCode}');
      return response.statusCode <
          500; // Any status < 500 means API is reachable
    } catch (e) {
      debugPrint('API connectivity test failed: $e');
      return false;
    }
  }
}
