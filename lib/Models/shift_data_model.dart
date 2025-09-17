class ShiftData {
  final int schedulingId;
  final String facility;
  final String floorWing;
  final String dateLine;
  final String time;
  final DateTime dateTime;
  final String shiftTime;
  final int checkInStatus;
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
    required this.checkInStatus,
    this.actualCheckIn,
    this.actualCheckOut,
  });

  ShiftData copyWith({
    int? schedulingId,
    String? facility,
    String? floorWing,
    String? dateLine,
    String? time,
    DateTime? dateTime,
    String? shiftTime,
    int? checkInStatus,
    DateTime? actualCheckIn,
    DateTime? actualCheckOut,
  }) {
    return ShiftData(
      schedulingId: schedulingId ?? this.schedulingId,
      facility: facility ?? this.facility,
      floorWing: floorWing ?? this.floorWing,
      dateLine: dateLine ?? this.dateLine,
      time: time ?? this.time,
      dateTime: dateTime ?? this.dateTime,
      shiftTime: shiftTime ?? this.shiftTime,
      checkInStatus: checkInStatus ?? this.checkInStatus,
      actualCheckIn: actualCheckIn ?? this.actualCheckIn,
      actualCheckOut: actualCheckOut ?? this.actualCheckOut,
    );
  }
}
