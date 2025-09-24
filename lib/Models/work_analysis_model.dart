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

  Cards({
    required this.schedules,
    required this.workShift,
    required this.timeShifts,
    required this.estimatedEarnings,
  });

  factory Cards.fromJson(Map<String, dynamic> json) => Cards(
        schedules: CardSection.fromJson(json["schedules"] ?? {}),
        workShift: CardSection.fromJson(json["work_shift"] ?? {}),
        timeShifts: CardSection.fromJson(json["time_shifts"] ?? {}),
        estimatedEarnings:
            EstimatedEarnings.fromJson(json["estimated_earnings"] ?? {}),
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
  int total;

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
        total: (json["total"] as num?)?.toInt() ?? 0,
      );
}

class EstimatedEarningsDatum {
  String name;
  String color;
  int value;
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
        value: (json["value"] as num?)?.toInt() ?? 0,
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
    final fallbackDate = DateTime.fromMillisecondsSinceEpoch(0);

    final dateString = json['schedule_start_from_api'];

    final payValue = json['estimated_pay_from_api'];

    return Schedule(
      payHours: json["pay_hours"] ?? "0.00",
      scheduleStart:
          dateString != null ? DateTime.parse(dateString) : fallbackDate,
      estimatedPay: (payValue as num?)?.toInt() ?? 0,
    );
  }
}
