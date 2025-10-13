import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peach_iq/Providers/chekinout_provider.dart';
import 'package:peach_iq/models/shift_data_model.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';

class CheckInScreen extends StatefulWidget {
  final ShiftData shift;
  const CheckInScreen({super.key, required this.shift});

  @override
  State<CheckInScreen> createState() => _CheckInScreenState();
}

class _CheckInScreenState extends State<CheckInScreen> {
  DateTime? _checkInTime;
  DateTime? _checkOutTime;
  bool _isCheckingIn = false;
  bool _isCheckingOut = false;
  int _currentCheckInStatus = -1;

  @override
  void initState() {
    super.initState();
    // Initialize state from the shift data passed to the screen
    _checkInTime = widget.shift.actualCheckIn;
    _checkOutTime = widget.shift.actualCheckOut;
    _currentCheckInStatus = widget.shift.checkInStatus;
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Location services are disabled. Please enable them.')));
      }
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Location permissions are denied.')));
        }
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them in settings.')));
      }
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
        desiredAccuracy: LocationAccuracy.high,
      );
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Could not get a location in time. Try again in an area with a clearer sky.'),
        ));
      }
      return null;
    }
  }

  Future<void> _handleCheckIn() async {
    setState(() => _isCheckingIn = true);
    try {
      final checkInProvider = context.read<CheckInCheckOutProvider>();
      final schedulesProvider =
          context.read<SchedulesShiftsProvider>(); // Get the provider
      final messenger = ScaffoldMessenger.of(context);

      final position = await _getCurrentLocation();
      if (position == null) return;

      final success = await checkInProvider.checkIn(
        schedulingId: widget.shift.schedulingId,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        schedulesProvider: schedulesProvider, // Pass the provider
      );

      if (mounted) {
        if (success) {
          setState(() {
            _checkInTime = DateTime.now();
            _currentCheckInStatus = 0;
          });
          messenger.showSnackBar(
            const SnackBar(
                content: Text("Checked in successfully!",
                    style: TextStyle(color: AppColors.white)),
                backgroundColor: Colors.green),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
                content: Text(
                    checkInProvider.errorMessage ?? "Failed to check in.",
                    style: const TextStyle(color: AppColors.white)),
                backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingIn = false);
      }
    }
  }

  Future<void> _handleCheckOut() async {
    setState(() => _isCheckingOut = true);
    try {
      final checkInProvider = context.read<CheckInCheckOutProvider>();
      final schedulesProvider =
          context.read<SchedulesShiftsProvider>(); // Get the provider
      final messenger = ScaffoldMessenger.of(context);

      final position = await _getCurrentLocation();
      if (position == null) return;

      final success = await checkInProvider.checkOut(
        schedulingId: widget.shift.schedulingId,
        latitude: position.latitude.toString(),
        longitude: position.longitude.toString(),
        schedulesProvider: schedulesProvider, // Pass the provider
      );

      if (mounted) {
        if (success) {
          setState(() {
            _checkOutTime = DateTime.now();
            _currentCheckInStatus = 1;
          });
          messenger.showSnackBar(
            const SnackBar(
                content: Text("Checked out successfully!",
                    style: TextStyle(color: AppColors.white)),
                backgroundColor: Colors.green),
          );
        } else {
          messenger.showSnackBar(
            SnackBar(
                content: Text(
                    checkInProvider.errorMessage ?? "Failed to check out.",
                    style: const TextStyle(color: AppColors.white)),
                backgroundColor: Colors.red),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text('Sign Out',
                  style: TextStyle(color: AppColors.black)),
              content: const Text('Are you sure you want to sign out?',
                  style: TextStyle(color: AppColors.black)),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel',
                      style: TextStyle(color: AppColors.primary)),
                ),
                TextButton(
                  onPressed: () async {
                    final profileProvider =
                        Provider.of<ProfileProvider>(context, listen: false);
                    await profileProvider.logout();

                    if (mounted) {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    }
                  },
                  child: const Text('Sign Out',
                      style: TextStyle(color: AppColors.primary)),
                ),
              ],
            ));
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
            Stack(
              children: [
                Consumer<ProfileProvider>(
                  builder: (context, p, _) => HeaderCard(
                    name: p.fullName,
                    subtitle: p.email.isNotEmpty ? p.email : null,
                    pageheader: '       Check in/out',
                    onSignOut: () => _handleSignOut(context),
                  ),
                ),
                Positioned(
                  left: 4,
                  bottom: 3,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        color: AppColors.white, size: 22),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
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
                          if (widget.shift.floorWing.isNotEmpty)
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
                      currentStatus: _currentCheckInStatus,
                      isCheckingIn: _isCheckingIn,
                      isCheckingOut: _isCheckingOut,
                      onCheckIn: _handleCheckIn,
                      onCheckOut: _handleCheckOut,
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
  final int currentStatus;
  final bool isCheckingIn;
  final bool isCheckingOut;
  final VoidCallback onCheckIn;
  final VoidCallback onCheckOut;

  const _ModernCheckActionsCard({
    required this.shift,
    this.checkInTime,
    this.checkOutTime,
    required this.currentStatus,
    required this.isCheckingIn,
    required this.isCheckingOut,
    required this.onCheckIn,
    required this.onCheckOut,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasCheckedIn = currentStatus == 0 || currentStatus == 1;
    final bool hasCheckedOut = currentStatus == 1;

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
            status: hasCheckedIn ? 'Checked In' : 'Ready',
            statusColor: hasCheckedIn ? Colors.grey : const Color(0xFF10B981),
            buttonColor: const Color(0xFFF36856),
            buttonText: 'Check In Now',
            isDisabled: hasCheckedIn,
            isLoading: isCheckingIn,
            onTap: onCheckIn,
            actionTime: hasCheckedIn && checkInTime != null
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
            status: hasCheckedOut
                ? 'Checked Out'
                : (hasCheckedIn ? 'Ready' : 'Pending Check-In'),
            statusColor: hasCheckedOut
                ? Colors.grey
                : (hasCheckedIn
                    ? const Color(0xFF10B981)
                    : const Color(0xFFF59E0B)),
            buttonColor: AppColors.primary,
            buttonText: 'Check Out',
            isDisabled: !hasCheckedIn || hasCheckedOut,
            isLoading: isCheckingOut,
            onTap: onCheckOut,
            actionTime: hasCheckedOut && checkOutTime != null
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
  final String status;
  final Color statusColor;
  final Color buttonColor;
  final String buttonText;
  final bool isDisabled;
  final bool isLoading;
  final VoidCallback onTap;
  final String? actionTime;

  const _ActionSection({
    required this.title,
    required this.location,
    required this.status,
    required this.statusColor,
    required this.buttonColor,
    required this.buttonText,
    this.isDisabled = false,
    this.isLoading = false,
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
              onTap: isDisabled || isLoading ? null : onTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: isLoading
                    ? const Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
