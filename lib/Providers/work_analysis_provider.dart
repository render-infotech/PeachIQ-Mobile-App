// lib/Providers/work_analysis_provider.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:peach_iq/Models/work_analysis_model.dart';
import 'package:peach_iq/constants/api_utils.dart';

class WorkAnalysisProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  WorkAnalysisWelcome? _analysisData;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  WorkAnalysisWelcome? get analysisData => _analysisData;

  // <<< 1. UPDATE GETTER TO USE MTD VALUE
  int get totalShifts => _analysisData?.data.cards.mtdSchedules.total ?? 0;

  // <<< 2. UPDATE GETTER TO USE MTD VALUE
  double get totalEarnings =>
      _analysisData?.data.cards.mtdEstimatedEarnings.total ?? 0.0;

  // No change to totalHours as MTD hours aren't provided directly in the 'cards' object.
  // This continues to be calculated from the main schedules list.
  double get totalHours {
    if (_analysisData == null || _analysisData!.data.schedules.isEmpty) {
      return 0.0;
    }
    double total = 0.0;
    final now = DateTime.now();

    // Filter for past/current schedules before summing hours
    final monthToDateSchedules =
        _analysisData!.data.schedules.where((schedule) {
      return !schedule.scheduleStart.isAfter(now);
    }).toList();

    for (var schedule in monthToDateSchedules) {
      total += double.tryParse(schedule.payHours) ?? 0.0;
    }
    return total;
  }

  Future<void> fetchWorkAnalysis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) throw Exception('Token not found');

      final uri = Uri.parse(ApiUrls.workanAlysis());

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        _analysisData = workAnalysisWelcomeFromJson(response.body);

        // <<< 3. REMOVE OLD MANUAL MTD CALCULATION BLOCK
        // The manual filtering and recalculation logic is no longer needed
        // as the API now provides the correct MTD totals directly.
      } else {
        throw Exception('Failed to load work analysis');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _analysisData = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
