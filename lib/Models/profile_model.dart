// lib/models/profile_model.dart
import 'dart:convert';

// --- ProfileResponse class is unchanged and correct ---
class ProfileResponse {
  final Profile data;
  final String? message;
  final int? status;

  ProfileResponse({
    required this.data,
    this.message,
    this.status,
  });

  factory ProfileResponse.fromJsonString(String source) =>
      ProfileResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);

  factory ProfileResponse.fromMap(Map<String, dynamic> map) {
    final dataMap = map['data'] as Map<String, dynamic>? ?? const {};
    return ProfileResponse(
      data: Profile.fromMap(dataMap),
      message: map['message'] as String?,
      status: map['status'] is num ? (map['status'] as num).toInt() : null,
    );
  }

  Map<String, dynamic> toMap() => {
        'data': data.toMap(),
        if (message != null) 'message': message,
        if (status != null) 'status': status,
      };

  String toJsonString() => jsonEncode(toMap());

  static ProfileResponse? safeFromJsonString(
    String source, {
    void Function(Object error)? onError,
  }) {
    try {
      return ProfileResponse.fromJsonString(source);
    } catch (e) {
      if (onError != null) onError(e);
      return null;
    } finally {
      // no-op
    }
  }
}

// --- UPDATED Profile class ---
class Profile {
  final int id; // <-- ADDED
  final String firstName;
  final String lastName;
  final String email;
  final String dashboard; // <-- ADDED

  const Profile({
    required this.id, // <-- ADDED
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.dashboard, // <-- ADDED
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      // Safely parse 'id' from num to int
      id: (map['id'] as num? ?? 0).toInt(), // <-- ADDED
      firstName: (map['first_name'] ?? '').toString(),
      lastName: (map['last_name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
      dashboard: (map['dashboard'] ?? '').toString(), // <-- ADDED
    );
  }

  static Profile safeFromMap(
    Map<String, dynamic>? map, {
    void Function(Object error)? onError,
  }) {
    try {
      return Profile.fromMap(map ?? const {});
    } catch (e) {
      if (onError != null) onError(e);
      // Return with default values for new fields
      return const Profile(
        id: 0, // <-- ADDED
        firstName: '',
        lastName: '',
        email: '',
        dashboard: '', // <-- ADDED
      );
    } finally {
      // no-op
    }
  }

  Map<String, dynamic> toMap() => {
        'id': id, // <-- ADDED
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'dashboard': dashboard, // <-- ADDED
      };

  Profile copyWith({
    int? id, // <-- ADDED
    String? firstName,
    String? lastName,
    String? email,
    String? dashboard, // <-- ADDED
  }) {
    return Profile(
      id: id ?? this.id, // <-- ADDED
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      dashboard: dashboard ?? this.dashboard, // <-- ADDED
    );
  }

  @override
  String toString() =>
      'Profile(id: $id, firstName: $firstName, lastName: $lastName, email: $email, dashboard: $dashboard)'; // <-- UPDATED
}