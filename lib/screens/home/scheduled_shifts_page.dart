import 'dart:ui' show FontFeature;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peach_iq/Models/scheduled_shifts_model.dart';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/home/schedule_tile_widget.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/screens/auth/login.dart';

class ScheduledShifts extends StatefulWidget {
  const ScheduledShifts({super.key});

  @override
  State<ScheduledShifts> createState() => _ScheduledShiftsState();
}

class _ScheduledShiftsState extends State<ScheduledShifts> {
  int selectedShiftIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchedulesShiftsProvider>(context, listen: false)
          .fetchScheduledShifts();
    });
  }

  // ADDED: Method to show the new details popup
  void _showShiftDetailsPopup(BuildContext context, ScheduledShift shift) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return _ShiftDetailsSheet(shift: shift);
      },
    );
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
              final schedulesProvider =
                  Provider.of<SchedulesShiftsProvider>(context, listen: false);
              await profileProvider.logout();
              schedulesProvider.clear();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
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
                pageheader: 'Upcoming Shifts',
                onSignOut: () => _handleSignOut(context),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Consumer<SchedulesShiftsProvider>(
                builder: (context, provider, child) {
                  if (provider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Failed to load shifts.',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => provider.retry(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (provider.schedules.isEmpty) {
                    return const Center(
                      child: Text(
                        'You have no upcoming shifts.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }
                  if (selectedShiftIndex >= provider.schedules.length) {
                    selectedShiftIndex = 0;
                  }

                  // CHANGED: The main view is now just the list of tiles.
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: provider.schedules.asMap().entries.map((entry) {
                      final index = entry.key;
                      final shift = entry.value;
                      return ScheduleTile(
                        facility: shift.institution,
                        // floorWing: shift.unitarea ?? 'N/A',
                        dateLine:
                            DateFormat("EEEE, MMMM d").format(shift.start),
                        time: DateFormat('h:mm a').format(shift.start),
                        isSelected: index == selectedShiftIndex,
                        onTap: () {
                          // Preserves the tile selection highlight
                          setState(() {
                            selectedShiftIndex = index;
                          });
                          // Shows the new popup with the details
                          _showShiftDetailsPopup(context, shift);
                        },
                      );
                    }).toList(),
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

// ADDED: New private widget to build the content of the modal bottom sheet.
class _ShiftDetailsSheet extends StatelessWidget {
  final ScheduledShift shift;

  const _ShiftDetailsSheet({required this.shift});

  // Helper method to get day suffix (st, nd, rd, th)
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

  String _formatShiftTimeRange(DateTime start, DateTime end) {
    final format = DateFormat('h:mm a');
    return '${format.format(start)} to ${format.format(end)}';
  }

  Widget _buildFormattedDate(DateTime date) {
    String weekday = DateFormat('EEEE').format(date);
    String month = DateFormat('MMMM').format(date);
    String suffix = _getDaySuffix(date.day);
    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          fontFamily: 'Manrope',
        ),
        children: [
          TextSpan(text: '$weekday - $month ${date.day}'),
          TextSpan(
            text: suffix,
            style: const TextStyle(
              fontSize: 12,
              fontFeatures: [FontFeature.superscripts()],
            ),
          ),
          TextSpan(text: ' ${date.year}'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
            overflow: TextOverflow.visible,
            maxLines: 1,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title
          const Text(
            'Shift Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(color: AppColors.cardsWhite),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 140,
                    child: Text(
                      'Date:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _buildFormattedDate(shift.start),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            decoration: BoxDecoration(color: AppColors.cardsWhite),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  _buildDetailRow('LOCATION:', shift.institution),
                  const SizedBox(height: 8),
                  _buildDetailRow('UNIT/BLDG/WING:', shift.unitarea ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'SHIFT TIME:',
                    _formatShiftTimeRange(shift.start, shift.end),
                  ),
                  const SizedBox(height: 8),
                  _buildDetailRow(
                    'SHIFT HOURS:',
                    '${(shift.end.difference(shift.start).inMinutes / 60).toStringAsFixed(1)} Hours',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
