import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
import 'package:peach_iq/Providers/response_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/custom_pop_up.dart';
import 'package:provider/provider.dart';

class AvailableShiftCard extends StatefulWidget {
  final String name;
  final String dateLine;
  final String timeLine;
  final int notifyId;
  final String role;
  final String shiftType;
  final String unitArea;
  const AvailableShiftCard({
    super.key,
    required this.name,
    required this.dateLine,
    required this.timeLine,
    required this.notifyId,
    required this.role,
    required this.shiftType,
    required this.unitArea,
  });

  @override
  State<AvailableShiftCard> createState() => _AvailableShiftCardState();
}

class _AvailableShiftCardState extends State<AvailableShiftCard> {
  bool _isResponding = false;
  bool _isPending = false;

  (String prefix, String suffix, String postfix) _splitOrdinal(String input) {
    final parts = input.split(' ');
    if (parts.length < 2) return (input, '', '');
    final idx = parts.indexWhere((t) => RegExp(r'^\d+[a-zA-Z]+$').hasMatch(t));
    if (idx == -1) return (input, '', '');
    final m = RegExp(r'^(\d+)([a-zA-Z]+)$').firstMatch(parts[idx]);
    if (m == null) return (input, '', '');
    final day = m.group(1)!;
    final suf = m.group(2)!;
    final before = [...parts.take(idx)].join(' ');
    final after = [...parts.skip(idx + 1)].join(' ');
    return ('$before $day', suf, ' $after');
  }

  void _showInterestConfirmation() {
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 240, maxWidth: 320),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Success icon
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.AppSelectedGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle,
                      color: AppColors.AppSelectedGreen,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Title
                  const Text(
                    'Interest Confirmed!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                      fontFamily: 'Manrope',
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Message
                  const Text(
                    'Thank you for your interest. Shifts are assigned on a first-come, first-serve basis. We will notify you once your shift has been assigned.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Colors.black87,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // OK Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                        if (mounted) {
                          _respondToShift(
                              1); // Proceed with accepting the shift
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.AppSelectedGreen,
                        foregroundColor: AppColors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Got it!',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Manrope',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _respondToShift(int status) async {
    setState(() {
      _isResponding = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final responseProvider = context.read<ShiftResponseProvider>();
    final shiftsProvider = context.read<AvailableShiftsProvider>();

    final success = await responseProvider.respondToShift(
      notifyId: widget.notifyId,
      status: status,
      shiftsProvider:
          shiftsProvider, // Pass the shifts provider for immediate updates
    );

    if (mounted) {
      setState(() {
        _isResponding = false;
        if (success && status == 1) {
          _isPending = true; // Show Pending after successful Interested
        }
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            success
                ? (status == 1
                    ? 'Your interest has been submitted successfully!'
                    : 'Shift declined successfully! The shift has been removed from available shifts.')
                : responseProvider.errorMessage ?? 'An unknown error occurred.',
            style: const TextStyle(color: AppColors.white),
          ),
          backgroundColor: success ? Colors.green : Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final split = _splitOrdinal(widget.dateLine);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardsWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Shift available at ${widget.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              children: [
                                TextSpan(text: split.$1),
                                WidgetSpan(
                                  alignment: PlaceholderAlignment.top,
                                  child: Transform.translate(
                                    offset: const Offset(0, -3),
                                    child: Text(
                                      split.$2,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                TextSpan(text: split.$3),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/icons/clock_icon.svg',
                                width: 20,
                                height: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                widget.timeLine,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF8C8C8C),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: GestureDetector(
                        onTap: _isResponding || _isPending
                            ? null
                            : () {
                                showAppPopup(
                                  context,
                                  title:
                                      'Scheduling Request from ${widget.name}',
                                  message: '''Role: ${widget.role}
Dates: ${widget.dateLine}
Shift: ${widget.shiftType} (${widget.timeLine})
Unit Area: ${widget.unitArea}''',
                                  primaryText: 'Not Interested',
                                  onPrimary: () {
                                    Navigator.of(context).pop();
                                    _respondToShift(-1);
                                  },
                                  secondaryText: 'Interested',
                                  onSecondary: () {
                                    Navigator.of(context).pop();
                                    _showInterestConfirmation();
                                  },
                                );
                              },
                        child: _isResponding
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(
                                _isPending ? 'Pending' : 'Respond',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
