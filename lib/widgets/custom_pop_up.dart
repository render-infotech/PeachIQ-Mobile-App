import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/animated_button.dart';
import 'package:peach_iq/widgets/text_button.dart';

class AppPopup extends StatefulWidget {
  final String title;
  final String? message;
  final Widget? content;

  final String primaryText;
  final VoidCallback? onPrimary;

  final String? secondaryText;
  final VoidCallback? onSecondary;

  final bool showClose;
  final EdgeInsetsGeometry contentPadding;

  const AppPopup({
    super.key,
    required this.title,
    this.message,
    this.content,
    this.primaryText = 'OK',
    this.onPrimary,
    this.secondaryText,
    this.onSecondary,
    this.showClose = true,
    this.contentPadding = const EdgeInsets.fromLTRB(20, 16, 20, 12),
  });

  @override
  State<AppPopup> createState() => _AppPopupState();
}

class _AppPopupState extends State<AppPopup> {
  // null = none, 0 = secondary, 1 = primary
  int? _pressed;

  void _setPressed(int? i) {
    if (_pressed == i) return;
    setState(() => _pressed = i);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white, // Entire popup uses white surface
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 280, maxWidth: 400),
        child: Padding(
          padding: widget.contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        fontFamily: 'Manrope',
                      ),
                    ),
                  ),
                  if (widget.showClose)
                    IconButton(
                      splashRadius: 22,
                      onPressed: () => Navigator.of(context).maybePop(),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.black54,
                        size: 22,
                      ),
                    ),
                ],
              ),

              if (widget.message != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.message!,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.35,
                    color: Colors.black87,
                    fontFamily: 'Manrope',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              if (widget.content != null) ...[
                if (widget.message != null) const SizedBox(height: 12),
                if (widget.message == null) const SizedBox(height: 6),
                widget.content!,
              ],

              const SizedBox(height: 16),

              // Actions (equal widths; both primary-styled; only scale animates)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
                child: Row(
                  children: [
                    if (widget.secondaryText != null) ...[
                      Flexible(
                        child: AnimatedChoiceButton(
                          label: widget.secondaryText!,
                          pressed: _pressed == 0,
                          onTapDown: () => _setPressed(0),
                          onTapCancel: () => _setPressed(null),
                          onTapUp: () {
                            _setPressed(null);
                            (widget.onSecondary ??
                                    () => Navigator.of(context).maybePop())
                                .call();
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                    Flexible(
                      child: AnimatedChoiceButton(
                        label: widget.primaryText,
                        pressed: _pressed == 1,
                        onTapDown: () => _setPressed(1),
                        onTapCancel: () => _setPressed(null),
                        onTapUp: () {
                          _setPressed(null);
                          (widget.onPrimary ??
                                  () => Navigator.of(context).maybePop())
                              .call();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Helper to show the popup easily
Future<T?> showAppPopup<T>(
  BuildContext context, {
  required String title,
  String? message,
  Widget? content,
  String primaryText = 'OK',
  VoidCallback? onPrimary,
  String? secondaryText,
  VoidCallback? onSecondary,
  bool barrierDismissible = true,
  bool showClose = true,
}) {
  return showDialog<T>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) => AppPopup(
      title: title,
      message: message,
      content: content,
      primaryText: primaryText,
      onPrimary: onPrimary,
      secondaryText: secondaryText,
      onSecondary: onSecondary,
      showClose: showClose,
    ),
  );
}
