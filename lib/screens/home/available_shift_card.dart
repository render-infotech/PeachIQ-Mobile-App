import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peach_iq/Models/available_shifts_model.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
import 'package:peach_iq/Providers/response_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/custom_pop_up.dart';
import 'package:provider/provider.dart';

class AvailableShiftCard extends StatefulWidget {
  final AvailableShift shift;

  const AvailableShiftCard({
    super.key,
    required this.shift,
  });

  @override
  State<AvailableShiftCard> createState() => _AvailableShiftCardState();
}

class _AvailableShiftCardState extends State<AvailableShiftCard> {
  bool _isResponding = false;
  bool _isDismissed = false;

  (String, String, String) _splitOrdinal(String input) {
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

  void _showSnackbar(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showInterestConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Interest Confirmed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.black,
                    fontFamily: 'Manrope',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Thank you for your interest. Shifts are assigned on a first-come, first-serve basis. We will notify you once your shift has been assigned.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.black,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _respondToShift(1);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Got it!',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Manrope',
                        color: Colors.white,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotInterestedConfirmation() {
    showAppPopup(
      context,
      title: 'Confirm Action',
      message: 'Are you sure you are not interested in this shift?',
      primaryText: 'Cancel',
      onPrimary: () => Navigator.of(context).pop(),
      secondaryText: 'Yes',
      onSecondary: () {
        Navigator.of(context).pop();
        _respondToShift(-1);
      },
      showClose: false,
      barrierDismissible: false,
    );
  }

  Future<void> _respondToShift(int status) async {
    if (!mounted) return;
    setState(() => _isResponding = true);

    try {
      final responseProvider = context.read<ShiftResponseProvider>();
      final shiftsProvider = context.read<AvailableShiftsProvider>();

      await responseProvider.respondToShift(
        notifyId: widget.shift.notifyId,
        status: status,
        shiftsProvider: shiftsProvider,
      );

      if (mounted) {
        if (status == -1) {
          setState(() => _isDismissed = true);
        }

        final message = status == 1
            ? 'Your interest has been submitted successfully.'
            : 'Shift has been dismissed.';
        _showSnackbar(message);
      }
    } catch (e) {
      if (mounted) {
        _showSnackbar('An error occurred. Please try again.', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isResponding = false);
      }
    }
  }

  void _showActionDialog() {
    showAppPopup(
      context,
      title: 'Scheduling Request from ${widget.shift.name}',
      message: '''Role: ${widget.shift.role}
Dates: ${widget.shift.dateLine}
Shift: ${widget.shift.shiftType} (${widget.shift.timeLine})
Unit Area: ${widget.shift.unitArea}''',
      primaryText: 'Not Interested',
      onPrimary: () {
        Navigator.of(context).pop();
        _showNotInterestedConfirmation();
      },
      secondaryText: 'Interested',
      onSecondary: () {
        Navigator.of(context).pop();
        _showInterestConfirmationDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shift.caregiverDecision == -1 || _isDismissed) {
      return const SizedBox.shrink();
    }

    final split = _splitOrdinal(widget.shift.dateLine);
    final bool isActionable = widget.shift.caregiverDecision == 0;
    final bool hasRespondedInterested = widget.shift.caregiverDecision == 1;

    String buttonText;
    Color buttonColor;
    bool isEnabled = isActionable && !_isResponding;

    if (hasRespondedInterested) {
      buttonText = 'Pending';
      buttonColor = AppColors.primary.withOpacity(.6);
    } else {
      buttonText = 'Respond';
      buttonColor = AppColors.primary;
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardsWhite,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
                  'Shift available at ${widget.shift.name}',
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
                                fontFamily: 'Manrope',
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
                                        color: AppColors.black,
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
                                widget.shift.timeLine,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
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
                        color: buttonColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: InkWell(
                        onTap: isEnabled ? _showActionDialog : null,
                        child: _isResponding
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : Text(
                                buttonText,
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
