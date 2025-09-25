// lib/Models/work_analysis_model.dart

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
  CardSection timeShifts;
  EstimatedEarnings estimatedEarnings;
  // <<< 1. ADD NEW MTD PROPERTIES
  CardSection mtdSchedules;
  CardSection mtdWorkShift;
  CardSection mtdTimeShifts;
  EstimatedEarnings mtdEstimatedEarnings;

  Cards({
    required this.schedules,
    required this.workShift,
    required this.timeShifts,
    required this.estimatedEarnings,
    // <<< 2. INITIALIZE NEW PROPERTIES
    required this.mtdSchedules,
    required this.mtdWorkShift,
    required this.mtdTimeShifts,
    required this.mtdEstimatedEarnings,
  });

  factory Cards.fromJson(Map<String, dynamic> json) => Cards(
        schedules: CardSection.fromJson(json["schedules"] ?? {}),
        workShift: CardSection.fromJson(json["work_shift"] ?? {}),
        timeShifts: CardSection.fromJson(json["time_shifts"] ?? {}),
        estimatedEarnings:
            EstimatedEarnings.fromJson(json["estimated_earnings"] ?? {}),
        // <<< 3. PARSE NEW MTD JSON KEYS
        mtdSchedules: CardSection.fromJson(json["mtd_schedules"] ?? {}),
        mtdWorkShift: CardSection.fromJson(json["mtd_work_shift"] ?? {}),
        mtdTimeShifts: CardSection.fromJson(json["mtd_time_shifts"] ?? {}),
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

class EstimatedEarnings {
  List<EstimatedEarningsDatum> data;
  double total; // <<< 4. CHANGE total FROM int TO double

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
        // <<< 5. PARSE total AS A double
        total: (json["total"] as num?)?.toDouble() ?? 0.0,
      );
}

class EstimatedEarningsDatum {
  String name;
  String color;
  double value; // <<< 6. CHANGE value FROM int TO double
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
        // <<< 7. PARSE value AS A double
        value: (json["value"] as num?)?.toDouble() ?? 0.0,
        currencySymbol: json["currency_symbol"] ?? "",
        currency: json["currency"] ?? "",
      );
}

class Schedule {
  String payHours;
  DateTime scheduleStart;
  int estimatedPay;

  Schedule({
    required this.payHours,
    required this.scheduleStart,
    required this.estimatedPay,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    // This logic seems disconnected from the new JSON but is kept as is.
    final fallbackDate = DateTime.fromMillisecondsSinceEpoch(0);
    final dateString = json['start'];
    final payValue = json['estimated_pay_from_api'];

    return Schedule(
      payHours: json["pay_hours"] ?? "0.00",
      scheduleStart:
          dateString != null ? DateTime.parse(dateString) : fallbackDate,
      estimatedPay: (payValue as num?)?.toInt() ?? 0,
    );
  }
}
