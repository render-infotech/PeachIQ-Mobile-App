import 'package:flutter/material.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
import 'package:peach_iq/Providers/calender_provider.dart';
import 'package:peach_iq/Providers/chekinout_provider.dart';
import 'package:peach_iq/Providers/content_page_provider.dart';
import 'package:peach_iq/Providers/document_provider.dart';
import 'package:peach_iq/Providers/forgot_password_provider.dart';
import 'package:peach_iq/Providers/get_address_details_provider.dart';
import 'package:peach_iq/Providers/location_provider.dart';
import 'package:peach_iq/Providers/notifications_provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/Providers/profile_update_provider.dart';
import 'package:peach_iq/Providers/response_provider.dart';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';
import 'package:peach_iq/Providers/work_analysis_provider.dart';
import 'package:peach_iq/constants/loading/loading_provider.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/login_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/shared/themes/typography.dart';
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
        ChangeNotifierProvider(create: (_) => ProfileUpdateProvider()),
        ChangeNotifierProvider(create: (_) => ContentPageProvider()),
        ChangeNotifierProvider(create: (_) => DocumentProvider()),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: MaterialApp(
        title: 'Peach iQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'NunitoSans', // Set Nunito Sans as default font
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.primaryDark,
            surface: AppColors.background,
            background: AppColors.background,
            onPrimary: AppColors.white,
            onSecondary: AppColors.white,
            onSurface: AppColors.textPrimary,
            onBackground: AppColors.textPrimary,
          ),
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
            titleTextStyle: AppTypography.h5.copyWith(color: AppColors.white),
            elevation: 0,
          ),
          textTheme: TextTheme(
            // Headings
            displayLarge: AppTypography.h1,
            displayMedium: AppTypography.h2,
            displaySmall: AppTypography.h3,
            headlineLarge: AppTypography.h3,
            headlineMedium: AppTypography.h4,
            headlineSmall: AppTypography.h5,
            titleLarge: AppTypography.h4,
            titleMedium: AppTypography.h5,
            titleSmall: AppTypography.h6,
            // Body text
            bodyLarge: AppTypography.bodyLarge,
            bodyMedium: AppTypography.bodyMedium,
            bodySmall: AppTypography.bodySmall,
            // Labels
            labelLarge: AppTypography.labelLarge,
            labelMedium: AppTypography.labelMedium,
            labelSmall: AppTypography.labelSmall,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              textStyle: AppTypography.buttonMedium.copyWith(
                fontFamily: 'NunitoSans', // Override to use Nunito Sans for buttons
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: AppTypography.labelLarge.copyWith(
                color: AppColors.primary,
                fontFamily: 'NunitoSans',
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            labelStyle: AppTypography.labelMedium,
            hintStyle: AppTypography.bodyMedium.copyWith(color: AppColors.textLight),
          ),
        ),
        themeMode: ThemeMode.system,
        initialRoute: '/splash',
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}
