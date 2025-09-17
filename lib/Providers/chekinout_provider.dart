import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/checkin_checkout_model.dart';
import 'package:peach_iq/models/shift_data_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/constants/api_utils.dart';

class CheckInCheckOutProvider with ChangeNotifier {
  ShiftData? _activeShift;
  bool _isLoading = false;
  String? _errorMessage;

  ShiftData? get activeShift => _activeShift;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setShift(ShiftData shift) {
    _activeShift = shift;
    notifyListeners();
  }

  Future<bool> checkIn({
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    return _handleCheckInOut(
      isCheckIn: true,
      url: ApiUrls.checkIn(),
      schedulingId: schedulingId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  Future<bool> checkOut({
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    return _handleCheckInOut(
      isCheckIn: false,
      url: ApiUrls.checkOut(),
      schedulingId: schedulingId,
      latitude: latitude,
      longitude: longitude,
    );
  }

  // REVISED: Combined the logic for check-in and check-out to reduce duplication.
  Future<bool> _handleCheckInOut({
    required bool isCheckIn,
    required String url,
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _performCheckInOut(
        url: url,
        schedulingId: schedulingId,
        latitude: latitude,
        longitude: longitude,
      );

      if (success && _activeShift != null) {
        if (isCheckIn) {
          debugPrint("✅ User checked in for schedulingId: $schedulingId");
          _activeShift = _activeShift!.copyWith(actualCheckIn: DateTime.now());
        } else {
          debugPrint("🔴 User checked out for schedulingId: $schedulingId");
          _activeShift = _activeShift!.copyWith(actualCheckOut: DateTime.now());
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _performCheckInOut({
    required String url,
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in again.');
    }

    final requestModel = CheckInOutRequest(
      schedulingId: schedulingId,
      latitude: latitude,
      longitude: longitude,
    );

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
  }
}
