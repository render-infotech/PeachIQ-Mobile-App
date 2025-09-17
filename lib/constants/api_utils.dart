import 'package:peach_iq/Models/scheduled_shifts_model.dart';

const String kStaticClientIp = '27.7.158.252';

class ApiUrls {
  static const String baseUrl =
      "https://hpl56ugq69.execute-api.ca-central-1.amazonaws.com/dev/v1";

  // auth
  static String login() => '$baseUrl/users/login';

  // Profile endpoint
  static String myProfile() => '$baseUrl/users/my-profile';

  // available shifts endpoint
  static String availableShifts() =>
      '$baseUrl/caregiver-dashboard/requested-schedules-by-client';

  // scheduled shifts endpoint
  static String scheduledShift({required int month, required int year}) =>
      '$baseUrl/caregiver-dashboard/schedulings?month=$month&year=$year';

  // work analysis endpoint
  static String workanAlysis() => '$baseUrl/caregiver-dashboard/';

  // respond to shift(interested/not interested)
  static String respondToShift() =>
      '$baseUrl/caregiver-dashboard/requested-schedule-caregiver-decision';

  // forgot password
  static String forgotPassword() => '$baseUrl/users/forgot-password';

  // check In
  static String checkIn() => '$baseUrl/caregiver-dashboard/schedule/check-in';

  //Check Out
  static String checkOut() => '$baseUrl/caregiver-dashboard/schedule/check-out';

  // Location
  static String Locations() =>
      '$baseUrl/caregiver-dashboard/mapped-institutions';

  static void debugUrls() {
    print('Base URL: $baseUrl');
    print('Login URL: ${login()}');
    print('Profile URL: ${myProfile()}');
  }
}
