import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart'; // Import SharedPreferences
import '../constants/api_utils.dart';

class ShiftResponseProvider with ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> respondToShift({
    required int notifyId,
    required int status,
  }) async {
    _errorMessage = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('access_token');

      if (authToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      final url = Uri.parse(ApiUrls.respondToShift());
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({
          'notify_id': notifyId,
          'status': status,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage =
            responseBody['message'] ?? 'Failed to respond to shift.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      return false;
    }
  }
}
