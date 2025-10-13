import 'dart:convert';
import 'dart:io';
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
    return (earnings * 100).truncateToDouble() / 100;
  }

  double get totalHours {
    return _analysisData?.data.cards.mtdTimeShifts.totalHours ?? 0.0;
  }

  Future<void> fetchWorkAnalysis() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        throw Exception('Authentication Error: Token not found.');
      }

      final uri = Uri.parse(ApiUrls.workanAlysis());
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        try {
          _analysisData = workAnalysisWelcomeFromJson(response.body);
        } catch (e) {
          throw Exception('Failed to parse server data. Please try again.');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Your session has expired. Please log in again.');
      } else {
        final errorBody = json.decode(response.body);
        final message = errorBody['message'] ?? 'Failed to load work analysis.';
        throw Exception('Error ${response.statusCode}: $message');
      }
    } on SocketException {
      _errorMessage = 'No Internet Connection. Please check your network.';
    } catch (e) {
      _errorMessage = e.toString().replaceFirst("Exception: ", "");
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
