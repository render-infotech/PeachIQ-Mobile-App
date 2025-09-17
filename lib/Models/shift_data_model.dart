class ShiftData {
  final int schedulingId;
  final String facility;
  final String floorWing;
  final String dateLine;
  final String time;
  final DateTime dateTime;
  final String shiftTime;

  final DateTime? actualCheckIn;
  final DateTime? actualCheckOut;

  ShiftData({
    required this.schedulingId,
    required this.facility,
    required this.floorWing,
    required this.dateLine,
    required this.time,
    required this.dateTime,
    required this.shiftTime,
    this.actualCheckIn,
    this.actualCheckOut,
  });
}
