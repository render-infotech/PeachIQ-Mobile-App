import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:peach_iq/routes.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/models/shift_data_model.dart';
import 'package:peach_iq/Models/scheduled_shifts_model.dart';

class TodaysShiftsScreen extends StatefulWidget {
  const TodaysShiftsScreen({super.key});

  @override
  State<TodaysShiftsScreen> createState() => _TodaysShiftsScreenState();
}

class _TodaysShiftsScreenState extends State<TodaysShiftsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SchedulesShiftsProvider>().fetchScheduledShifts();
    });
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d').format(date);
  }

  String _formatShiftTime(DateTime start, DateTime end) {
    final DateFormat format = DateFormat('h:mm a');
    return '${format.format(start)} to ${format.format(end)}';
  }

  void _onSelect(ShiftData selectedShift) {
    AppNavigator.toCheckIn(context, selectedShift);
  }

  Map<String, dynamic> _getStatusInfo(int checkInStatus) {
    switch (checkInStatus) {
      case -1: // Not started/Incomplete
        return {
          'text': 'Incomplete',
          'color': const Color(0xFFEF4444), // Red
        };
      case 0: // Checked in but not checked out
        return {
          'text': 'Pending',
          'color': const Color(0xFFF97316), // Orange
        };
      case 1: // Complete (both checked in and out)
        return {
          'text': 'Complete',
          'color': const Color(0xFF16A34A), // Green
        };
      default:
        return {
          'text': 'Unknown',
          'color': const Color(0xFF6B7280), // Gray
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<ProfileProvider>(
              builder: (context, p, _) => HeaderCard(
                name: p.fullName,
                subtitle: p.email.isNotEmpty ? p.email : null,
                pageheader: 'Today\'s Shifts',
                onQrCodeTap: () {
                  // TODO: Implement QR code functionality
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('QR Code feature coming soon!')),
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<SchedulesShiftsProvider>(
                builder: (context, shiftProvider, child) {
                  if (shiftProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (shiftProvider.errorMessage != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                              'Failed to load shifts. Please try again.'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                shiftProvider.fetchScheduledShifts(),
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    );
                  }

                  final now = DateTime.now();
                  final todaysShifts = shiftProvider.schedules
                      .where((s) => DateUtils.isSameDay(s.start, now))
                      .map((apiShift) => ShiftData(
                            schedulingId: apiShift.scheduleId,
                            facility: apiShift.institution,
                            floorWing: apiShift.unitarea,
                            dateLine: 'Today',
                            time:
                                _formatShiftTime(apiShift.start, apiShift.end),
                            dateTime: apiShift.start,
                            shiftTime:
                                _formatShiftTime(apiShift.start, apiShift.end),
                            checkInStatus: apiShift.checkInStatus ?? -1,
                            actualCheckIn: apiShift.actualCheckIn,
                            actualCheckOut: apiShift.actualCheckOut,
                          ))
                      .toList()
                    ..sort((a, b) => a.dateTime.compareTo(b.dateTime));

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: todaysShifts.isEmpty
                        ? Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 50),
                            child: const Text(
                              'No shifts scheduled for today.',
                              style: TextStyle(
                                  fontSize: 16, color: AppColors.black),
                            ),
                          )
                        : Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.04),
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(height: 1),
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: todaysShifts.length,
                                    separatorBuilder: (_, __) => const Divider(
                                        height: 1, indent: 16, endIndent: 16),
                                    itemBuilder: (context, index) {
                                      final s = todaysShifts[index];
                                      final statusInfo =
                                          _getStatusInfo(s.checkInStatus);
                                      final Color statusColor =
                                          statusInfo['color'];
                                      final String statusText =
                                          statusInfo['text'];

                                      final unitText = (s.floorWing.isNotEmpty)
                                          ? '${s.floorWing} • '
                                          : '';

                                      return ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                        onTap: () => _onSelect(s),
                                        leading: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Container(
                                              width: 10,
                                              height: 10,
                                              decoration: BoxDecoration(
                                                color: statusColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              statusText,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        title: Text(
                                          s.facility,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.black,
                                          ),
                                        ),
                                        subtitle: Text(
                                          '${_formatDate(s.dateTime)}\n$unitText${s.shiftTime}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF475569),
                                          ),
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
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
}
