import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/checkin_checkout_model.dart';
import 'package:peach_iq/models/shift_data_model.dart'; // FIX: Import your ShiftData model
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/constants/api_utils.dart';

class CheckInCheckOutProvider with ChangeNotifier {
  // FIX: Add state variables for the active shift and loading status.
  ShiftData? _activeShift;
  bool _isLoading = false;
  String? _errorMessage;

  // FIX: Add getters for the new state.
  ShiftData? get activeShift => _activeShift;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // FIX: Add a method to initialize the provider with the shift from the screen.
  void setShift(ShiftData shift) {
    _activeShift = shift;
    // Notify listeners in case the initial shift data is different from the default.
    notifyListeners();
  }

  Future<bool> checkIn({
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _performCheckInOut(
        url: ApiUrls.checkIn(),
        schedulingId: schedulingId,
        latitude: latitude,
        longitude: longitude,
      );

      if (success) {
        debugPrint("✅ User checked in for schedulingId: $schedulingId");
        if (_activeShift != null) {
          _activeShift = ShiftData(
            schedulingId: _activeShift!.schedulingId,
            facility: _activeShift!.facility,
            floorWing: _activeShift!.floorWing,
            dateLine: _activeShift!.dateLine,
            time: _activeShift!.time,
            dateTime: _activeShift!.dateTime,
            shiftTime: _activeShift!.shiftTime,
            actualCheckIn: DateTime.now(), // Set the check-in time
            actualCheckOut: _activeShift!.actualCheckOut,
          );
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners(); // This call notifies the UI of both loading and data changes.
    }
  }

  Future<bool> checkOut({
    required int schedulingId,
    required String latitude,
    required String longitude,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _performCheckInOut(
        url: ApiUrls.checkOut(),
        schedulingId: schedulingId,
        latitude: latitude,
        longitude: longitude,
      );

      if (success) {
        debugPrint("🔴 User checked out for schedulingId: $schedulingId");
        // FIX: Update the internal state upon successful check-out.
        if (_activeShift != null) {
          _activeShift = ShiftData(
            schedulingId: _activeShift!.schedulingId,
            facility: _activeShift!.facility,
            floorWing: _activeShift!.floorWing,
            dateLine: _activeShift!.dateLine,
            time: _activeShift!.time,
            dateTime: _activeShift!.dateTime,
            shiftTime: _activeShift!.shiftTime,
            actualCheckIn: _activeShift!.actualCheckIn,
            actualCheckOut: DateTime.now(), // Set the check-out time
          );
        }
      }
      return success;
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners(); // This call notifies the UI of both loading and data changes.
    }
  }

  // This private method now only handles the network request and returns a boolean or throws an error.
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
      // Set the error message in the public methods that call this.
      _errorMessage =
          responseBody['message'] ?? 'An unknown API error occurred.';
      return false;
    }
  }
}
