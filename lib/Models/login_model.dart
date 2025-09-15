// login_model.dart
import 'dart:convert';

/// Root model for the login response
class LoginResponse {
  final LoginData data;
  final String message;
  final int status;

  const LoginResponse({
    required this.data,
    required this.message,
    required this.status,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      data: LoginData.fromJson(json['data'] as Map<String, dynamic>),
      message: (json['message'] ?? '').toString(),
      status: (json['status'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'data': data.toJson(),
        'message': message,
        'status': status,
      };
}

/// Payload under "data"
class LoginData {
  final User user;
  final String token;
  // JWT
  /// expiresIn in days (per your example: 365)
  final int expiresIn;

  const LoginData({
    required this.user,
    required this.token,
    required this.expiresIn,
  });

  factory LoginData.fromJson(Map<String, dynamic> json) {
    return LoginData(
      user: User.fromJson(json['user'] as Map<String, dynamic>),
      token: (json['token'] ?? '').toString(),
      expiresIn: (json['expiresIn'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user.toJson(),
        'token': token,
        'expiresIn': expiresIn,
      };

  /// Decode the JWT payload (unsafe decode, no signature verification).
  Map<String, dynamic>? get decodedJwt {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      final normalized = base64.normalize(parts[1]);
      final payload = utf8.decode(base64Url.decode(normalized));
      return json.decode(payload) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// Expiration from JWT `exp` (seconds since epoch), if present.
  DateTime? get jwtExpiry {
    final payload = decodedJwt;
    if (payload == null) return null;
    final exp = payload['exp'];
    if (exp is int) {
      return DateTime.fromMillisecondsSinceEpoch(
        exp * 1000,
        isUtc: true,
      ).toLocal();
    }
    return null;
  }

  /// Convenience: is the token currently expired (based on JWT exp)?
  bool get isExpired {
    final e = jwtExpiry;
    if (e == null) return false; // if exp absent, treat as not expired
    return DateTime.now().isAfter(e);
  }
}

/// User object inside "data.user"
class User {
  final String firstName;
  final String lastName;
  final String email;
  final int roleId;

  const User({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      firstName: (json['first_name'] ?? '').toString(),
      lastName: (json['last_name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      roleId: (json['role_id'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'role_id': roleId,
      };

  String get fullName => '$firstName $lastName';
}
