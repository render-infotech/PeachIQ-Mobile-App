import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/constants/loading/loading_provider.dart';
import 'package:peach_iq/constants/loading/shimmer_gate.dart';
import 'package:peach_iq/models/shift_data_model.dart';
import 'package:peach_iq/screens/Notifications/inbox_screen.dart';
import 'package:peach_iq/screens/auth/change_password_page.dart';
import 'package:peach_iq/screens/auth/forgot_password_page.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/screens/home/available_shifts_page.dart';
import 'package:peach_iq/screens/home/homeScreen.dart';
import 'package:peach_iq/screens/home/scheduled_shifts_page.dart';
import 'package:peach_iq/screens/profile/edit_profile/document_upload_page.dart';
import 'package:peach_iq/screens/profile/edit_profile/edit_profile_sccreen.dart';
import 'package:peach_iq/screens/profile/settings/about_screen.dart';
import 'package:peach_iq/screens/profile/settings/privacy_policy_screen.dart';
import 'package:peach_iq/screens/profile/settings/settings_screen.dart';
import 'package:peach_iq/screens/profile/settings/terms_and_conditions_screen.dart';
import 'package:peach_iq/screens/schedule/calender_widget.dart';
import 'package:peach_iq/screens/schedule/schedule_page.dart';
import 'package:peach_iq/screens/chech_in/todays_shifts_screen.dart';
import 'package:peach_iq/screens/chech_in/check_in_screen.dart';
import 'package:peach_iq/widgets/bottom_nav.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/splash.dart';
import 'package:provider/provider.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String login = '/login';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String inbox = '/inbox';
  static const String profile = '/profile';
  static const String schedule = '/schedule';
  static const String checkin = '/checkin';
  static const String scheduledShifts = '/scheduled-shifts';
  static const String availableShifts = '/available-shifts';
  static const String calendar = '/calendar';
  static const String generalSettings = '/general-settings';
  static const String todaysShifts = '/todays-shifts';
  static const String checkIn = '/check-in';
  static const String changePassword = '/change-password';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy-policy';
  static const String termsAndConditions = '/terms-and-conditions';
  static const String documentUpload = '/document-upload';
}

class AppShell extends StatefulWidget {
  final int initialIndex;
  final Widget? child;
  const AppShell({super.key, this.initialIndex = 0, this.child});
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _currentIndex;
  static const _indexToRoute = <int, String>{
    0: AppRoutes.home,
    1: AppRoutes.checkin,
    2: AppRoutes.schedule,
    3: AppRoutes.inbox,
    4: AppRoutes.profile,
  };
  final List<Widget> _pages = const [
    HomeScreen(),
    TodaysShiftsScreen(),
    SchedulePage(),
    InboxScreen(),
    SettingsScreen(),
  ];
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onBottomNavTap(int index) {
    if (_currentIndex == index && widget.child == null) return;
    final loadingProvider =
        Provider.of<LoadingProvider>(context, listen: false);
    loadingProvider.setLoading(true);
    Future.delayed(const Duration(milliseconds: 20), () {
      if (mounted) {
        final route = _indexToRoute[index]!;
        Navigator.pushReplacementNamed(context, route);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoadingProvider>(
      builder: (context, loadingProvider, child) {
        return ShimmerGate(
          isLoading: loadingProvider.isLoading,
          child: Scaffold(
            body: widget.child ??
                IndexedStack(index: _currentIndex, children: _pages),
            bottomNavigationBar: AppBottomNav(
              currentIndex: _currentIndex,
              onTap: _onBottomNavTap,
              selectedItemColor: Colors.white,
              unselectedItemColor: Colors.white,
              backgroundColor: AppColors.primary,
            ),
          ),
        );
      },
    );
  }
}

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
        );
      case AppRoutes.forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
        );
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 0),
        );
      case AppRoutes.checkin:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 1),
        );
      case AppRoutes.todaysShifts:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 1, child: TodaysShiftsScreen()),
        );
      case AppRoutes.checkIn:
        final shift = settings.arguments;
        if (shift == null || shift is! ShiftData) {
          return MaterialPageRoute(
            builder: (_) => const AppShell(initialIndex: 1),
          );
        }
        return MaterialPageRoute(
          builder: (_) =>
              AppShell(initialIndex: 1, child: CheckInScreen(shift: shift)),
        );
      case AppRoutes.schedule:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 2),
        );
      case AppRoutes.inbox:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 3),
        );
      case AppRoutes.profile:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 4),
        );
      case AppRoutes.scheduledShifts:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 0, child: ScheduledShifts()),
        );
      case AppRoutes.availableShifts:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 0, child: AvailableShifts()),
        );
      case AppRoutes.calendar:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 2, child: CalenderWidget()),
        );
      case AppRoutes.generalSettings:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 4, child: ProfileScreen()),
        );
      case AppRoutes.changePassword:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 4, child: ChangePasswordScreen()),
        );
      case AppRoutes.about:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 4, child: AboutScreen()),
        );
      case AppRoutes.privacyPolicy:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 4, child: PrivacyPolicyScreen()),
        );
      case AppRoutes.termsAndConditions:
        return MaterialPageRoute(
          builder: (_) => const AppShell(
              initialIndex: 4, child: TermsAndConditionsScreen()),
        );
      case AppRoutes.documentUpload:
        return MaterialPageRoute(
          builder: (_) =>
              const AppShell(initialIndex: 4, child: DocumentUploadScreen()),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const AppShell(initialIndex: 0),
        );
    }
  }
}

class AppNavigator {
  static Future<void> pushNamed(BuildContext context, String routeName,
      {Object? arguments}) {
    return Navigator.pushNamed(context, routeName, arguments: arguments);
  }

  static Future<void> pushReplacementNamed(
    BuildContext context,
    String routeName,
  ) {
    return Navigator.pushReplacementNamed(context, routeName);
  }

  static void pop(BuildContext context) {
    Navigator.pop(context);
  }

  static Future<void> toForgotPassword(BuildContext context) {
    return pushNamed(context, AppRoutes.forgotPassword);
  }

  static Future<void> toScheduledShifts(BuildContext context) {
    return pushNamed(context, AppRoutes.scheduledShifts);
  }

  static Future<void> toAvailableShifts(BuildContext context) {
    return pushNamed(context, AppRoutes.availableShifts);
  }

  static Future<void> toCalendar(BuildContext context) {
    return pushNamed(context, AppRoutes.calendar);
  }

  static Future<void> toGeneralSettings(BuildContext context) {
    return pushNamed(context, AppRoutes.generalSettings);
  }

  static Future<void> toTodaysShifts(BuildContext context) {
    return pushNamed(context, AppRoutes.todaysShifts);
  }

  static Future<void> toCheckIn(BuildContext context, ShiftData shift) {
    return pushNamed(context, AppRoutes.checkIn, arguments: shift);
  }

  static Future<void> toChangePassword(BuildContext context) {
    return pushNamed(context, AppRoutes.changePassword);
  }

  static Future<void> toAbout(BuildContext context) {
    return pushNamed(context, AppRoutes.about);
  }

  static Future<void> toPrivacyPolicy(BuildContext context) {
    return pushNamed(context, AppRoutes.privacyPolicy);
  }

  static Future<void> toTermsAndConditions(BuildContext context) {
    return pushNamed(context, AppRoutes.termsAndConditions);
  }

  // Add new navigation helper
  static Future<void> toDocumentUpload(BuildContext context) {
    return pushNamed(context, AppRoutes.documentUpload);
  }
}
