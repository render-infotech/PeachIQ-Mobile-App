// lib/providers/profile_provider.dart
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/constants/api_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/Models/profile_model.dart';

class ProfileProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  Profile? _profile;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Profile? get profile => _profile;

  String get fullName {
    final p = _profile;
    if (p == null) return 'Loading...';
    final first = p.firstName.trim();
    final last = p.lastName.trim();
    if (first.isEmpty && last.isEmpty) return 'Guest User';
    return [first, last].where((e) => e.isNotEmpty).join(' ').trim();
  }

  String get email => _profile?.email.trim() ?? '';

  // --- NEW GETTERS ADDED HERE ---

  /// Returns the user's ID, or null if the profile isn't loaded.
  int? get userId => _profile?.id;

  /// Returns the user's dashboard type (e.g., "caregiver"), or an empty string.
  String get dashboard => _profile?.dashboard.trim() ?? '';
  
  // --- END OF NEW GETTERS ---


  void setProfile(Profile profile) {
    _profile = profile;
    notifyListeners();
  }

  void setFromResponse(ProfileResponse response) {
    _profile = response.data;
    notifyListeners();
  }

  void clear() {
    _profile = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMyProfile({String? bearerToken}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = bearerToken ?? await _getBearerToken();

      if (kDebugMode) {
        print('Using token: ${token != null ? _safePreview(token) : "NULL"}');
      }

      if (token == null || token.isEmpty) {
        _errorMessage = 'No authentication token found. Please login.';
        if (kDebugMode) print('No token available for profile fetch');
        return;
      }

      final uri = Uri.parse(ApiUrls.myProfile());
      final headers = <String, String>{
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _formatAuthorizationHeader(token),
      };

      final resp = await http
          .get(uri, headers: headers)
          .timeout(const Duration(seconds: 20));

      if (kDebugMode) {
        print('Status Code: ${resp.statusCode}');
        print('Response Body: ${resp.body}');
      }

      if (resp.statusCode == 200) {
        final Map<String, dynamic> map =
            jsonDecode(resp.body) as Map<String, dynamic>;
        
        // NO CHANGE NEEDED HERE:
        // ProfileResponse.fromMap correctly calls Profile.fromMap,
        // which now parses 'id' and 'dashboard' automatically.
        final profileResp = ProfileResponse.fromMap(map);
        _profile = profileResp.data;
        _errorMessage = null;
        if (kDebugMode) print('Profile loaded successfully');

        try {
          // You could add logic here using the new `_profile.id`
          // or `_profile.dashboard` if needed
        } catch (_) {}
      } else if (resp.statusCode == 401) {
        _errorMessage = 'Authentication failed. Please login again.';
        await _clearStoredToken();
        if (kDebugMode) print('Authentication failed - token cleared');
      } else {
        _errorMessage = 'HTTP ${resp.statusCode}: Failed to load profile.';
        if (kDebugMode) print('HTTP Error ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please check your connection.';
      if (kDebugMode) print('Exception in fetchMyProfile: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final token = await _getBearerToken();
      if (token == null || token.isEmpty) {
        throw Exception('No authentication token found. Please login.');
      }

      final uri = Uri.parse(ApiUrls.ChangePassword());
      final headers = {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Authorization': _formatAuthorizationHeader(token),
      };
      final body = jsonEncode({
        'old_password': oldPassword,
        'new_password': newPassword,
        'confirm_password': confirmPassword,
      });

      final response = await http
          .post(uri, headers: headers, body: body)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true; // Success
      } else {
        // Handle API errors (like "Invalid old password")
        final responseBody = jsonDecode(response.body);
        _errorMessage = responseBody['message'] ?? 'An unknown error occurred.';
        return false; // Failure
      }
    } catch (e) {
      _errorMessage = 'An error occurred. Please check your connection.';
      if (kDebugMode) {
        print('Exception in changePassword: $e');
      }
      return false; // Failure
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retry() async {
    await fetchMyProfile();
  }

  Future<String?> _getBearerToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final accessToken = prefs.getString('access_token');
      if (kDebugMode) {
        print('Access Token: ${_safePreview(accessToken ?? "NULL")}');
      }
      return accessToken;
    } catch (e) {
      if (kDebugMode) print('Error getting bearer token: $e');
      return null;
    }
  }

  String _safePreview(String token) {
    if (token.length <= 20) return token;
    return '${token.substring(0, 10)}...${token.substring(token.length - 10)}';
  }

  String _formatAuthorizationHeader(String tokenOrHeader) {
    final t = tokenOrHeader.trim();
    if (t.isEmpty) {
      if (kDebugMode) print('⚠️ Empty token provided');
      return '';
    }
    if (t.toLowerCase().startsWith('bearer ')) {
      return t;
    }
    return 'Bearer $t';
  }

  Future<void> _clearStoredToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('access_token');
      if (kDebugMode) print('Stored token cleared');
    } catch (e) {
      if (kDebugMode) print('Error clearing stored token: $e');
    }
  }

  Future<void> logout() async {
    try {
      clear();
      await _clearStoredToken();
      if (kDebugMode) print('User logged out successfully');
    } catch (e) {
      if (kDebugMode) print('Error during logout: $e');
    }
  }
}