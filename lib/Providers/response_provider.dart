import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/constants/api_utils.dart';

class ResponseProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<bool> respondToShift({
    required int notifyId,
    required int status,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) throw Exception('Token not found');

      final uri = Uri.parse(ApiUrls.respondToShift());

      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final body = jsonEncode({
        'notify_id': notifyId,
        'status': status,
      });

      final response = await http.post(uri, headers: headers, body: body);

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        _successMessage =
            responseBody['message'] ?? 'Successfully responded to shift.';
        return true;
      } else {
        final errorBody = jsonDecode(response.body);
        throw Exception(errorBody['message'] ?? 'Failed to respond to shift.');
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
