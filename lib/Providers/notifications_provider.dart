import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/notifications_model.dart';
import 'package:peach_iq/constants/api_utils.dart';
import 'package:shared_preferences/shared_preferences.dart'; 


class NotificationProvider with ChangeNotifier {
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<NotificationModel> get notifications => _notifications;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  
  // Get count of unread notifications
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }

  // --- Helper to get token ---
  Future<String?> _getAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final String? authToken = prefs.getString('access_token');
    if (authToken == null || authToken.isEmpty) {
      throw Exception('Authentication token not found or is empty');
    }
    return authToken;
  }

  // --- Helper to get standard headers ---
  Map<String, String> _getHeaders(String authToken) {
    return {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.acceptHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer $authToken',
    };
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final Uri url = Uri.parse(ApiUrls.getMynotifications()); 
    
    try {
      final authToken = await _getAuthToken();
      final response = await http.get(
        url,
        headers: _getHeaders(authToken!),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final notificationList = NotificationListModel.fromJson(responseData);
        _notifications = notificationList.notifications;
      } else {
        final errorData = jsonDecode(response.body);
        _errorMessage = errorData['message'] ?? 'Failed to load notifications.';
      }
    } on SocketException {
      _errorMessage = 'Network error. Please check your connection.';
    } catch (e) {
      _errorMessage = 'An unexpected error occurred: $e';
      print('FetchNotifications Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> markOneAsRead(int notificationId) async {
    final Uri url = Uri.parse(ApiUrls.postNotificationread());
    
    // --- BETTER DEBUGGING ---
    print('--- Calling markOneAsRead ---');
    print('URL: $url');
    final String requestBody = jsonEncode({'id': notificationId});
    print('Request Body: $requestBody');
    // --- END DEBUGGING ---

    try {
      final authToken = await _getAuthToken();
      
      final response = await http.post(
        url,
        headers: _getHeaders(authToken!),
        body: requestBody,
      );

      // --- BETTER DEBUGGING ---
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      // --- END DEBUGGING ---

      if (response.statusCode == 200) {
        _notifications = _notifications.map((notification) {
          if (notification.id == notificationId) {
            return notification.copyWith(isRead: true);
          }
          return notification;
        }).toList();
        notifyListeners();
      } else {
        print('markOneAsRead Error: Failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('markOneAsRead Exception: $e');
    }
  }

  Future<void> markAllAsRead() async {
    final Uri url = Uri.parse(ApiUrls.postAllnotificationread());

    // --- BETTER DEBUGGING ---
    print('--- Calling markAllAsRead ---');
    print('URL: $url');
    // --- END DEBUGGING ---

    try {
      final authToken = await _getAuthToken();
      final response = await http.post(
        url,
        headers: _getHeaders(authToken!),
      );

      // --- BETTER DEBUGGING ---
      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');
      // --- END DEBUGGING ---

      if (response.statusCode == 200) {
        _notifications = _notifications.map((notification) {
          if (notification.isRead) return notification;
          return notification.copyWith(isRead: true);
        }).toList();
        notifyListeners();
      } else {
        print('markAllAsRead Error: Failed with status ${response.statusCode}');
      }
    } catch (e) {
      print('markAllAsRead Exception: $e');
    }
  }
}