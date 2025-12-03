// lib/widgets/animated_choice_button.dart
import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class AnimatedChoiceButton extends StatelessWidget {
  final String label;
  final bool pressed;
  final VoidCallback onTapDown;
  final VoidCallback onTapCancel;
  final VoidCallback onTapUp;

  // Optional overrides
  final Color backgroundColor;
  final Color textColor;
  final double pressedScale;
  final double minHeight;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;

  const AnimatedChoiceButton({
    super.key,
    required this.label,
    required this.pressed,
    required this.onTapDown,
    required this.onTapCancel,
    required this.onTapUp,
    this.backgroundColor = AppColors.primary,
    this.textColor = Colors.white,
    this.pressedScale = 1.04,
    this.minHeight = 40,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTapDown(),
      onTapCancel: onTapCancel,
      onTapUp: (_) => onTapUp(),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        scale: pressed ? pressedScale : 1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          constraints: BoxConstraints(minHeight: minHeight),
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'NunitoSans',
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
