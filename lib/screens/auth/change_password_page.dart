import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      final provider = context.read<ProfileProvider>();
      final messenger = ScaffoldMessenger.of(context);
      final navigator = Navigator.of(context);

      final success = await provider.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );

      if (mounted) {
        if (success) {
          messenger.showSnackBar(
            const SnackBar(
              content: Text(
                'Password changed successfully!',
                style: TextStyle(color: AppColors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );
          navigator.pop();
        } else {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage ?? 'Failed to change password.',
                style: TextStyle(color: AppColors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: SafeArea(
          child: Column(
            children: [
              Consumer<ProfileProvider>(
                builder: (context, p, _) => HeaderCard(
                  name: p.fullName,
                  subtitle: p.email.isNotEmpty ? p.email : null,
                  pageheader: 'Change Password',
                  onSignOut: () {},
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPasswordField(
                            controller: _oldPasswordController,
                            labelText: 'Current Password',
                            isVisible: _isOldPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() => _isOldPasswordVisible =
                                  !_isOldPasswordVisible);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your current password.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            controller: _newPasswordController,
                            labelText: 'New Password',
                            isVisible: _isNewPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() => _isNewPasswordVisible =
                                  !_isNewPasswordVisible);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildPasswordField(
                            controller: _confirmPasswordController,
                            labelText: 'Confirm New Password',
                            isVisible: _isConfirmPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() => _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please confirm your new password.';
                              }
                              if (value != _newPasswordController.text) {
                                return 'Passwords do not match.';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 32),
                          Consumer<ProfileProvider>(
                            builder: (context, provider, child) {
                              return SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: provider.isLoading
                                      ? null
                                      : _handleChangePassword,
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16),
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: provider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2.5,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Text(
                                          'Update Password',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String labelText,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: !isVisible,
      // MODIFIED: Added this style to set the input text color.
      style: const TextStyle(color: AppColors.black),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Color(0xFF475569)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        suffixIcon: IconButton(
          icon: Icon(
            isVisible ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onVisibilityToggle,
        ),
      ),
      validator: validator,
    );
  }
}
