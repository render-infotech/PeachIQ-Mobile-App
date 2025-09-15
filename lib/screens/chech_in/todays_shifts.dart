// lib/screens/todays_shifts_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:peach_iq/routes.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/models/shift_data_model.dart';

class TodaysShiftsScreen extends StatefulWidget {
  const TodaysShiftsScreen({super.key});

  @override
  State<TodaysShiftsScreen> createState() => _TodaysShiftsScreenState();
}

class _TodaysShiftsScreenState extends State<TodaysShiftsScreen> {
  late final List<ShiftData> _todays;

  void _handleSignOut(BuildContext context) {
    // ... (sign out logic remains the same)
  }

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final allSample = [
      ShiftData(
        facility: 'Villa Columbo',
        floorWing: '8th Floor - West Wing',
        dateLine: 'Today',
        time: '7AM to 3PM',
        dateTime: DateTime(today.year, today.month, today.day, 7, 0),
        shiftTime: '7AM to 3PM',
      ),
      ShiftData(
        facility: 'Palm Springs LTC',
        floorWing: 'Unit B - Medicine',
        dateLine: 'Today',
        time: '3PM to 11PM',
        dateTime: DateTime(today.year, today.month, today.day, 15, 0),
        shiftTime: '3PM to 11PM',
      ),
      ShiftData(
        facility: 'Villa Columbo',
        floorWing: '8th Floor - West Wing',
        dateLine: 'Tomorrow',
        time: '4PM to 12AM',
        dateTime: today.add(const Duration(days: 1, hours: 16)),
        shiftTime: '4PM to 12AM',
      ),
    ];

    _todays = allSample
        .where((s) => DateUtils.isSameDay(s.dateTime, now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // --- NEW HELPER FUNCTION TO FORMAT THE DATE ---
  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d')
        .format(date); // e.g., "Friday, September 12"
  }

  void _onSelect(int index) {
    final selected = _todays[index];
    AppNavigator.toCheckIn(context, selected);
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
                onSignOut: () => _handleSignOut(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _todays.isEmpty
                    ? Container(
                        // ... (empty state widget remains the same)
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
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _todays.length,
                                separatorBuilder: (_, __) => const Divider(
                                    height: 1, indent: 16, endIndent: 16),
                                itemBuilder: (context, index) {
                                  final s = _todays[index];
                                  return ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    onTap: () => _onSelect(index),
                                    title: Text(
                                      s.facility,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    // --- MODIFIED SUBTITLE ---
                                    subtitle: Text(
                                      '${_formatDate(s.dateTime)}\n${s.floorWing} • ${s.shiftTime}',
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
