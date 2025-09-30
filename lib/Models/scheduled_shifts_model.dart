import 'dart:convert';

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
    required this.unitarea,
    this.checkInStatus,
    // --- ADDED TO CONSTRUCTOR ---
    this.actualCheckIn,
    this.actualCheckOut,
  });

  factory ScheduledShift.fromJson(Map<String, dynamic> json) => ScheduledShift(
        start: DateTime.parse(json["start"]),
        end: DateTime.parse(json["end"]),
        scheduleId: json["schedule_id"] ?? 0,
        institution:
            (json["institution"] as String?)?.trim() ?? "Unknown Facility",
        category: json["category"] ?? "Unknown Role",
        workShift: json["work_shift"] ?? "Unknown Shift",
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
