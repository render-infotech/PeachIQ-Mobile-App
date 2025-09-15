import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class ScheduleTile extends StatelessWidget {
  final String facility;
  final String floorWing;
  final String dateLine;
  final String time;
  final bool isSelected;
  final VoidCallback? onTap;

  const ScheduleTile({
    super.key,
    required this.facility,
    required this.floorWing,
    required this.dateLine,
    required this.time,
    this.isSelected = false,
    this.onTap,
  });

  // Helper to split ordinal token for superscript
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

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.cardsWhite,
          borderRadius: BorderRadius.circular(10),
          border: isSelected
              ? Border.all(color: AppColors.AppSelectedGreen, width: 2)
              : null,
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
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.primary,
              child: const Icon(
                Icons.calendar_month_outlined,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        facility,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 37),
                      Text(
                        floorWing,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        // Superscript date in schedule tile
                        child: split.$2.isEmpty
                            ? Text(
                                dateLine,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                              )
                            : RichText(
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
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    TextSpan(text: split.$3),
                                  ],
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Row(
                        children: [
                          Builder(
                            builder: (context) {
                              try {
                                return SvgPicture.asset(
                                  'assets/icons/clock_icon.svg',
                                  width: 20,
                                  height: 20,
                                );
                              } catch (e) {
                                // ignore: avoid_print
                                print('SVG Error: $e');
                                return Icon(
                                  Icons.access_time,
                                  size: 20,
                                  color: AppColors.primary,
                                );
                              }
                            },
                          ),
                          const SizedBox(width: 6),
                          Text(
                            time,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
