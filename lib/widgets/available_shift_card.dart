import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/response_provider.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/custom_pop_up.dart';

class AvailableShiftCard extends StatelessWidget {
  final String name;
  final String dateLine;
  final String timeLine;
  final int notifyId; // 1. ADDED THIS TO RECEIVE THE ID

  const AvailableShiftCard({
    super.key,
    required this.name,
    required this.dateLine,
    required this.timeLine,
    required this.notifyId, // 2. MADE IT A REQUIRED PARAMETER
  });

  (String prefix, String suffix, String postfix) _splitOrdinal(String input) {
    final parts = input.split(' ');
    if (parts.length < 4) return (input, '', '');
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

  @override
  Widget build(BuildContext context) {
    final split = _splitOrdinal(dateLine);

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
                  name,
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
                          // ... (The RichText for date formatting remains the same)
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
                              Icon(Icons.access_time,
                                  size: 20, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(
                                timeLine,
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
                    // Use a Consumer to rebuild the button based on loading state
                    Consumer<ResponseProvider>(
                      builder: (context, responseProvider, child) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: GestureDetector(
                            // 3. UPDATED TAP HANDLER
                            onTap: responseProvider.isLoading
                                ? null
                                : () {
                                    // Disable button while loading
                                    showAppPopup(
                                      context,
                                      title: 'AVAILABLE SHIFT',
                                      message:
                                          'Do you wish to proceed with this shift? \n$name \n$dateLine • $timeLine',
                                      primaryText: 'Not Interested',
                                      onPrimary: () {
                                        Navigator.of(context).pop();
                                      },
                                      secondaryText: 'Interested',
                                      onSecondary: () async {
                                        // Close the dialog first
                                        Navigator.of(context).pop();

                                        // Call the provider to respond to the shift
                                        final success = await responseProvider
                                            .respondToShift(
                                          notifyId: notifyId,
                                          status: 1, // 1 for accepted
                                        );

                                        // Show feedback to the user
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(success
                                                  ? responseProvider
                                                      .successMessage!
                                                  : responseProvider
                                                      .errorMessage!),
                                              backgroundColor: success
                                                  ? Colors.green
                                                  : Colors.red,
                                            ),
                                          );
                                        }
                                      },
                                    );
                                  },
                            child: responseProvider.isLoading
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
                        );
                      },
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
