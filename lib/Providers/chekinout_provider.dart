import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/checkin_checkout_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/constants/api_utils.dart';

class CheckInCheckOutProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> checkIn({
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    final requestModel = CheckInOutRequest(
      schedulingId: schedulingId,
      latitude: latitude,
      longitude: longitude,
    );
    final success = await _performCheckInOut(
      url: ApiUrls.checkIn(),
      requestModel: requestModel,
    );

    if (success) {
      debugPrint("✅ User checked in for schedulingId: $schedulingId");
    }

    return success;
  }

  Future<bool> checkOut({
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    final requestModel = CheckInOutRequest(
      schedulingId: schedulingId,
      latitude: latitude,
      longitude: longitude,
    );
    final success = await _performCheckInOut(
      url: ApiUrls.checkOut(),
      requestModel: requestModel,
    );

    if (success) {
      debugPrint("🔴 User checked out for schedulingId: $schedulingId");
    }

    return success;
  }

  Future<bool> _performCheckInOut({
    required String url,
    required CheckInOutRequest requestModel,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please log in again.');
      }

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode(requestModel.toJson()),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final responseBody = json.decode(response.body);
        _errorMessage =
            responseBody['message'] ?? 'An unknown API error occurred.';
        return false;
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
