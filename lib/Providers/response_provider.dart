import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/api_utils.dart';
import 'available_shifts_provider.dart';

class ShiftResponseProvider with ChangeNotifier {
  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  Future<bool> respondToShift({
    required int notifyId,
    required int status,
    AvailableShiftsProvider? shiftsProvider,
  }) async {
    _errorMessage = null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final String? authToken = prefs.getString('access_token');

      if (authToken == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      debugPrint('Responding to shift - notifyId: $notifyId, status: $status');

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

      debugPrint('Shift response API - Status: ${response.statusCode}');
      debugPrint('Shift response API - Body: ${response.body}');

      if (response.statusCode == 200) {
        // Immediately remove the shift from local list
        if (shiftsProvider != null) {
          shiftsProvider.removeShift(notifyId);

          // Refresh the entire list after a short delay to ensure server state is updated
          Future.delayed(const Duration(seconds: 2), () {
            shiftsProvider.refreshAfterAction();
          });
        }

        debugPrint('Successfully responded to shift with notifyId: $notifyId');
        return true;
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage =
            responseBody['message'] ?? 'Failed to respond to shift.';
        debugPrint('Failed to respond to shift: $_errorMessage');
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      debugPrint('Error responding to shift: $_errorMessage');
      return false;
    } finally {
      // No need to manage global loading state
    }
  }

  /// Clear any error messages
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
