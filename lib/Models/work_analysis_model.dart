import 'dart:convert';

WorkAnalysisWelcome workAnalysisWelcomeFromJson(String str) =>
    WorkAnalysisWelcome.fromJson(json.decode(str));

class WorkAnalysisWelcome {
  Data data;
  String message;
  int status;

  WorkAnalysisWelcome({
    required this.data,
    required this.message,
    required this.status,
  });

  factory WorkAnalysisWelcome.fromJson(Map<String, dynamic> json) =>
      WorkAnalysisWelcome(
        data: Data.fromJson(json["data"] ?? {}),
        message: json["message"] ?? "",
        status: (json["status"] as num?)?.toInt() ?? 0,
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
        schedules: json["schedules"] == null
            ? []
            : List<Schedule>.from(
                json["schedules"].map((x) => Schedule.fromJson(x))),
      );
}

class Cards {
  CardSection schedules;
  CardSection workShift;
  TimeShifts timeShifts;
  EstimatedEarnings estimatedEarnings;
  CardSection mtdSchedules;
  CardSection mtdWorkShift;
  TimeShifts mtdTimeShifts;
  EstimatedEarnings mtdEstimatedEarnings;

  Cards({
    required this.schedules,
    required this.workShift,
    required this.timeShifts,
    required this.estimatedEarnings,
    required this.mtdSchedules,
    required this.mtdWorkShift,
    required this.mtdTimeShifts,
    required this.mtdEstimatedEarnings,
  });

  factory Cards.fromJson(Map<String, dynamic> json) => Cards(
        schedules: CardSection.fromJson(json["schedules"] ?? {}),
        workShift: CardSection.fromJson(json["work_shift"] ?? {}),
        timeShifts: TimeShifts.fromJson(json["time_shifts"] ?? {}),
        estimatedEarnings:
            EstimatedEarnings.fromJson(json["estimated_earnings"] ?? {}),
        mtdSchedules: CardSection.fromJson(json["mtd_schedules"] ?? {}),
        mtdWorkShift: CardSection.fromJson(json["mtd_work_shift"] ?? {}),
        mtdTimeShifts: TimeShifts.fromJson(json["mtd_time_shifts"] ?? {}),
        mtdEstimatedEarnings:
            EstimatedEarnings.fromJson(json["mtd_estimated_earnings"] ?? {}),
      );
}

class CardSection {
  List<CardDataItem> data;
  int total;

  CardSection({
    required this.data,
    required this.total,
  });

  factory CardSection.fromJson(Map<String, dynamic> json) => CardSection(
        data: json["data"] == null
            ? []
            : List<CardDataItem>.from(
                json["data"].map((x) => CardDataItem.fromJson(x))),
        total: (json["total"] as num?)?.toInt() ?? 0,
      );
}

class CardDataItem {
  String name;
  String color;
  int value;

  CardDataItem({
    required this.name,
    required this.color,
    required this.value,
  });

  factory CardDataItem.fromJson(Map<String, dynamic> json) => CardDataItem(
        name: json["name"] ?? "",
        color: json["color"] ?? "",
        value: (json["value"] as num?)?.toInt() ?? 0,
      );
}

class TimeShifts {
  List<CardDataItem> data;
  int total;
  double totalHours;

  TimeShifts({
    required this.data,
    required this.total,
    required this.totalHours,
  });

  factory TimeShifts.fromJson(Map<String, dynamic> json) => TimeShifts(
        data: json["data"] == null
            ? []
            : List<CardDataItem>.from(
                json["data"].map((x) => CardDataItem.fromJson(x))),
        total: (json["total"] as num?)?.toInt() ?? 0,
        totalHours: (json["total_hours"] as num?)?.toDouble() ?? 0.0,
      );
}

class EstimatedEarnings {
  List<EstimatedEarningsDatum> data;
  double total;

  EstimatedEarnings({
    required this.data,
    required this.total,
  });

  factory EstimatedEarnings.fromJson(Map<String, dynamic> json) =>
      EstimatedEarnings(
        data: json["data"] == null
            ? []
            : List<EstimatedEarningsDatum>.from(
                json["data"].map((x) => EstimatedEarningsDatum.fromJson(x))),
        total: (json["total"] as num?)?.toDouble() ?? 0.0,
      );
}

class EstimatedEarningsDatum {
  String name;
  String color;
  double value;
  String currencySymbol;
  String currency;

  EstimatedEarningsDatum({
    required this.name,
    required this.color,
    required this.value,
    required this.currencySymbol,
    required this.currency,
  });

  factory EstimatedEarningsDatum.fromJson(Map<String, dynamic> json) =>
      EstimatedEarningsDatum(
        name: json["name"] ?? "",
        color: json["color"] ?? "",
        value: (json["value"] as num?)?.toDouble() ?? 0.0,
        currencySymbol: json["currency_symbol"] ?? "",
        currency: json["currency"] ?? "",
      );
}

class Schedule {
  DateTime start;
  String timeShift;
  String payHours;
  String institution;
  String category;
  int estimatedPay;

  Schedule({
    required this.start,
    required this.timeShift,
    required this.payHours,
    required this.institution,
    required this.category,
    required this.estimatedPay,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      start: json["start"] != null
          ? DateTime.parse(json["start"])
          : DateTime.now(),
      timeShift: json["time_shift"] ?? "N/A",
      payHours: json["pay_hours"] ?? "0.00",
      institution: json["institution"] ?? "N/A",
      category: json["category"] ?? "N/A",
      estimatedPay: 0,
    );
  }
}
