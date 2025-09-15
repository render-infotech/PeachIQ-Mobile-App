// lib/Providers/work_analysis_provider.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';

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

  // Getter for Total Shifts
  int get totalShifts => _analysisData?.data.cards.schedules.total ?? 0;

  // Getter for Total Earnings
  int get totalEarnings =>
      _analysisData?.data.cards.estimatedEarnings.total ?? 0;

  // Calculated Getter for Total Hours
  double get totalHours {
    if (_analysisData == null || _analysisData!.data.schedules.isEmpty) {
      return 0.0;
    }
    double total = 0.0;
    for (var schedule in _analysisData!.data.schedules) {
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

      // IMPORTANT: Add this URL to your api_utils.dart file
      final uri = Uri.parse(ApiUrls.workanAlysis());

      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        _analysisData = workAnalysisWelcomeFromJson(response.body);
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
