import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/constants/loading/shimmer_gate.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/routes.dart';

// settings_screen.dart

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool darkMode = false;
  bool mobileLocation = true;

  void _handleSignOut(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Use shared logout method
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              await profileProvider.logout();

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              );
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
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
                onSignOut: () => _handleSignOut(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Edit Profile row
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

                    divider,

                    // Mobile Location switch
                    _SwitchSettingsTile(
                      leadingColor: const Color(0xFFFFB020),
                      leadingIcon: CupertinoIcons.globe,
                      title: 'Mobile Location',
                      value: mobileLocation,
                      onChanged: (v) => setState(() => mobileLocation = v),
                      activeColor: AppColors.AppSelectedGreen,
                    ),

                    divider,

                    // About
                    _SettingsTile(
                      leadingColor: const Color(0xFFD7D7F8),
                      leadingIcon: CupertinoIcons.question_circle_fill,
                      title: 'About',
                      onTap: () {},
                    ),

                    divider,

                    // Terms & Conditions
                    _SettingsTile(
                      leadingColor: const Color(0xFF2962FF),
                      leadingIcon: CupertinoIcons.info_circle_fill,
                      title: 'Terms & Conditions',
                      onTap: () {},
                    ),

                    divider,

                    // Privacy Policy
                    _SettingsTile(
                      leadingColor: const Color(0xFFFF5252),
                      leadingIcon: CupertinoIcons.lock_fill,
                      title: 'Privacy Policy',
                      onTap: () {},
                    ),

                    divider,

                    // Rate This App
                    _SettingsTile(
                      leadingColor: const Color(0xFF7C4DFF),
                      leadingIcon: CupertinoIcons.star_fill,
                      title: 'Rate This App',
                      onTap: () {},
                    ),

                    divider,

                    // Share This App
                    _SettingsTile(
                      leadingColor: const Color(0xFFFF7043),
                      leadingIcon: CupertinoIcons.share_solid,
                      title: 'Share This App',
                      onTap: () {},
                    ),

                    const SizedBox(height: 14),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation is provided by AppShell when routed via AppRoutes.generalSettings
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

class _SwitchSettingsTile extends StatelessWidget {
  final Color leadingColor;
  final IconData leadingIcon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const _SwitchSettingsTile({
    required this.leadingColor,
    required this.leadingIcon,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
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
            CupertinoSwitch(
              value: value,
              activeColor: activeColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
