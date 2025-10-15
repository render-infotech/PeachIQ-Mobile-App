import 'dart:convert';
import 'package:intl/intl.dart';

SchedulesShiftsWelcome schedulesShiftsWelcomeFromJson(String str) =>
    SchedulesShiftsWelcome.fromJson(json.decode(str));

class SchedulesShiftsWelcome {
  List<ScheduledShift> data;
  String message;
  int status;

  SchedulesShiftsWelcome({
    required this.data,
    required this.message,
    required this.status,
  });

  factory SchedulesShiftsWelcome.fromJson(Map<String, dynamic> json) =>
      SchedulesShiftsWelcome(
        data: json["data"] == null
            ? []
            : List<ScheduledShift>.from(
                json["data"].map((x) => ScheduledShift.fromJson(x))),
        message: json["message"] ?? "",
        status: json["status"] ?? 0,
      );
}

class ScheduledShift {
  DateTime start;
  DateTime end;
  int scheduleId;
  String institution;
  String category;
  String workShift;
  String timeShift; // Pre-formatted time from API like "04:00 PM - 12:00 AM"
  String unitarea;
  int? checkInStatus;
  // --- ADDED THESE FIELDS ---
  DateTime? actualCheckIn;
  DateTime? actualCheckOut;

  ScheduledShift({
    required this.start,
    required this.end,
    required this.scheduleId,
    required this.institution,
    required this.category,
    required this.workShift,
    required this.timeShift,
    required this.unitarea,
    this.checkInStatus,
    // --- ADDED TO CONSTRUCTOR ---
    this.actualCheckIn,
    this.actualCheckOut,
  });

  // Getter to convert 24-hour format to 12-hour format
  String get formattedTimeShift {
    try {
      // Check if timeShift is already in 12-hour format (contains AM/PM)
      if (timeShift.toUpperCase().contains('AM') ||
          timeShift.toUpperCase().contains('PM')) {
        return timeShift; // Already in 12-hour format
      }

      // Split the time range: "18:00:00 - 19:00:00"
      final parts = timeShift.split(' - ');
      if (parts.length != 2)
        return timeShift; // Return original if format is unexpected

      final startTimeStr = parts[0].trim();
      final endTimeStr = parts[1].trim();

      // Convert each time part
      final formattedStart = _convertTo12Hour(startTimeStr);
      final formattedEnd = _convertTo12Hour(endTimeStr);

      return '$formattedStart - $formattedEnd';
    } catch (e) {
      return timeShift; // Return original if conversion fails
    }
  }

  // Helper method to convert single time from 24-hour to 12-hour format
  String _convertTo12Hour(String time24) {
    try {
      // Handle different formats: "18:00:00" or "18:00"
      DateTime parsedTime;
      if (time24.split(':').length == 3) {
        // Format: "18:00:00"
        parsedTime = DateFormat('HH:mm:ss').parse(time24);
      } else {
        // Format: "18:00"
        parsedTime = DateFormat('HH:mm').parse(time24);
      }

      // Convert to 12-hour format
      return DateFormat('h:mm a').format(parsedTime);
    } catch (e) {
      return time24; // Return original if parsing fails
    }
  }

  factory ScheduledShift.fromJson(Map<String, dynamic> json) => ScheduledShift(
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        scheduleId: json["schedule_id"] ?? 0,
        institution:
            (json["institution"] as String?)?.trim() ?? "Unknown Facility",
        category: json["category"] ?? "Unknown Role",
        workShift: json["work_shift"] ?? "Unknown Shift",
        timeShift: json["time_shift"] ?? "Time not available",
        unitarea: json["unitarea"] ?? "",
        checkInStatus: json["check_in_status"],
        // --- ADDED PARSING LOGIC (handles nulls) ---
        actualCheckIn: json["actual_check_in"] == null
            ? null
            : DateTime.parse(json["actual_check_in"]),
        actualCheckOut: json["actual_check_out"] == null
            ? null
            : DateTime.parse(json["actual_check_out"]),
      );
}
