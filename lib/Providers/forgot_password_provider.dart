import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/constants/api_utils.dart';

class ForgotPasswordProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  Future<void> requestPasswordReset({required String email}) async {
    _setLoading(true);
    _setError(null);
    _setSuccess(null);

    try {
      final Uri uri = Uri.parse(ApiUrls.forgotPassword());

      if (kDebugMode) {
        print('Forgot Password URL: ${uri.toString()}');
        print('Requesting reset for: $email');
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
          'ip': kStaticClientIp,
        }),
      );

      if (kDebugMode) {
        print('Forgot Password response status: ${response.statusCode}');
        print('Forgot Password response body: ${response.body}');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        String serverMsg = response.body;
        try {
          final Map<String, dynamic> m =
              jsonDecode(response.body) as Map<String, dynamic>;
          serverMsg = (m['message'] ?? serverMsg).toString();
        } catch (_) {}
        throw Exception('Request failed (${response.statusCode}): $serverMsg');
      }

      try {
        final Map<String, dynamic> jsonMap =
            jsonDecode(response.body) as Map<String, dynamic>;
        final successMsg = jsonMap['message'] as String? ??
            'If an account exists, a reset link has been sent.';
        _setSuccess(successMsg);
      } catch (e) {
        if (kDebugMode) print('JSON parsing error: $e');
        throw Exception('Invalid response format: ${response.body}');
      }
    } catch (e) {
      if (kDebugMode) print('Forgot Password error: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _errorMessage = null;
    _successMessage = null;
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

  void _setSuccess(String? message) {
    _successMessage = message;
    notifyListeners();
  }
}
