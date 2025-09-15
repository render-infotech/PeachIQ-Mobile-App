import 'dart:ui' show FontFeature;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // Fetch the shifts after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SchedulesShiftsProvider>(context, listen: false)
          .fetchScheduledShifts();
    });
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
              // Clear all provider data on sign out
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

  String _formatDate(DateTime date) {
    return DateFormat("EEEE - MMMM d'${_getDaySuffix(date.day)}' yyyy")
        .format(date);
  }

  String _formatShiftTimeRange(DateTime start, DateTime end) {
    final format = DateFormat('h:mm a');
    return '${format.format(start)} to ${format.format(end)}';
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
                  // === LOADING STATE ===
                  // if (provider.isLoading) {
                  //   return _buildShimmerLoading();
                  // }

                  // === ERROR STATE ===
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

                  // === EMPTY STATE ===
                  if (provider.schedules.isEmpty) {
                    return const Center(
                      child: Text(
                        'You have no upcoming shifts.',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    );
                  }

                  // Reset index if out of bounds
                  if (selectedShiftIndex >= provider.schedules.length) {
                    selectedShiftIndex = 0;
                  }

                  // === SUCCESS STATE (DATA AVAILABLE) ===
                  final selectedShift = provider.schedules[selectedShiftIndex];

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        // Shifts List
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Column(
                            children:
                                provider.schedules.asMap().entries.map((entry) {
                              final index = entry.key;
                              final shift = entry.value;
                              return ScheduleTile(
                                facility: shift.institution,
                                floorWing: shift.unitarea ?? 'N/A',
                                dateLine: _formatDate(shift.start),
                                time: _formatShiftTimeRange(
                                    shift.start, shift.end),
                                isSelected: index == selectedShiftIndex,
                                onTap: () {
                                  setState(() {
                                    selectedShiftIndex = index;
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Date Section
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 20),
                          child: Container(
                            decoration:
                                BoxDecoration(color: AppColors.cardsWhite),
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
                                    child: _buildFormattedDate(
                                        selectedShift.start),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 2),

                        // Location and shift details
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Container(
                            decoration:
                                BoxDecoration(color: AppColors.cardsWhite),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                      'LOCATION:', selectedShift.institution),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('UNIT/BLDG/WING:',
                                      selectedShift.unitarea ?? 'N/A'),
                                  const SizedBox(height: 8),
                                  _buildDetailRow(
                                      'SHIFT TIME:',
                                      _formatShiftTimeRange(selectedShift.start,
                                          selectedShift.end)),
                                  const SizedBox(height: 8),
                                  _buildDetailRow('SHIFT HOURS:',
                                      '${(selectedShift.end.difference(selectedShift.start).inMinutes / 60).toStringAsFixed(1)} Hours'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildShimmerLoading() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.symmetric(horizontal: 12),
  //     child: Column(
  //       children: List.generate(
  //         5,
  //         (index) => Container(
  //           margin: const EdgeInsets.only(bottom: 10),
  //           height: 120,
  //           decoration: BoxDecoration(
  //             color: Colors.white,
  //             borderRadius: BorderRadius.circular(12),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Helper method to build detail rows (regular)
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

  // Helper method to build formatted date with superscript
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
          fontFamily: 'Manrope', // Ensure font matches
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
}
