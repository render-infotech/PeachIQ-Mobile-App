import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart'; // Assuming you have this
import 'package:peach_iq/widgets/header_card_widget.dart'; // Assuming you have this
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart'; // Assuming you have this

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

  void _handleChangePassword() {
    // Dismiss the keyboard
    FocusScope.of(context).unfocus();

    // Validate the form
    if (_formKey.currentState!.validate()) {
      // --- PASSWORD CHANGE LOGIC GOES HERE ---

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // <<< KEY CHANGE: Wrapped the Container with a Material widget to fix the error.
    return Material(
      child: Container(
        color:
            const Color(0xFFF8FAFC), // Sets the background color for this view
        child: SafeArea(
          child: Column(
            children: [
              Consumer<ProfileProvider>(
                builder: (context, p, _) => HeaderCard(
                  name: p.fullName,
                  subtitle: p.email.isNotEmpty ? p.email : null,
                  pageheader: 'Change Password',
                  onSignOut: () {
                    // This can be adapted or removed as needed for this screen
                  },
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
                            labelText: 'Currrent Password',
                            isVisible: _isOldPasswordVisible,
                            onVisibilityToggle: () {
                              setState(() {
                                _isOldPasswordVisible = !_isOldPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your old password.';
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
                              setState(() {
                                _isNewPasswordVisible = !_isNewPasswordVisible;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a new password.';
                              }
                              if (value.length < 8) {
                                return 'Password must be at least 8 characters long.';
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
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
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
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _handleChangePassword,
                              style: ElevatedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                                backgroundColor: AppColors
                                    .primary, // Use your app's primary color
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Update Password',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
