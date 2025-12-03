import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class CompactTextButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const CompactTextButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.white,
        backgroundColor: AppColors.primary, // Keep original primary color
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        fixedSize: const Size.fromHeight(32),
        minimumSize: const Size(0, 28),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700, // Increased weight for better visibility
          letterSpacing: 0.3,
          fontFamily: 'NunitoSans',
        ),
      ),
      onPressed: onPressed,
      child: Text(
        label,
        style: const TextStyle(
          shadows: [
            Shadow(
              offset: Offset(0.5, 0.5),
              blurRadius: 1.0,
              color: Colors.black26,
            ),
          ],
        ),
      ),
    );
  }
}
