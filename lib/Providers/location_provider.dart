import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/locations_model.dart';
import 'package:peach_iq/constants/api_utils.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocationProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _errorMessage;
  List<Location> _locations = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Location> get locations => _locations;

  Future<void> fetchLocations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final uri = Uri.parse(ApiUrls.Locations());

      final response = await http.get(
        uri,
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final welcomeResponse = locationsWelcomeFromJson(response.body);
        _locations = welcomeResponse.data;
      } else {
        throw Exception('Failed to load locations: ${response.statusCode}');
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Error fetching locations: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
