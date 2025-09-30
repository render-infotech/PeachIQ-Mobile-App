import 'dart:convert';
import 'package:intl/intl.dart';

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
  int caregiverDecision; // Made non-final for optimistic updates
  final String displayInstitutionName;
  final DateTime startDate;
  final DateTime? endDate;
  final String schedulingType;
  final String displayTimeshift;
  final String displayWorkshift;
  final Category category;
  final UnitArea? unitarea;

  AvailableShift({
    required this.id,
    required this.notifyId,
    required this.caregiverDecision,
    required this.displayInstitutionName,
    required this.startDate,
    this.endDate,
    required this.schedulingType,
    required this.displayTimeshift,
    required this.displayWorkshift,
    required this.category,
    this.unitarea,
  });

  String get name => displayInstitutionName.trim();
  String get timeLine => displayTimeshift;
  String get role => category.jobCategory;
  String get shiftType => displayWorkshift;
  String get unitArea => unitarea?.unitareaName ?? "N/A";

  String get dateLine {
    String getDayWithSuffix(DateTime date) {
      final day = date.day;
      if (day >= 11 && day <= 13) return "${day}th";
      switch (day % 10) {
        case 1:
          return "${day}st";
        case 2:
          return "${day}nd";
        case 3:
          return "${day}rd";
        default:
          return "${day}th";
      }
    }

    final end = endDate ?? startDate;
    final isSingleDay = startDate.year == end.year &&
        startDate.month == end.month &&
        startDate.day == end.day;

    if (isSingleDay || schedulingType == "Once") {
      return "${DateFormat("EEEE, MMMM").format(startDate)} ${getDayWithSuffix(startDate)}";
    } else {
      final startFormatted =
          "${DateFormat("MMMM").format(startDate)} ${getDayWithSuffix(startDate)}";
      final endFormatted =
          "${DateFormat("MMMM").format(end)} ${getDayWithSuffix(end)}";
      return "$startFormatted - $endFormatted, ${end.year}";
    }
  }

  factory AvailableShift.fromJson(Map<String, dynamic> json) => AvailableShift(
        id: json["id"] ?? 0,
        notifyId: json["notify_id"] ?? 0,
        caregiverDecision: json["caregiver_decision"] ?? 0,
        displayInstitutionName:
            json["display_institution_name"] ?? "Unknown Institution",
        startDate: json["start_date"] != null
            ? DateTime.tryParse(json["start_date"]) ?? DateTime.now()
            : DateTime.now(),
        endDate: json["end_date"] != null
            ? DateTime.tryParse(json["end_date"])
            : null,
        schedulingType: json["scheduling_type"] ?? "Once",
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

  Category(
      {required this.id, required this.jobCategory, required this.colorCode});

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

  UnitArea(
      {required this.id,
      required this.unitareaName,
      required this.description});

  factory UnitArea.fromJson(Map<String, dynamic> json) => UnitArea(
        id: json["id"] ?? 0,
        unitareaName: json["unitarea_name"] ?? "N/A",
        description: json["description"] ?? "",
      );
}
