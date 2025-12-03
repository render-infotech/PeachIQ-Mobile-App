import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';
import 'package:peach_iq/Providers/scheduled_shifts_provider.dart';
import 'package:peach_iq/Providers/work_analysis_provider.dart';
import 'package:peach_iq/QR/qr_code_widget.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/routes.dart';
import 'package:peach_iq/constants/app_config.dart';
// New imports for functionality
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Instance for handling in-app reviews
  final InAppReview _inAppReview = InAppReview.instance;

  void _handleRateApp() async {
    try {
      // Check if the InAppReview library is available on the current device
      if (await _inAppReview.isAvailable()) {
        // PRO METHOD: openStoreListing() is safer for buttons.
        // It takes the user directly to the store page to leave a review.
        // It avoids the strict quotas of requestReview().
        await _inAppReview.openStoreListing(
          appStoreId: AppConfig.appStoreId, 
        );
      } else {
        // Fallback: If the native library fails, try opening the URL manually
        _launchStoreUrl();
      }
    } catch (e) {
      debugPrint('Error launching store listing: $e');
      // Final Fallback: Try launching the browser URL
      _launchStoreUrl();
    }
  }

  void _launchStoreUrl() async {
    try {
      final uri = Uri.parse(AppConfig.storeUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showErrorDialog('Unable to open app store. Please try again later.');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Unable to open app store. Please try again later.');
      }
    }
  }

  void _handleShareApp() async {
    try {
      // Uses share_plus to open the native share sheet (WhatsApp, Messages, etc.)
      await Share.share(
        AppConfig.shareMessage,
        subject: 'Check out ${AppConfig.appName}!', // Subject helps for Email apps
      );
    } catch (e) {
      debugPrint('Error sharing app: $e');
      if (mounted) {
        _showErrorDialog('Unable to share app. Please try again later.');
      }
    }
  }

  void _showComingSoonDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: Text(
          title,
          style: const TextStyle(color: AppColors.black),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        title: const Text(
          'Error',
          style: TextStyle(color: AppColors.black),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.black),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'OK',
              style: TextStyle(color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              title: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.black),
              ),
              content: const Text(
                'Are you sure you want to sign out?',
                style: TextStyle(color: AppColors.black),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    try {
                      final profileProvider =
                          Provider.of<ProfileProvider>(context, listen: false);
                      final availableShiftsProvider =
                          Provider.of<AvailableShiftsProvider>(context,
                              listen: false);
                      final scheduledShiftsProvider =
                          Provider.of<SchedulesShiftsProvider>(context,
                              listen: false);
                      final workAnalysisProvider =
                          Provider.of<WorkAnalysisProvider>(context,
                              listen: false);

                      await profileProvider.logout();
                      availableShiftsProvider.clear();
                      scheduledShiftsProvider.clear();
                      workAnalysisProvider.clear();

                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    } catch (e) {
                      debugPrint('Error during sign out: $e');
                      if (mounted) {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      }
                    }
                  },
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    final divider = Divider(
      height: 1,
      thickness: 0.7,
      color: Colors.black.withOpacity(0.06),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<ProfileProvider>(
              builder: (context, p, _) => HeaderCard(
                name: p.fullName,
                subtitle: p.email.isNotEmpty ? p.email : null,
                onQrCodeTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const QRCodeDialog(),
                    );
                  },
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    _SettingsTile(
                      leadingColor: const Color(0xFF17C964),
                      leadingIcon: CupertinoIcons.pencil,
                      title: 'Edit Profile',
                      onTap: () {
                        AppNavigator.pushNamed(
                            context, AppRoutes.generalSettings);
                      },
                    ),
                    const SizedBox(height: 16),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        'General Settings',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF2C2C2C),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _SettingsTile(
                      leadingColor: const Color(0xFFD7D7F8),
                      leadingIcon: CupertinoIcons.question_circle_fill,
                      title: 'About',
                      onTap: () {
                        AppNavigator.toAbout(context);
                      },
                    ),
                    divider,
                    _SettingsTile(
                      leadingColor: const Color(0xFF2962FF),
                      leadingIcon: CupertinoIcons.info_circle_fill,
                      title: 'Terms & Conditions',
                      onTap: () {
                        AppNavigator.toTermsAndConditions(context);
                      },
                    ),
                    divider,
                    _SettingsTile(
                      leadingColor: const Color(0xFFFF5252),
                      leadingIcon: CupertinoIcons.lock_fill,
                      title: 'Privacy Policy',
                      onTap: () {
                        AppNavigator.toPrivacyPolicy(context);
                      },
                    ),
                    divider,
                    _SettingsTile(
                      leadingColor: const Color(0xFF7C4DFF),
                      leadingIcon: CupertinoIcons.star_fill,
                      title: 'Rate This App',
                      onTap: _handleRateApp,
                    ),
                    divider,
                    _SettingsTile(
                      leadingColor: const Color(0xFFFF7043),
                      leadingIcon: CupertinoIcons.share_solid,
                      title: 'Share This App',
                      onTap: _handleShareApp,
                    ),
                    divider,
                    _SettingsTile(
                      leadingColor: const Color(0xFFFF5252),
                      leadingIcon: CupertinoIcons.square_arrow_right,
                      title: 'Log Out',
                      onTap: () => _handleSignOut(context),
                    ),
                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final Color leadingColor;
  final IconData leadingIcon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.leadingColor,
    required this.leadingIcon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: leadingColor,
                child: Icon(leadingIcon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2C2C2C),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.right_chevron,
                size: 18,
                color: Color(0xFF8C8C8C),
              ),
            ],
          ),
        ),
      ),
    );
  }
}