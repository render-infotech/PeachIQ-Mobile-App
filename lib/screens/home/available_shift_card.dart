import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
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

  Future<void> _respondToShift(int status) async {
    setState(() {
      _isResponding = true;
    });

    final messenger = ScaffoldMessenger.of(context);
    final responseProvider = context.read<ShiftResponseProvider>();

    final success = await responseProvider.respondToShift(
      notifyId: widget.notifyId,
      status: status,
    );

    if (mounted) {
      setState(() {
        _isResponding = false;
      });

      messenger.showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Caregiver status updated successfully'
              : responseProvider.errorMessage ?? 'An unknown error occurred.'),
          backgroundColor: success ? Colors.green : Colors.red,
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
                  'Shift available at ${widget.name}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
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
                        onTap: _isResponding
                            ? null
                            : () {
                                showAppPopup(
                                  context,
                                  title:
                                      'Scheduling Request from ${widget.name}',
                                  message: '''Role: ${widget.role}

Dates: ${widget.dateLine} - ${widget.dateLine}
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
                                    _respondToShift(1);
                                  },
                                );
                              },
                        child: _isResponding
                            ? const SizedBox(
                                width: 12,
                                height: 12,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Colors.white))
                            : const Text(
                                'Respond',
                                style: TextStyle(
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
