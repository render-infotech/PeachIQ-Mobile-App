import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/Models/available_shifts_model.dart';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';
import 'package:peach_iq/constants/loading/loading_provider.dart';
import 'package:peach_iq/routes.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/screens/home/available_shift_card.dart';
import 'package:peach_iq/screens/home/schedule_tile_widget.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
import 'package:peach_iq/Providers/work_analysis_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/text_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final AvailableShiftsProvider _availableShiftsProvider;
  late final SchedulesShiftsProvider _scheduledShiftsProvider;

  @override
  void initState() {
    super.initState();

    _availableShiftsProvider =
        Provider.of<AvailableShiftsProvider>(context, listen: false);
    _scheduledShiftsProvider =
        Provider.of<SchedulesShiftsProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationAndFetchData();

      _availableShiftsProvider.startAutoRefresh();
      _scheduledShiftsProvider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    _availableShiftsProvider.stopAutoRefresh();
    _scheduledShiftsProvider.stopAutoRefresh();

    super.dispose();
  }

  Future<void> _checkAuthenticationAndFetchData() async {
    final loadingProvider =
        Provider.of<LoadingProvider>(context, listen: false);
    try {
      loadingProvider.setLoading(true);

      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final workAnalysisProvider =
          Provider.of<WorkAnalysisProvider>(context, listen: false);

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('access_token');

      if (token == null || token.isEmpty) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
        return;
      }

      await Future.wait([
        profileProvider.fetchMyProfile(),
        _availableShiftsProvider.fetchAvailableShifts(),
        _scheduledShiftsProvider.fetchScheduledShifts(),
        workAnalysisProvider.fetchWorkAnalysis(),
      ]);
    } catch (e) {
      debugPrint('Error in _checkAuthenticationAndFetchData: $e');
      if (e.toString().contains('401') ||
          e.toString().toLowerCase().contains('authentication')) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } finally {
      if (mounted) {
        loadingProvider.setLoading(false);
      }
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('MMMM d, yyyy').format(date);
  }

  String _buildTimeLine(dynamic schedule) {
    try {
      // Use the formatted 12-hour time
      return schedule.formattedTimeShift ?? 'Time information unavailable';
    } catch (e) {
      return 'Time information unavailable';
    }
  }

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text(
          'Sign Out',
          style: TextStyle(color: AppColors.black),
        ),
        content: const Text(
          'Are you sure you want to sign out?',
          style: TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
          TextButton(
            onPressed: () async {
              try {
                final profileProvider =
                    Provider.of<ProfileProvider>(context, listen: false);
                final workAnalysisProvider =
                    Provider.of<WorkAnalysisProvider>(context, listen: false);

                await profileProvider.logout();
                _availableShiftsProvider.clear();
                _scheduledShiftsProvider.clear();
                workAnalysisProvider.clear();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<ProfileProvider>(
              builder: (context, profileProvider, _) {
                return HeaderCard(
                  name: profileProvider.profile != null
                      ? profileProvider.fullName
                      : 'Welcome',
                  subtitle: profileProvider.email.isNotEmpty
                      ? profileProvider.email
                      : null,
                  onSignOut: _handleSignOut,
                );
              },
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _checkAuthenticationAndFetchData,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _SectionHeader(
                        title: 'Available Shifts',
                        actionText: 'View all Available Shifts',
                        onAction: () {
                          AppNavigator.pushNamed(
                              context, AppRoutes.availableShifts);
                        },
                      ),
                      Consumer<AvailableShiftsProvider>(
                        builder: (context, shiftsProvider, _) {
                          if (shiftsProvider.errorMessage != null) {
                            return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                    child: Text(
                                        'Could not load available shifts.')));
                          }
                          List<AvailableShift> shiftsToShow = [];
                          if (shiftsProvider.hasActionableSchedules) {
                            final sortedActionable =
                                List.of(shiftsProvider.actionableSchedules);
                            sortedActionable.sort(
                                (a, b) => a.startDate.compareTo(b.startDate));
                            shiftsToShow = sortedActionable.take(2).toList();
                          } else if (shiftsProvider.allSchedules.isNotEmpty) {
                            final sortedResponded =
                                List.of(shiftsProvider.allSchedules);
                            sortedResponded.sort(
                                (a, b) => a.startDate.compareTo(b.startDate));
                            shiftsToShow = sortedResponded.take(2).toList();
                          }
                          if (shiftsToShow.isEmpty) {
                            return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 24.0),
                                child: Center(
                                    child: Text(
                                  'No available shifts at the moment.',
                                  style: TextStyle(color: AppColors.black),
                                )));
                          }
                          return Column(
                            children: shiftsToShow.map((schedule) {
                              return AvailableShiftCard(
                                shift: schedule,
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 16),
                      _SectionHeader(
                        title: 'Your Scheduled Shifts',
                        actionText: 'View all Schedules',
                        onAction: () {
                          AppNavigator.toScheduledShifts(context);
                        },
                      ),
                      const SizedBox(height: 2),
                      Consumer<SchedulesShiftsProvider>(
                        builder: (context, scheduledShiftsProvider, _) {
                          if (scheduledShiftsProvider
                              .upcomingSchedules.isEmpty) {
                            return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                    child: Text(
                                  'You have no upcoming shifts.',
                                  style: TextStyle(color: AppColors.black),
                                )));
                          }
                          final shiftsToShow = scheduledShiftsProvider
                              .upcomingSchedules
                              .take(3)
                              .toList();
                          return Column(
                            children: shiftsToShow.map((schedule) {
                              return ScheduleTile(
                                facility: schedule.institution,
                                dateLine: _formatDate(schedule.start),
                                time: _buildTimeLine(schedule),
                              );
                            }).toList(),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const _AnalysisRow(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeader({
    required this.title,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
            letterSpacing: 0.5,
            color: AppColors.black,
          ),
        ),
        CompactTextButton(label: actionText, onPressed: onAction),
      ],
    );
  }
}

class _AnalysisRow extends StatelessWidget {
  const _AnalysisRow();

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkAnalysisProvider>(
      builder: (context, analysisProvider, child) {
        Widget card(String number, String label, {double fontSize = 40.0}) {
          return Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                color: AppColors.cardsWhite,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(number,
                      style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87)),
                  const SizedBox(height: 4),
                  Text(label,
                      style:
                          const TextStyle(color: Colors.black87, fontSize: 13)),
                ],
              ),
            ),
          );
        }

        if (analysisProvider.errorMessage != null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Work Analysis Error: ${analysisProvider.errorMessage}',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Work Analysis - Month to Date',
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppColors.black),
            ),
            const SizedBox(height: 9),
            Row(
              children: [
                card(
                  analysisProvider.totalShifts.toString(),
                  'Total Shifts',
                  fontSize: 24.0,
                ),
                const SizedBox(width: 9),
                card(
                  analysisProvider.totalHours.toStringAsFixed(1),
                  'Total Hours',
                  fontSize: 22.0,
                ),
                const SizedBox(width: 9),
                card(
                  '\$${analysisProvider.totalEarnings.toStringAsFixed(2)}', // Assuming earnings should be formatted to 2 decimal places
                  'Total earnings',
                  fontSize: 20.0,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
