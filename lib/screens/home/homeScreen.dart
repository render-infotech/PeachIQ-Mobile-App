// lib/screens/home/homeScreen.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/Models/available_shifts_model.dart';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';
import 'package:peach_iq/loading/loading_provider.dart';
import 'package:peach_iq/routes.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/screens/home/schedule_tile_widget.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
import 'package:peach_iq/Providers/work_analysis_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/text_button.dart';
import 'package:peach_iq/widgets/available_shift_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthenticationAndFetchData();
    });
  }

  // --- MODIFIED: This method now fully controls its own loading state ---
  Future<void> _checkAuthenticationAndFetchData() async {
    final loadingProvider =
        Provider.of<LoadingProvider>(context, listen: false);

    try {
      // >>>>>>> THIS IS THE NEW LINE <<<<<<<
      // Show the loader at the start of ANY data fetch for this screen.
      loadingProvider.setLoading(true);

      final profileProvider =
          Provider.of<ProfileProvider>(context, listen: false);
      final availableShiftsProvider =
          Provider.of<AvailableShiftsProvider>(context, listen: false);
      final scheduledShiftsProvider =
          Provider.of<SchedulesShiftsProvider>(context, listen: false);
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
        availableShiftsProvider.fetchAvailableShifts(),
        scheduledShiftsProvider.fetchScheduledShifts(),
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
      // This correctly hides the loader when everything is done.
      if (mounted) {
        loadingProvider.setLoading(false);
      }
    }
  }

  // --- NO OTHER CHANGES ARE NEEDED IN THE REST OF THE FILE ---
  // ... all your other methods (_formatDate, build, _handleSignOut, etc.) ...
  // ... remain exactly the same as you had them. ...

  String _formatDate(DateTime date) {
    try {
      return DateFormat(
              'EEEE - MMMM d' "'" '${_getDaySuffix(date.day)}' "'" ' yyyy')
          .format(date);
    } catch (e) {
      debugPrint('Error formatting date: $e');
      return 'Invalid Date';
    }
  }

  String _getDaySuffix(int day) {
    if (day >= 11 && day <= 13) return 'th';
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _formatTime(DateTime dateTime) {
    try {
      return DateFormat('h:mm a').format(dateTime);
    } catch (e) {
      debugPrint('Error formatting time: $e');
      return 'Invalid Time';
    }
  }

  String _formatShiftTimeRange(DateTime start, DateTime end) {
    return '${_formatTime(start)} to ${_formatTime(end)}';
  }

  String _buildTimeLine(Schedule schedule) {
    try {
      final startTime = _formatTime(schedule.start);
      final endTime = _formatTime(schedule.end);
      final unitInfo =
          schedule.unitarea != null && schedule.unitarea!.isNotEmpty
              ? ' - ${schedule.unitarea}'
              : '';
      return '$startTime to $endTime$unitInfo';
    } catch (e) {
      debugPrint('Error building time line: $e');
      return 'Time information unavailable';
    }
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
                        actionText: 'View all Available',
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
                          if (!shiftsProvider.hasSchedules) {
                            return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                    child: Text(
                                        'No available shifts right now.')));
                          }
                          final shiftsToShow =
                              shiftsProvider.schedules.take(2).toList();
                          return Column(
                            children: shiftsToShow.map((schedule) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 2),
                                child: AvailableShiftCard(
                                  name:
                                      'Shift Available at ${schedule.institution.isNotEmpty ? schedule.institution : 'Unknown Location'}',
                                  dateLine: _formatDate(schedule.start),
                                  timeLine: _buildTimeLine(schedule),
                                  notifyId: schedule.notifyId!,
                                ),
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
                          if (scheduledShiftsProvider.errorMessage != null) {
                            return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                    child:
                                        Text('Could not load your schedule.')));
                          }
                          if (scheduledShiftsProvider.schedules.isEmpty) {
                            return const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Center(
                                    child:
                                        Text('You have no upcoming shifts.')));
                          }
                          final shiftsToShow = scheduledShiftsProvider.schedules
                              .take(3)
                              .toList();
                          return Column(
                            children: shiftsToShow.map((schedule) {
                              return ScheduleTile(
                                facility: schedule.institution,
                                floorWing: schedule.unitarea,
                                dateLine: _formatDate(schedule.start),
                                time: _formatShiftTimeRange(
                                    schedule.start, schedule.end),
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

  void _handleSignOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                final profileProvider =
                    Provider.of<ProfileProvider>(context, listen: false);
                final availableShiftsProvider =
                    Provider.of<AvailableShiftsProvider>(context,
                        listen: false);
                final scheduledShiftsProvider =
                    Provider.of<SchedulesShiftsProvider>(context,
                        listen: false);
                final workAnalysisProvider =
                    Provider.of<WorkAnalysisProvider>(context, listen: false);

                await profileProvider.logout();
                availableShiftsProvider.clear();
                scheduledShiftsProvider.clear();
                workAnalysisProvider.clear();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              } catch (e) {
                debugPrint('Error during sign out: $e');
                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                }
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
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
            color: Color(0xFF2C2C2C),
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
                          const TextStyle(color: Colors.black87, fontSize: 15)),
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
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
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
                  fontSize: 24.0,
                ),
                const SizedBox(width: 9),
                card(
                  '\$${analysisProvider.totalEarnings}',
                  'Total earnings',
                  fontSize: 24.0,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
