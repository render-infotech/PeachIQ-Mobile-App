// lib/constants/api_utils.dart
import 'package:peach_iq/Models/scheduled_shifts_model.dart';

const String kStaticClientIp = '27.7.158.252';

class ApiUrls {
  // Updated base URL with the correct AWS API Gateway URL
  static const String baseUrl =
      "https://hpl56ugq69.execute-api.ca-central-1.amazonaws.com/dev/v1";

  // Auth endpoints
  static String login() => '$baseUrl/users/login';
  // static String register() => '$baseUrl/users/register';

  // Profile endpoint
  static String myProfile() => '$baseUrl/users/my-profile';

  // availableshifts endpoint
  static String availableShifts() =>
      '$baseUrl/caregiver-dashboard/requested-schedules-by-client';
  // scheduledshifts endpoint
  static String scheduledShift() =>
      '$baseUrl/caregiver-dashboard/schedulings?month=5&year=2025';

  // workanalysis endpoint
  static String workanAlysis() => '$baseUrl/caregiver-dashboard/';

  // respond to shift(interested/not interested)
  static String respondToShift() =>
      '$baseUrl/caregiver-dashboard/requested-schedule-caregiver-decision';
  // forgot password
  static String forgotPassword() => '$baseUrl/users/forgot-password';

  static void debugUrls() {
    print('Base URL: $baseUrl');
    print('Login URL: ${login()}');
    print('Profile URL: ${myProfile()}');
  }
}
