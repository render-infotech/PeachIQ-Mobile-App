// lib/screens/schedule/schedule_page.dart
import 'dart:ui' show FontFeature;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:peach_iq/screens/schedule/calender_widget.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/loading/shimmer_gate.dart';
import 'package:peach_iq/screens/auth/login.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  DateTime? selectedDate; // Selected date controller
  ShiftAppointment? selectedShift; // Selected shift from calendar

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
              // Use shared logout method
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              await profileProvider.logout();

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

  // Method to update selected date
  void onDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
      // Clear any previous shift; CalenderWidget will set one if the date has schedules
      selectedShift = null;
    });
  }

  // Method to update selected shift from calendar overlay/list
  void onAppointmentSelected(ShiftAppointment appt) {
    setState(() {
      selectedShift = appt;
      selectedDate = appt.startTime;
    });

    // Build display values here (no undefined getters on appt)
    // TODO: Map these from actual API fields when available
    final String location = 'Villa Colombo';
    final String unitBefore = 'West Wing - 8';
    final String unitSup = 'th';
    final String unitAfter = ' Floor';
    final String shiftTime = appt.shiftTime; // non-nullable
    final String shiftHours = '8 Hours';
    final String? additionalInfo = null; // set from API when available

    _showShiftDetailsSheet(
      context,
      date: appt.startTime,
      location: location,
      unitBefore: unitBefore,
      unitSup: unitSup,
      unitAfter: unitAfter,
      shiftTime: shiftTime,
      shiftHours: shiftHours,
      additionalInfo: additionalInfo,
    );
  }

  void _showShiftDetailsSheet(
    BuildContext context, {
    required DateTime date,
    required String location,
    required String unitBefore,
    required String unitSup,
    required String unitAfter,
    required String shiftTime,
    required String shiftHours,
    required String? additionalInfo,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(ctx).viewInsets.bottom,
            ),
            child: _ShiftDetailsSheet(
              date: date,
              location: location,
              unitBefore: unitBefore,
              unitSup: unitSup,
              unitAfter: unitAfter,
              shiftTime: shiftTime,
              shiftHours: shiftHours,
              additionalInfo: additionalInfo,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, p, _) => HeaderCard(
                  name: p.fullName,
                  subtitle: p.email.isNotEmpty ? p.email : null,
                  pageheader: 'Schedule overview',
                  onSignOut: () => _handleSignOut(context),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 560,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CalenderWidget(
                  selectedDate: selectedDate,
                  onDateSelected: onDateSelected,
                  onAppointmentSelected: onAppointmentSelected,
                ),
              ),
              // Inline detail cards removed; details appear in the bottom sheet on selection
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShiftDetailsSheet extends StatelessWidget {
  final DateTime date;
  final String location;
  final String unitBefore;
  final String unitSup;
  final String unitAfter;
  final String shiftTime;
  final String shiftHours;
  final String? additionalInfo;

  const _ShiftDetailsSheet({
    required this.date,
    required this.location,
    required this.unitBefore,
    required this.unitSup,
    required this.unitAfter,
    required this.shiftTime,
    required this.shiftHours,
    required this.additionalInfo,
  });

  // Helper method to build formatted date with superscript
  Widget _buildFormattedDate(DateTime date) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];

    String weekday = weekdays[date.weekday - 1];
    String month = months[date.month - 1];
    String suffix = _getDaySuffix(date.day);

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
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

  // Helper method to build detail rows with superscript
  Widget _buildDetailRowWithSuperscript(
    String label,
    String beforeSuperscript,
    String superscript,
    String afterSuperscript,
  ) {
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
        RichText(
          text: TextSpan(
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
            children: [
              TextSpan(text: beforeSuperscript),
              TextSpan(
                text: superscript,
                style: const TextStyle(
                  fontSize: 10,
                  fontFeatures: [FontFeature.superscripts()],
                ),
              ),
              TextSpan(text: afterSuperscript),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollCtrl) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollCtrl,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Grab handle + title row
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
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Shift details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    // IconButton(
                    //   icon: const Icon(Icons.close_rounded),
                    //   onPressed: () => Navigator.of(context).pop(),
                    // ),
                  ],
                ),
                const SizedBox(height: 8),

                // Date card
                Container(
                  decoration: BoxDecoration(color: AppColors.cardsWhite),
                  padding: const EdgeInsets.all(8),
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
                      Expanded(child: _buildFormattedDate(date)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Details card
                Container(
                  decoration: BoxDecoration(color: AppColors.cardsWhite),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      _buildDetailRow('LOCATION:', location),
                      const SizedBox(height: 8),
                      _buildDetailRowWithSuperscript(
                        'UNIT/BLDG/WING:',
                        unitBefore,
                        unitSup,
                        unitAfter,
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow('SHIFT TIME:', shiftTime),
                      const SizedBox(height: 8),
                      _buildDetailRow('SHIFT HOURS:', shiftHours),
                    ],
                  ),
                ),

                // Additional Information (only if provided)
                if ((additionalInfo ?? '').trim().isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      'Additional Information:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.grey.shade400,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      additionalInfo!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
