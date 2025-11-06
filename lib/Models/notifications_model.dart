class NotificationListModel {
  final List<NotificationModel> notifications;

  NotificationListModel({required this.notifications});

  factory NotificationListModel.fromJson(Map<String, dynamic> json) {
    // Correctly targets the 'data' key from your JSON
    final List<dynamic> data = json['data'] ?? []; 
    
    return NotificationListModel(
      notifications: data.map((item) => NotificationModel.fromJson(item)).toList(),
    );
  }
}

class NotificationModel {
  final int id;
  final int caregiverId;
  final String title;
  final String message;
  final bool isRead;
  final String? readAt;
  final DateTime timestamp; // Parsed from 'created_at'

  NotificationModel({
    required this.id,
    required this.caregiverId,
    required this.title,
    required this.message,
    required this.isRead,
    this.readAt,
    required this.timestamp,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? 0,
      caregiverId: json['caregiver_id'] ?? 0,
      title: json['title'] ?? 'No Title',
      message: json['message'] ?? 'No Message',
      isRead: (json['is_read'] ?? 0) == 1,
      readAt: json['read_at'],
      timestamp: json['created_at'] != null 
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  // --- THIS IS THE FIX ---
  // --- ADD THIS METHOD TO YOUR MODEL FILE ---
  /// Creates a copy of this object with updated fields.
  NotificationModel copyWith({
    int? id,
    int? caregiverId,
    String? title,
    String? message,
    bool? isRead,
    String? readAt,
    DateTime? timestamp,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      caregiverId: caregiverId ?? this.caregiverId,
      title: title ?? this.title,
      message: message ?? this.message,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}