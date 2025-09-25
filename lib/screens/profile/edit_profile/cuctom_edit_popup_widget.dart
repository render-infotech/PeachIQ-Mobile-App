import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';

class EditProfilePopup extends StatefulWidget {
  final String title;
  final String currentValue;
  final String hintText;
  final Function(String) onSave;
  final TextInputType? keyboardType;
  final int? maxLines;

  const EditProfilePopup({
    Key? key,
    required this.title,
    required this.currentValue,
    required this.hintText,
    required this.onSave,
    this.keyboardType,
    this.maxLines = 1,
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
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Edit ${widget.title}',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppColors.black,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(
                      Icons.close,
                      color: AppColors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _controller,
                keyboardType: widget.keyboardType ?? TextInputType.text,
                maxLines: widget.maxLines,
                style: TextStyle(color: AppColors.black),
                decoration: InputDecoration(
                  labelText: widget.title,
                  hintText: widget.hintText,
                  labelStyle: TextStyle(color: AppColors.black),
                  hintStyle: TextStyle(color: AppColors.black.withOpacity(0.5)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: AppColors.black.withOpacity(0.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide:
                        BorderSide(color: AppColors.black.withOpacity(0.3)),
                  ),
                  filled: true,
                  fillColor: AppColors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '${widget.title} cannot be empty';
                  }

                  // Email validation
                  if (widget.title.toLowerCase() == 'email') {
                    final emailRegex =
                        RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                    if (!emailRegex.hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                  }

                  if (widget.title.toLowerCase().contains('mobile') ||
                      widget.title.toLowerCase().contains('phone')) {
                    if (value.length < 10) {
                      return 'Please enter a valid mobile number';
                    }
                  }

                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Cancel Button
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.black,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Save Button
                  ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        widget.onSave(_controller.text.trim());
                        Navigator.of(context).pop();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.AppSelectedGreen,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function to show the popup
void showEditProfilePopup({
  required BuildContext context,
  required String title,
  required String currentValue,
  required String hintText,
  required Function(String) onSave,
  TextInputType? keyboardType,
  int? maxLines,
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
      );
    },
  );
}
