// lib/models/shift_data_model.dart

class ShiftData {
  final String facility;
  final String floorWing;
  final String dateLine;
  final String time;
  final DateTime dateTime;
  final String shiftTime;

  ShiftData({
    required this.facility,
    required this.floorWing,
    required this.dateLine,
    required this.time,
    required this.dateTime,
    required this.shiftTime,
  });
}