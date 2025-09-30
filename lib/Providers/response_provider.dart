import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/constants/api_utils.dart'; // Ensure this import path is correct
import 'available_shifts_provider.dart'; // Ensure this import path is correct

class ShiftResponseProvider with ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<bool> respondToShift({
    required int notifyId,
    required int status,
    required AvailableShiftsProvider shiftsProvider,
  }) async {
    _errorMessage = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('access_token');
      if (authToken == null) {
        throw Exception('Authentication token not found.');
      }

      final url = Uri.parse(ApiUrls.respondToShift());
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: json.encode({'notify_id': notifyId, 'status': status}),
      );

      if (response.statusCode == 200) {
        // Optimistically update the UI without a full refresh
        shiftsProvider.updateShiftDecision(notifyId, status);

        debugPrint('Successfully responded to shift with notifyId: $notifyId');
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

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
