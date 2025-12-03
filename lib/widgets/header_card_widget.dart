import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/shared/themes/typography.dart';

class HeaderCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? pageheader;
  final bool isLoading;
  final VoidCallback? onQrCodeTap;

  const HeaderCard({
    super.key,
    required this.name,
    this.subtitle,
    this.pageheader,
    this.isLoading = false,
    this.onQrCodeTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
      ),
      child: _buildNormalContent(),
    );
  }

  Widget _buildNormalContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 14,
                  ),
                  Text(
                    'Welcome, ${name.isNotEmpty ? '$name' : ''}!',
                    style: AppTypography.h5.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                      shadows: [
                        Shadow(
                          offset: const Offset(0.5, 0.5),
                          blurRadius: 1.0,
                          color: Colors.black.withValues(alpha: 0.3),
                        ),
                      ],
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600, // Increased weight for better visibility
                        shadows: [
                          Shadow(
                            offset: const Offset(0.5, 0.5),
                            blurRadius: 1.0,
                            color: Colors.black.withValues(alpha: 0.25),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 16),
            if (onQrCodeTap != null)
              GestureDetector(
                onTap: onQrCodeTap,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.qr_code,
                        color: AppColors.white,
                        size: 20,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "QR Code",
                        style: AppTypography.caption.copyWith(
                          color: AppColors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(
                              offset: const Offset(0.5, 0.5),
                              blurRadius: 1.0,
                              color: Colors.black.withValues(alpha: 0.25),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (pageheader != null && pageheader!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            pageheader!,
            style: AppTypography.h5.copyWith(
              color: AppColors.white,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(
                  offset: const Offset(0.5, 0.5),
                  blurRadius: 1.0,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
