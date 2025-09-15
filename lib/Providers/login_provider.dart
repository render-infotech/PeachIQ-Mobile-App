// lib/providers/login_provider.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:peach_iq/Models/login_model.dart';
import 'package:peach_iq/constants/api_utils.dart';

class LoginProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  LoginResponse? _lastResponse;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  LoginResponse? get lastResponse => _lastResponse;

  Future<void> login({required String email, required String password}) async {
    _setLoading(true);
    _setError(null);

    try {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password are required');
      }

      final Uri uri = Uri.parse(ApiUrls.login());

      if (kDebugMode) {
        print('Login URL: ${uri.toString()}');
        print('Attempting login for: $email');
      }

      final http.Response response = await http.post(
        uri,
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-IP': kStaticClientIp,
        },
        body: jsonEncode(<String, String>{
          'email': email,
          'password': password,
          'ip': kStaticClientIp,
        }),
      );
      // .timeout(const Duration(seconds: 15));

      if (kDebugMode) {
        print('Login response status: ${response.statusCode}');
        print('Login response body: ${response.body}');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String serverMsg = response.body;
        try {
          final Map<String, dynamic> m =
              jsonDecode(response.body) as Map<String, dynamic>;
          serverMsg = (m['message'] ?? serverMsg).toString();
        } catch (_) {}
        throw Exception('Login failed (${response.statusCode}): $serverMsg');
      }

      try {
        final Map<String, dynamic> jsonMap =
            jsonDecode(response.body) as Map<String, dynamic>;
        _lastResponse = LoginResponse.fromJson(jsonMap);

        // Persist token for subsequent authenticated requests
        final token = _lastResponse?.data.token;
        if (token != null && token.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('access_token', token);
          if (kDebugMode) {
            print('Saved access_token to SharedPreferences');
          }
        }
      } catch (e) {
        if (kDebugMode) print('JSON parsing error: $e');
        throw Exception('Invalid response format: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Login error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  // Clear any stored login data
  void clear() {
    _lastResponse = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }
}
