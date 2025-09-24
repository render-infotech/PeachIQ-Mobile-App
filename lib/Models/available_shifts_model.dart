// lib/models/available_shift_model.dart

import 'dart:convert';
import 'package:intl/intl.dart';

// Helper function to easily decode the entire JSON response
AvailableShiftsResponse availableShiftsResponseFromJson(String str) =>
    AvailableShiftsResponse.fromJson(json.decode(str));

class AvailableShiftsResponse {
  final List<AvailableShift> data;
  final String message;
  final int status;

  AvailableShiftsResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory AvailableShiftsResponse.fromJson(Map<String, dynamic> json) =>
      AvailableShiftsResponse(
        data: json["data"] != null
            ? List<AvailableShift>.from(
                json["data"].map((x) => AvailableShift.fromJson(x)))
            : [],
        message: json["message"] ?? "Unknown error",
        status: json["status"] ?? 500,
      );
}

class AvailableShift {
  final int id;
  final int notifyId;
  final String displayInstitutionName;
  final DateTime startDate;
  final String displayTimeshift;
  final String displayWorkshift;
  final Category category;
  final UnitArea? unitarea;

  AvailableShift({
    required this.id,
    required this.notifyId,
    required this.displayInstitutionName,
    required this.startDate,
    required this.displayTimeshift,
    required this.displayWorkshift,
    required this.category,
    this.unitarea,
  });

  // --- GETTERS FOR THE UI WIDGET ---
  // These getters provide the exact strings your AvailableShiftCard needs.

  /// The institution name. E.g., "ABS Hospital"
  String get name => displayInstitutionName.trim();

  /// Formatted time range. E.g., "06:00 AM - 02:00 PM"
  String get timeLine => displayTimeshift;

  /// The job category. E.g., "PSW" or "RN"
  String get role => category.jobCategory;

  /// The type of shift. E.g., "Floor Shift"
  String get shiftType => displayWorkshift;

  /// The unit area name. Returns "N/A" if null.
  String get unitArea => unitarea?.unitareaName ?? "N/A";

  /// Formats the date into the format "Tuesday 16th September".
  String get dateLine {
    // Helper function to get the 'st', 'nd', 'rd', 'th' suffix for the day
    String getDaySuffix(int day) {
      if (day >= 11 && day <= 13) {
        return 'th';
      }
      switch (day % 10) {
        case 1:
          return 'st';
        case 2:
          return 'nd';
        case 3:
          return 'rd';
        default:
          return 'th';
      }
    }

    final day = startDate.day;
    final suffix = getDaySuffix(day);
    // Creates the format: "Weekday Day<suffix> Month" e.g., "Tuesday 16th September"
    return DateFormat("EEEE d'$suffix' MMMM").format(startDate);
  }
  // ------------------------------------

  factory AvailableShift.fromJson(Map<String, dynamic> json) => AvailableShift(
        id: json["id"] ?? 0,
        notifyId: json["notify_id"] ?? 0,
        displayInstitutionName:
            json["display_institution_name"] ?? "Unknown Institution",
        // Safely parse the date string into a DateTime object
        startDate: json["start_date"] != null
            ? DateTime.tryParse(json["start_date"]) ?? DateTime.now()
            : DateTime.now(),
        displayTimeshift: json["display_timeshift"] ?? "N/A",
        displayWorkshift: json["display_workshift"] ?? "N/A",
        category: Category.fromJson(json["category"] ?? {}),
        unitarea: json["unitarea"] == null
            ? null
            : UnitArea.fromJson(json["unitarea"]),
      );
}

class Category {
  final int id;
  final String jobCategory;
  final String colorCode;

  Category({
    required this.id,
    required this.jobCategory,
    required this.colorCode,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"] ?? 0,
        jobCategory: json["job_category"] ?? "N/A",
        colorCode: json["color_code"] ?? "#000000",
      );
}

class UnitArea {
  final int id;
  final String unitareaName;
  final String description;

  UnitArea({
    required this.id,
    required this.unitareaName,
    required this.description,
  });

  factory UnitArea.fromJson(Map<String, dynamic> json) => UnitArea(
        id: json["id"] ?? 0,
        unitareaName: json["unitarea_name"] ?? "N/A",
        description: json["description"] ?? "",
      );
}
