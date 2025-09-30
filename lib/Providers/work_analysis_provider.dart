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

  int get totalShifts => _analysisData?.data.cards.mtdSchedules.total ?? 0;

  double get totalEarnings {
    final earnings =
        _analysisData?.data.cards.mtdEstimatedEarnings.total ?? 0.0;
    // Truncate the value to 2 decimal places without rounding.
    // e.g., 2442.8898 -> 2442.88
    return (earnings * 100).truncateToDouble() / 100;
  }

  double get totalHours {
    if (_analysisData == null || _analysisData!.data.schedules.isEmpty) {
      return 0.0;
    }
    double total = 0.0;
    final now = DateTime.now();

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
