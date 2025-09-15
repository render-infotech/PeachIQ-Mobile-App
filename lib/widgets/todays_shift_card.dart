// lib/widgets/todays_shift_card.dart
import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class TodaysShiftCard extends StatelessWidget {
  const TodaysShiftCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFFAFAFA),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 40,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Subtle gradient accent
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF36856), Color(0xFFFF8A65)],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with icon and facility name
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF36856), Color(0xFFFF8A65)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFF36856).withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.business_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Villa Columbo',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                                letterSpacing: -0.3,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Healthcare Facility',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Date
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    iconColor: AppColors.primary,
                    iconBg: AppColors.primary.withOpacity(0.1),
                    title: 'Date',
                    content: _buildDateText(),
                  ),
                  const SizedBox(height: 10),

                  // Location
                  const _InfoRow(
                    icon: Icons.location_on_outlined,
                    iconColor: Color(0xFFF36856),
                    iconBg: Color(0x1AF36856),
                    title: 'Location',
                    content: Text(
                      '8th Floor - West Wing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Duration
                  const _InfoRow(
                    icon: Icons.access_time_outlined,
                    iconColor: Color(0xFFF36856),
                    iconBg: Color(0x1AF36856),
                    title: 'Duration',
                    content: Row(
                      children: [
                        Text(
                          '4:00 PM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF36856),
                          ),
                        ),
                        Text(
                          ' - ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.black,
                          ),
                        ),
                        Text(
                          '12:00 AM',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFF36856),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          '(8 hours)',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildDateText() {
    return RichText(
      text: TextSpan(
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF374151),
        ),
        children: [
          TextSpan(text: 'Monday, June 16'),
          WidgetSpan(
            alignment: PlaceholderAlignment.top,
            child: Text(
              'th',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          TextSpan(text: ' 2025'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final Widget content;

  const _InfoRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              content,
            ],
          ),
        ),
      ],
    );
  }
}
