// lib/main.dart
import 'package:flutter/material.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
import 'package:peach_iq/Providers/calender_provider.dart';
import 'package:peach_iq/Providers/chekinout_provider.dart';
import 'package:peach_iq/Providers/forgot_password_provider.dart';
import 'package:peach_iq/Providers/location_provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/Providers/response_provider.dart';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';
import 'package:peach_iq/Providers/work_analysis_provider.dart';
import 'package:peach_iq/constants/loading/loading_provider.dart';
import 'package:peach_iq/splash.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/login_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // LOADER PROVIDER HERE
        ChangeNotifierProvider(create: (_) => LoadingProvider()),
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => AvailableShiftsProvider()),
        ChangeNotifierProvider(create: (_) => SchedulesShiftsProvider()),
        ChangeNotifierProvider(create: (_) => WorkAnalysisProvider()),
        ChangeNotifierProvider(create: (_) => ShiftResponseProvider()),
        ChangeNotifierProvider(create: (_) => ForgotPasswordProvider()),
        ChangeNotifierProvider(create: (_) => CheckInCheckOutProvider()),
        ChangeNotifierProvider(create: (_) => CalenderProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: MaterialApp(
        title: 'Peach iQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          fontFamily: 'Manrope',
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFFFFFFFF),
          fontFamily: 'Manrope',
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
