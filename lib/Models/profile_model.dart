// lib/models/profile_model.dart
import 'dart:convert';

/// Top-level response model with only the fields needed to reach `data`.
class ProfileResponse {
  final Profile data;
  final String? message;
  final int? status;

  ProfileResponse({
    required this.data,
    this.message,
    this.status,
  });

  /// Create from raw JSON string.
  factory ProfileResponse.fromJsonString(String source) =>
      ProfileResponse.fromMap(jsonDecode(source) as Map<String, dynamic>);

  /// Create from already-decoded map.
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

  /// Safe factory using try/catch/finally. Returns null on failure.
  /// Optionally reports the error via [onError].
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
      // no-op: placeholder for cleanup hooks
    }
  }
}

/// Only the fields required by the app: first name, last name, email.
class Profile {
  final String firstName;
  final String lastName;
  final String email;

  const Profile({
    required this.firstName,
    required this.lastName,
    required this.email,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    // Source keys are snake_case in the provided JSON.
    return Profile(
      firstName: (map['first_name'] ?? '').toString(),
      lastName: (map['last_name'] ?? '').toString(),
      email: (map['email'] ?? '').toString(),
    );
  }

  /// Safe builder using try/catch/finally.
  /// Returns an empty-profile on failure to keep call-sites simple.
  static Profile safeFromMap(
    Map<String, dynamic>? map, {
    void Function(Object error)? onError,
  }) {
    try {
      return Profile.fromMap(map ?? const {});
    } catch (e) {
      if (onError != null) onError(e);
      return const Profile(firstName: '', lastName: '', email: '');
    } finally {
      // no-op: placeholder for cleanup hooks
    }
  }

  Map<String, dynamic> toMap() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
      };

  Profile copyWith({
    String? firstName,
    String? lastName,
    String? email,
  }) {
    return Profile(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
    );
  }

  @override
  String toString() =>
      'Profile(firstName: $firstName, lastName: $lastName, email: $email)';
}
