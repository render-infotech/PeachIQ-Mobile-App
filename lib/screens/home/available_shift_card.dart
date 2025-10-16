import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:peach_iq/Models/available_shifts_model.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
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

  void _showSnackbar(ScaffoldMessengerState messenger, String message,
      {bool isError = false, bool isSuccess = false}) {
    Color backgroundColor;
    Color textColor = Colors.white;
    Duration duration;

    if (isError) {
      backgroundColor = AppColors.Red;
      duration = const Duration(seconds: 4);
    } else if (isSuccess) {
      backgroundColor = AppColors.AppSelectedGreen;
      duration = const Duration(seconds: 3);
    } else {
      backgroundColor = AppColors.primary;
      duration = const Duration(seconds: 3);
    }

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            fontFamily: 'Manrope',
          ),
        ),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: duration,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: isError
            ? SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  messenger.hideCurrentSnackBar();
                },
              )
            : null,
      ),
    );
  }

  void _showInterestConfirmationDialog() {
    final shiftInfo =
        'NotifyId: ${widget.shift.notifyId} | Facility: ${widget.shift.name}';
    debugPrint(
        '💚 [UI_CONFIRMATION] Showing interest confirmation dialog | $shiftInfo');

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
                      debugPrint(
                          '✅ [UI_CONFIRMATION] User clicked "Got it!" - proceeding with INTERESTED response | $shiftInfo');
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
    final shiftInfo =
        'NotifyId: ${widget.shift.notifyId} | Facility: ${widget.shift.name}';
    debugPrint(
        '🔴 [UI_CONFIRMATION] Showing not interested confirmation dialog | $shiftInfo');

    showAppPopup(
      context,
      title: 'Confirm Action',
      message: 'Are you sure you are not interested in this shift?',
      primaryText: 'Cancel',
      onPrimary: () {
        debugPrint(
            '↩️ [UI_CONFIRMATION] User cancelled "Not Interested" action | $shiftInfo');
        Navigator.of(context).pop();
      },
      secondaryText: 'Yes',
      onSecondary: () {
        debugPrint(
            '❌ [UI_CONFIRMATION] User confirmed "Not Interested" - proceeding with NOT_INTERESTED response | $shiftInfo');
        Navigator.of(context).pop();
        _respondToShift(-1);
      },
      showClose: false,
      barrierDismissible: false,
    );
  }

  Future<void> _respondToShift(int status) async {
    final statusText = status == 1
        ? 'INTERESTED'
        : status == -1
            ? 'NOT_INTERESTED'
            : 'UNKNOWN';
    final shiftInfo =
        'NotifyId: ${widget.shift.notifyId} | Facility: ${widget.shift.name} | Date: ${widget.shift.dateLine}';

    debugPrint(
        '🎯 [USER_ACTION] User clicked response button | $shiftInfo | Response: $statusText ($status)');

    if (!mounted) {
      debugPrint(
          '⚠️ [USER_ACTION] Widget not mounted, aborting response | $shiftInfo');
      return;
    }

    if (_isResponding) {
      debugPrint(
          '🚫 [USER_ACTION] Already responding to shift, ignoring duplicate | $shiftInfo');
      return;
    }

    final messenger = ScaffoldMessenger.of(context);

    debugPrint(
        '🔄 [USER_ACTION] Setting responding state to true | $shiftInfo');
    setState(() => _isResponding = true);

    try {
      final shiftsProvider = context.read<AvailableShiftsProvider>();
      debugPrint(
          '📞 [USER_ACTION] Calling shiftsProvider.respondToShift() | $shiftInfo | Status: $statusText');

      final success = await shiftsProvider.respondToShift(
        widget.shift.notifyId,
        status,
      );

      debugPrint(
          '📋 [USER_ACTION] Provider response completed | $shiftInfo | Success: $success');

      if (success) {
        if (status == 1) {
          // *** CHANGE IS HERE ***
          // Now showing snackbar for "Interested" as well for consistency.
          _showSnackbar(messenger, 'Interest confirmed', isSuccess: true);
        } else {
          _showSnackbar(messenger, 'Shift dismissed', isSuccess: true);
        }
      } else {
        _showSnackbar(messenger, 'Failed to submit response. Please try again.',
            isError: true);
      }
    } catch (e) {
      _showSnackbar(messenger, 'Failed to submit response. Please try again.',
          isError: true);
    } finally {
      if (mounted) {
        debugPrint(
            '🏁 [USER_ACTION] Setting responding state to false | $shiftInfo');
        setState(() => _isResponding = false);
      } else {
        debugPrint(
            '⚠️ [USER_ACTION] Widget unmounted, cannot update responding state | $shiftInfo');
      }
    }
  }

  void _showActionDialog() {
    final shiftInfo =
        'NotifyId: ${widget.shift.notifyId} | Facility: ${widget.shift.name}';
    debugPrint('📱 [UI_DIALOG] Showing action dialog | $shiftInfo');

    showAppPopup(
      context,
      title: 'Scheduling Request from ${widget.shift.name}',
      message: '''Role: ${widget.shift.role}
Dates: ${widget.shift.dateLine}
Shift: ${widget.shift.shiftType} (${widget.shift.timeLine})
Unit Area: ${widget.shift.unitArea}''',
      primaryText: 'Not Interested',
      onPrimary: () {
        debugPrint(
            '🔴 [UI_DIALOG] User selected "Not Interested" | $shiftInfo');
        Navigator.of(context).pop();
        _showNotInterestedConfirmation();
      },
      secondaryText: 'Interested',
      onSecondary: () {
        debugPrint('🟢 [UI_DIALOG] User selected "Interested" | $shiftInfo');
        Navigator.of(context).pop();
        _showInterestConfirmationDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.shift.caregiverDecision == -1) {
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
                            ? const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2, color: Colors.white)),
                                  SizedBox(width: 4),
                                  Text(
                                    'Respond',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              )
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
