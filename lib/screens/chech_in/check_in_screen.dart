// lib/screens/check_in_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peach_iq/models/shift_data_model.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';

class CheckInScreen extends StatefulWidget {
  final ShiftData shift;
  const CheckInScreen({super.key, required this.shift});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  DateTime? _checkInTime;
  DateTime? _checkOutTime;

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

  String _formatDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
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
                pageheader: 'Check in/out',
                onSignOut: () => _handleSignOut(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Container(
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
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.shift.facility,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.shift.floorWing,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF475569),
                            ),
                          ),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              icon: Icons.calendar_today_outlined,
                              text: _formatDate(widget.shift.dateTime)),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                              icon: Icons.access_time_outlined,
                              text: widget.shift.shiftTime),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _ModernCheckActionsCard(
                      shift: widget.shift,
                      checkInTime: _checkInTime,
                      checkOutTime: _checkOutTime,
                      onCheckIn: () {
                        setState(() {
                          _checkInTime = DateTime.now();
                        });
                      },
                      onCheckOut: () {
                        setState(() {
                          _checkOutTime = DateTime.now();
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF475569)),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}

class _ModernCheckActionsCard extends StatelessWidget {
  final ShiftData shift;
  final DateTime? checkInTime;
  final DateTime? checkOutTime;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const _ModernCheckActionsCard({
    required this.shift,
    this.checkInTime,
    this.checkOutTime,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCheckedIn = checkInTime != null;
    final bool isCheckedOut = checkOutTime != null;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ActionSection(
            title: 'Check In',
            location: shift.facility,
            // shiftTime: shift.shiftTime,
            status: isCheckedIn ? 'Checked In' : 'Ready',
            statusColor: isCheckedIn ? Colors.grey : const Color(0xFF10B981),
            buttonColor: const Color(0xFFF36856),
            buttonText: 'Check In Now',
            icon: Icons.login_rounded,
            isDisabled: isCheckedIn,
            onTap: onCheckIn,
            // Display Check-In time only in this section
            actionTime: isCheckedIn
                ? 'at ${DateFormat('h:mm a').format(checkInTime!)}'
                : null,
          ),
          const SizedBox(height: 24),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.grey.withOpacity(0.2),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _ActionSection(
            title: 'Check Out',
            location: shift.facility,
            // shiftTime: shift.shiftTime,
            status: isCheckedOut
                ? 'Checked out'
                : (isCheckedIn ? 'Ready' : 'Pending'),
            statusColor: isCheckedOut
                ? Colors.grey
                : (isCheckedIn
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B)),
            buttonColor: AppColors.primary,
            buttonText: 'Check Out',
            icon: Icons.logout_rounded,
            isDisabled: !isCheckedIn || isCheckedOut,
            onTap: onCheckOut,
            // Display Check-Out time only in this section
            actionTime: isCheckedOut
                ? 'at ${DateFormat('h:mm a').format(checkOutTime!)}'
                : null,
          ),
        ],
      ),
    );
  }
}

class _ActionSection extends StatelessWidget {
  final String title;
  final String location;
  // final String shiftTime;
  final String status;
  final Color statusColor;
  final Color buttonColor;
  final String buttonText;
  final IconData icon;
  final bool isDisabled;
  final VoidCallback onTap;
  final String? actionTime;

  const _ActionSection({
    required this.title,
    required this.location,
    // required this.shiftTime,
    required this.status,
    required this.statusColor,
    required this.buttonColor,
    required this.buttonText,
    required this.icon,
    this.isDisabled = false,
    required this.onTap,
    this.actionTime,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.black,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                status,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
            ),
          ],
        ),
        // const SizedBox(height: 12),
        Row(
          children: [
            // Container(
            //   width: 22,
            //   height: 22,
            //   decoration: BoxDecoration(
            //     color: AppColors.primary.withOpacity(0.12),
            //     shape: BoxShape.circle,
            //   ),
            //   // alignment: Alignment.center,
            //   // child: const Icon(
            //   //   Icons.access_time_outlined,
            //   //   size: 12,
            //   //   color: AppColors.primary,
            //   // ),
            // ),
            // const SizedBox(width: 6),
            // Text(
            //   shiftTime,
            //   style: const TextStyle(
            //     fontSize: 14,
            //     fontWeight: FontWeight.w500,
            //     color: AppColors.black,
            //   ),
            // ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.place_outlined,
                size: 12,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              location,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        if (actionTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 28.0),
            child: Text(
              actionTime!,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Material(
            color: isDisabled ? buttonColor.withOpacity(0.3) : buttonColor,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: isDisabled ? null : onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      buttonText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
