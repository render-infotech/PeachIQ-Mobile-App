import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

DateTime _parseCombinedDateTime(String? dateStr, String? timeStr) {
  if (dateStr == null ||
      dateStr.isEmpty ||
      timeStr == null ||
      timeStr.isEmpty) {
    return DateTime.now();
  }
  try {
    return DateTime.parse('$dateStr $timeStr');
  } catch (e) {
    print('Failed to parse combined DateTime: $e');
    return DateTime.now();
  }
}

int _parseToInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) {
    if (value.isEmpty) return 0;
    try {
      return int.parse(value);
    } catch (e) {
      try {
        return double.parse(value).toInt();
      } catch (e2) {
        return 0;
      }
    }
  }
  return 0;
}

DateTime _parseDateTime(dynamic value) {
  if (value == null || value.toString().isEmpty) return DateTime.now();
  try {
    return DateTime.parse(value.toString());
  } catch (e) {
    return DateTime.now();
  }
}

List<dynamic> _parseCustomDays(dynamic value) {
  if (value == null) return [];
  if (value is List) return List<dynamic>.from(value);
  return [];
}

class Welcome {
  Data data;
  String message;
  int status;

  Welcome({
    required this.data,
    required this.message,
    required this.status,
  });

  factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        data: Data.fromJson(json["data"] ?? {}),
        message: json["message"] ?? "Success",
        status: json["status"] ?? 200,
      );
}

class Data {
  Cards cards;
  List<Schedule> schedules;

  Data({
    required this.cards,
    required this.schedules,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        cards: Cards.fromJson(json["cards"] ?? {}),
        schedules: json["schedules"] != null
            ? List<Schedule>.from(
                json["schedules"].map((x) => Schedule.fromJson(x)))
            : <Schedule>[],
      );
}

class Cards {
  Schedules schedules;
  Schedules workShift;
  Schedules timeShifts;
  EstimatedEarnings estimatedEarnings;

  Cards({
    required this.schedules,
    required this.workShift,
    required this.timeShifts,
    required this.estimatedEarnings,
  });

  factory Cards.fromJson(Map<String, dynamic> json) => Cards(
        schedules: Schedules.fromJson(json["schedules"] ?? {}),
        workShift: Schedules.fromJson(json["work_shift"] ?? {}),
        timeShifts: Schedules.fromJson(json["time_shifts"] ?? {}),
        estimatedEarnings:
            EstimatedEarnings.fromJson(json["estimated_earnings"] ?? {}),
      );
}

class EstimatedEarnings {
  List<dynamic> data;
  int total;

  EstimatedEarnings({
    required this.data,
    required this.total,
  });

  factory EstimatedEarnings.fromJson(Map<String, dynamic> json) =>
      EstimatedEarnings(
        data: json["data"] != null
            ? List<dynamic>.from(json["data"].map((x) => x))
            : [],
        total: _parseToInt(json["total"]),
      );
}

class Schedules {
  List<dynamic> data;
  int total;

  Schedules({
    required this.data,
    required this.total,
  });

  factory Schedules.fromJson(Map<String, dynamic> json) => Schedules(
        data: json["data"] != null
            ? List<dynamic>.from(json["data"].map((x) => x))
            : [],
        total: _parseToInt(json["total"]),
      );
}

class Schedule {
  DateTime start;
  DateTime end;
  int scheduleId;
  int? notifyId;
  dynamic batchId;
  String category;
  int categoryId;
  String timeShift;
  String workShift;
  int workShiftId;
  int? caregiverId;
  String? caregiver;
  int? isCustomTimeShift;
  DateTime schedulingStartDate;
  DateTime schedulingEndDate;
  String customStartTime;
  String customEndTime;
  int? timeShiftId;
  String? payHours;
  String? invoiceHours;
  String jobCategoryColor;
  String? description;
  String institution;
  String? currencySymbol;
  String? currency;
  int institutionId;
  dynamic companyFare;
  dynamic clientFare;
  dynamic miscDescription;
  String schedulingType;
  int schedulingTypeId;
  List<dynamic> schedulingCustomDays;
  String? residentName;
  int? residentIsActive;
  int? residentId;
  int? isResidentRequired;
  int? isCustomResident;
  int? unitareaId;
  String? unitarea;
  String? unitareaDescription;

  Schedule({
    required this.start,
    required this.end,
    required this.scheduleId,
    this.notifyId,
    this.batchId,
    required this.category,
    required this.categoryId,
    required this.timeShift,
    required this.workShift,
    required this.workShiftId,
    this.caregiverId,
    this.caregiver,
    this.isCustomTimeShift,
    required this.schedulingStartDate,
    required this.schedulingEndDate,
    required this.customStartTime,
    required this.customEndTime,
    this.timeShiftId,
    this.payHours,
    this.invoiceHours,
    required this.jobCategoryColor,
    this.description,
    required this.institution,
    this.currencySymbol,
    this.currency,
    required this.institutionId,
    this.companyFare,
    this.clientFare,
    this.miscDescription,
    required this.schedulingType,
    required this.schedulingTypeId,
    required this.schedulingCustomDays,
    this.residentName,
    this.residentIsActive,
    this.residentId,
    this.isResidentRequired,
    this.isCustomResident,
    this.unitareaId,
    this.unitarea,
    this.unitareaDescription,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    try {
      return Schedule(
        start: _parseCombinedDateTime(
            json["start_date"], json["custom_start_time"]),
        end: _parseCombinedDateTime(json["end_date"], json["custom_end_time"]),
        scheduleId: _parseToInt(json["id"]),
        notifyId: _parseToInt(json["notify_id"]),
        institution: json["display_institution_name"]?.toString().trim() ?? "",
        category: json["category"]?["job_category"]?.toString() ?? "",
        unitarea: json["unitarea"]?["unitarea_name"]?.toString(),
        workShift: json["display_workshift"]?.toString() ?? "",
        timeShift: json["display_timeshift"]?.toString() ?? "",
        batchId: json["batch"],
        categoryId: _parseToInt(json["category_id"]),
        workShiftId: _parseToInt(json["work_shift_id"]),
        caregiverId: null,
        caregiver: null,
        isCustomTimeShift: null,
        schedulingStartDate: _parseDateTime(json["start_date"]),
        schedulingEndDate: _parseDateTime(json["end_date"]),
        customStartTime: json["custom_start_time"]?.toString() ?? "",
        customEndTime: json["custom_end_time"]?.toString() ?? "",
        timeShiftId: _parseToInt(json["time_shift_id"]),
        payHours: null,
        invoiceHours: null,
        jobCategoryColor:
            json["category"]?["color_code"]?.toString() ?? "#000000",
        description: json["description"]?.toString(),
        currencySymbol: null,
        currency: null,
        institutionId: _parseToInt(json["institution_id"]),
        companyFare: null,
        clientFare: null,
        miscDescription: null,
        schedulingType: json["scheduling_type"]?.toString() ?? "",
        schedulingTypeId: _parseToInt(json["scheduling_type_id"]),
        schedulingCustomDays: _parseCustomDays(json["scheduling_custom_days"]),
        residentName: json["resident_name"]?.toString(),
        residentIsActive: null,
        residentId: _parseToInt(json["resident_id"]),
        isResidentRequired: null,
        isCustomResident: null,
        unitareaId: _parseToInt(json["unitarea_id"]),
        unitareaDescription: json["unitarea"]?["description"]?.toString(),
      );
    } catch (e) {
      print('Error parsing Schedule from JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}
