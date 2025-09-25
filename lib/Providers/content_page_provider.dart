import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/constants/api_utils.dart';
import 'package:peach_iq/models/content_page_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContentPageProvider with ChangeNotifier {
  List<ContentPage> _pages = [];
  bool _isLoading = true; // Start in loading state by default
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Constructor: Fetches pages as soon as the provider is initialized.
  ContentPageProvider() {
    fetchAllPages();
  }

  /// Fetches all content pages from the API and caches them in the provider.
  Future<void> fetchAllPages() async {
    // If pages are already loaded, no need to fetch again.
    if (_pages.isNotEmpty) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');
      if (token == null || token.isEmpty) {
        throw Exception('Authentication token not found.');
      }

      final uri = Uri.parse(ApiUrls.getPages());
      final response = await http.get(uri, headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        final decodedResponse =
            ContentPageResponse.fromJson(json.decode(response.body));
        _pages = decodedResponse.data;
        _errorMessage = null;
      } else {
        throw Exception(
            'Failed to load content pages (Status code: ${response.statusCode})');
      }
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Finds a specific page by its title from the cached list.
  /// Case-insensitive and trims whitespace for robust matching.
  ContentPage? getPageByTitle(String title) {
    try {
      return _pages.firstWhere(
        (page) =>
            page.pageName.toLowerCase().trim() == title.toLowerCase().trim(),
      );
    } catch (e) {
      // Return null if no page with that title is found
      return null;
    }
  }
}
