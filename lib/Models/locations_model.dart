// lib/models/location_model.dart

import 'dart:convert';

LocationsWelcome locationsWelcomeFromJson(String str) =>
    LocationsWelcome.fromJson(json.decode(str));

class LocationsWelcome {
  List<Location> data;
  String message;
  int status;

  LocationsWelcome({
    required this.data,
    required this.message,
    required this.status,
  });

  factory LocationsWelcome.fromJson(Map<String, dynamic> json) =>
      LocationsWelcome(
        data: json["data"] == null
            ? []
            : List<Location>.from(
                json["data"].map((x) => Location.fromJson(x))),
        message: json["message"] ?? "",
        status: json["status"] ?? 0,
      );
}

class Location {
  int institutionId;
  String name;

  Location({
    required this.institutionId,
    required this.name,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        institutionId: json["institution_id"] ?? 0,
        name: json["name"] ?? "Unknown Location",
      );
}
