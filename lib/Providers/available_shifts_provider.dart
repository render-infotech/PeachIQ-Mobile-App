import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/Models/available_shifts_model.dart';
import 'package:peach_iq/constants/api_utils.dart';

class AvailableShiftsProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Welcome? _availableShiftsResponse;
  List<Schedule> _schedules = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Schedule> get schedules => _schedules;
  bool get hasSchedules => _schedules.isNotEmpty;

  void clear() {
    _availableShiftsResponse = null;
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
      };

      final response = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decodedJson = jsonDecode(response.body);
        // Assuming the root of the response is a List under a 'data' key
        // Adjust if the root itself is the list.
        if (decodedJson['data'] is List) {
          List<dynamic> scheduleData = decodedJson['data'];
          _schedules =
              scheduleData.map((data) => Schedule.fromJson(data)).toList();
        } else {
          throw Exception('Expected a list of schedules in the "data" field.');
        }
      } else {
        throw Exception(
            'Failed to load shifts. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await fetchAvailableShifts();
  }
}
