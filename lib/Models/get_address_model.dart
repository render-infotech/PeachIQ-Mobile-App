import 'dart:convert';

class Country {
  final int id;
  final String countryName;

  Country({required this.id, required this.countryName});

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'] ?? 0,
      countryName: json['country_name'] ?? '',
    );
  }
}

class StateDetails {
  final int id;
  final int countryId;
  final String stateName;

  StateDetails(
      {required this.id, required this.countryId, required this.stateName});

  factory StateDetails.fromJson(Map<String, dynamic> json) {
    return StateDetails(
      id: json['id'] ?? 0,
      countryId: json['country_id'] ?? 0,
      stateName: json['state_name'] ?? '',
    );
  }
}

class City {
  final int id;
  final String cityName;

  City({required this.id, required this.cityName});

  factory City.fromJson(Map<String, dynamic> json) => City(
        id: json["id"] ?? 0,
        cityName: json["city_name"] ?? "",
      );
}

List<Country> parseCountries(String responseBody) {
  final parsed = json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
  return parsed.map<Country>((json) => Country.fromJson(json)).toList();
}

List<StateDetails> parseStates(String responseBody) {
  final parsed = json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
  return parsed
      .map<StateDetails>((json) => StateDetails.fromJson(json))
      .toList();
}

List<City> parseCities(String responseBody) {
  final parsed = json.decode(responseBody)['data'].cast<Map<String, dynamic>>();
  return parsed.map<City>((json) => City.fromJson(json)).toList();
}
