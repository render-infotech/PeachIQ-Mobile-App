import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peach_iq/Models/available_shifts_model.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:peach_iq/widgets/available_shift_card.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';

class AvailableShifts extends StatefulWidget {
  const AvailableShifts({super.key});

  @override
  State<AvailableShifts> createState() => _AvailableShiftsState();
}

class _AvailableShiftsState extends State<AvailableShifts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AvailableShiftsProvider>(context, listen: false)
          .fetchAvailableShifts();
    });
  }

  String _formatDate(DateTime date) {
    try {
      return DateFormat('EEEE - MMMM d\'${_getDaySuffix(date.day)}\' yyyy')
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

  void _handleSignOut(BuildContext context) {
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
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              final shiftsProvider =
                  Provider.of<AvailableShiftsProvider>(context, listen: false);

              await profileProvider.logout();
              shiftsProvider.clear();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Sign Out'),
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<ProfileProvider>(
              builder: (context, p, _) => HeaderCard(
                name: p.fullName,
                subtitle: p.email.isNotEmpty ? p.email : null,
                pageheader: 'Available Shifts',
                onSignOut: () => _handleSignOut(context),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<AvailableShiftsProvider>(
                builder: (context, shiftsProvider, child) {
                  // UPDATED: Loading state now shows nothing.
                  if (shiftsProvider.isLoading) {
                    return const SizedBox.shrink();
                  }

                  if (shiftsProvider.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Colors.red, size: 48),
                            const SizedBox(height: 16),
                            Text('Failed to Load Shifts',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text(shiftsProvider.errorMessage!,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              onPressed: () => shiftsProvider.retry(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!shiftsProvider.hasSchedules) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today_outlined,
                              color: Colors.grey[400], size: 48),
                          const SizedBox(height: 16),
                          Text(
                            'No Available Shifts',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back later for new opportunities.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: shiftsProvider.schedules.length,
                    itemBuilder: (context, index) {
                      final schedule = shiftsProvider.schedules[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 2.0),
                        child: AvailableShiftCard(
                          name: 'Shift Available at ${schedule.institution}',
                          dateLine: _formatDate(schedule.start),
                          timeLine: _buildTimeLine(schedule),
                          notifyId: schedule.notifyId!,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
