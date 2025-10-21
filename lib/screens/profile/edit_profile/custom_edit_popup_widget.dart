import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class EditProfilePopup extends StatefulWidget {
  final String title;
  final String currentValue;
  final String hintText;
  final Function(String) onSave;
  final TextInputType? keyboardType;
  final int? maxLines;
  final String? prefixText;

  const EditProfilePopup({
    Key? key,
    required this.title,
    required this.currentValue,
    required this.hintText,
    required this.onSave,
    this.keyboardType,
    this.maxLines = 1,
    this.prefixText,
  }) : super(key: key);

  @override
  State<EditProfilePopup> createState() => _EditProfilePopupState();
}

class _EditProfilePopupState extends State<EditProfilePopup> {
  late TextEditingController _controller;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      // KEY FIX 1: Wrap content in a SizedBox to constrain the width
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          // KEY FIX 2: Use a SingleChildScrollView to prevent overflow from the keyboard
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // Keep the dialog compact
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Edit ${widget.title}',
                        style: TextStyle(
                            fontSize: 15,
                            color: AppColors.black,
                            fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _controller,
                    keyboardType: widget.keyboardType ?? TextInputType.text,
                    maxLines: widget.maxLines,
                    style: TextStyle(color: AppColors.black, fontSize: 16),
                    decoration: InputDecoration(
                      prefixIcon: widget.prefixText != null
                          ? Padding(
                              padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
                              child: Text(
                                widget.prefixText!,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black.withOpacity(0.7),
                                ),
                              ),
                            )
                          : null,
                      labelText: widget.title,
                      hintText: widget.hintText,
                      labelStyle: TextStyle(color: AppColors.black),
                      hintStyle:
                          TextStyle(color: AppColors.black.withOpacity(0.5)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.3)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                            color: AppColors.black.withOpacity(0.3)),
                      ),
                      filled: true,
                      fillColor: AppColors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return '${widget.title} cannot be empty';
                      }

                      // Only apply length validation for phone numbers
                      if (widget.keyboardType == TextInputType.phone &&
                          value.length < 10) {
                        return 'Please enter a valid mobile number';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                        ),
                        child: const Text(
                          'Cancel',
                          style:
                              TextStyle(fontSize: 14, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            widget.onSave(_controller.text.trim());
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        child: const Text(
                          'Save',
                          style: TextStyle(
                              fontSize: 14, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

void showEditProfilePopup({
  required BuildContext context,
  required String title,
  required String currentValue,
  required String hintText,
  required Function(String) onSave,
  TextInputType? keyboardType,
  int? maxLines,
  String? prefixText,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return EditProfilePopup(
        title: title,
        currentValue: currentValue,
        hintText: hintText,
        onSave: onSave,
        keyboardType: keyboardType,
        maxLines: maxLines,
        prefixText: prefixText,
      );
    },
  );
}