import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:peach_iq/Models/get_address_model.dart';
import 'package:peach_iq/constants/api_utils.dart';

class AddressProvider with ChangeNotifier {
  bool _isLoadingCountries = false;
  List<Country> _countries = [];
  String? _countryError;
  bool get isLoadingCountries => _isLoadingCountries;
  List<Country> get countries => _countries;
  String? get countryError => _countryError;

  bool _isLoadingStates = false;
  List<StateDetails> _states = [];
  String? _stateError;
  bool get isLoadingStates => _isLoadingStates;
  List<StateDetails> get states => _states;
  String? get stateError => _stateError;

  bool _isLoadingCities = false;
  List<City> _cities = [];
  String? _cityError;
  bool get isLoadingCities => _isLoadingCities;
  List<City> get cities => _cities;
  String? get cityError => _cityError;

  Future<void> fetchCountries() async {
    if (_countries.isNotEmpty) return;

    _isLoadingCountries = true;
    _countryError = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.getCountries());
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _countries = parseCountries(response.body);
      } else {
        _countryError =
            'Failed to load countries. Status code: ${response.statusCode}';
      }
    } catch (e) {
      _countryError = 'An error occurred: ${e.toString()}';
    } finally {
      _isLoadingCountries = false;
      notifyListeners();
    }
  }

  Future<void> fetchStates(int countryId) async {
    _states = [];
    _isLoadingStates = true;
    _stateError = null;
    notifyListeners();

    try {
      final url = Uri.parse(ApiUrls.getStates(countryId: countryId));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _states = parseStates(response.body);
      } else {
        _stateError = 'Failed to load states. Status: ${response.statusCode}';
      }
    } catch (e) {
      _stateError = 'An error occurred while fetching states: ${e.toString()}';
    } finally {
      _isLoadingStates = false;
      notifyListeners();
    }
  }

  Future<void> fetchCities(
      {required int countryId, required int stateId}) async {
    _cities = [];
    _isLoadingCities = true;
    _cityError = null;
    notifyListeners();

    try {
      final url =
          Uri.parse(ApiUrls.getCities(countryId: countryId, stateId: stateId));
      final response = await http.get(url);

      if (response.statusCode == 200) {
        _cities = parseCities(response.body);
      } else {
        _cityError = 'Failed to load cities. Status: ${response.statusCode}';
      }
    } catch (e) {
      _cityError = 'An error occurred while fetching cities: ${e.toString()}';
    } finally {
      _isLoadingCities = false;
      notifyListeners();
    }
  }

  void clearStates() {
    _states = [];
    _stateError = null;
    notifyListeners();
  }

  void clearCities() {
    _cities = [];
    _cityError = null;
    notifyListeners();
  }
}
