class CheckInOutRequest {
  final int schedulingId;
  final String latitude;
  final String longitude;

  CheckInOutRequest({
    required this.schedulingId,
    required this.latitude,
    required this.longitude,
  });

  Map<String, dynamic> toJson() => {
        'scheduling_id': schedulingId,
        'latitude': latitude,
        'longitude': longitude,
      };
}
