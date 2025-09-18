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
        status: (json["status"] as num?)?.toInt() ?? 0,
      );
}

class Location {
  final int institutionId;
  final String name;

  // FIX: Changed to a const constructor
  const Location({
    required this.institutionId,
    required this.name,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        institutionId: (json["institution_id"] as num?)?.toInt() ?? 0,
        name: json["name"] ?? "Unknown Location",
      );

  // Optional: Add for debugging or comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          runtimeType == other.runtimeType &&
          institutionId == other.institutionId;

  @override
  int get hashCode => institutionId.hashCode;
}
