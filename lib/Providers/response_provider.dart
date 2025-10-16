import 'package:flutter/material.dart';
import 'available_shifts_provider.dart'; // Ensure this import path is correct

class ShiftResponseProvider with ChangeNotifier {
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// **UPDATED: Now uses the integrated response method from AvailableShiftsProvider**
  Future<bool> respondToShift({
    required int notifyId,
    required int status,
    required AvailableShiftsProvider shiftsProvider,
  }) async {
    _errorMessage = null;

    try {
      // Use the new integrated method that handles everything properly
      final success = await shiftsProvider.respondToShift(notifyId, status);

      if (!success) {
        _errorMessage = 'Failed to respond to shift. Please try again.';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
