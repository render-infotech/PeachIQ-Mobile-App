import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/routes.dart';
import 'package:peach_iq/loading/shimmer_gate.dart';
import 'package:peach_iq/screens/auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool unavailable = true;

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
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          children: [
            Consumer<ProfileProvider>(
              builder: (context, p, _) => HeaderCard(
                name: p.fullName,
                subtitle: p.email.isNotEmpty ? p.email : null,
                pageheader: 'Edit profile',
                onSignOut: () => _handleSignOut(context),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section header
                    Padding(
                      padding: const EdgeInsets.only(
                          bottom: 0, top: 10, left: 12, right: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Padding(
                          //   padding: EdgeInsets.symmetric(horizontal: 8),
                          //   child: Text(
                          //     'Edit Profile',
                          //     style: TextStyle(
                          //       fontSize: 19.2,
                          //       fontWeight: FontWeight.w600,
                          //       color: Color(0xFF2C2C2C),
                          //       fontFamily: 'Manrope',
                          //       letterSpacing: 0.5,
                          //     ),
                          //   ),
                          // ),
                          SizedBox(
                            width: 190,
                          ),
                          // GestureDetector(
                          //   onTap: () {
                          //     AppNavigator.toGeneralSettings(context);
                          //   },
                          //   child: const Icon(
                          //     CupertinoIcons.gear,
                          //     size: 25,
                          //     color: Color(0xFF2C2C2C),
                          //   ),
                          // ),
                        ],
                      ),
                    ),

                    // Card group
                    _ProfileCardGroup(
                      children: [
                        _ProfileTile(
                          color: const Color(0xFF17C964),
                          icon: CupertinoIcons.pencil,
                          iconSize: 26,
                          title: 'Change Password',
                          subtitle: null,
                          onTap: () {},
                        ),
                        // divider,
                        SizedBox(
                          height: 8,
                        ),
                        _ProfileTile(
                          color: Colors.black,
                          icon: Icons.email_outlined,
                          iconSize: 26,
                          title: 'Email',
                          subtitle: '123456789@gmail.com',
                          onTap: () {},
                        ),
                        SizedBox(
                          height: 8,
                        ),

                        // CHANGED: yellow background + black phone icon
                        _ProfileTile(
                          color: const Color(0xFFFFB020), // yellow avatar bg
                          icon: CupertinoIcons.phone_fill,
                          iconSize: 26,
                          iconColor: Colors.black, // black glyph
                          title: 'Mobile Number',
                          subtitle: '+1-555-555-5555',
                          onTap: () {},
                        ),

                        SizedBox(
                          height: 8,
                        ),

                        // Address tile: light background + purple house glyph
                        _ProfileTile(
                          color: const Color.fromARGB(255, 230, 231, 241),
                          icon: CupertinoIcons.house_fill,
                          iconSize: 26,
                          iconColor: const Color(0xFF7C4DFF),
                          title: 'Address',
                          subtitle: '1234, John Street, Toronto, M1L 1V3',
                          onTap: () {},
                        ),

                        SizedBox(
                          height: 8,
                        ),
                        _ProfileTile(
                          color: const Color(0xFFFF7043),
                          icon: CupertinoIcons.doc_text_fill,
                          iconSize: 26,
                          title: 'Documents',
                          subtitle: 'Upload required documents',
                          onTap: () {},
                        ),

                        // NEW: Switch Profile option
                        const SizedBox(height: 8),
                        _ProfileTile(
                          color: const Color(0xFF3B82F6), // blue avatar bg
                          icon: Icons.switch_account, // switch profile icon
                          iconSize: 26,
                          title: 'Switch Profile',
                          subtitle: 'Change to another profile',
                          onTap: () {
                            // TODO: implement switch profile
                          },
                        ),
                      ],
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

// Group container styled like Home cards
class _ProfileCardGroup extends StatelessWidget {
  final List<Widget> children;
  const _ProfileCardGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: children),
    );
  }
}

// Standard tile with optional SVG support and icon color override
class _ProfileTile extends StatelessWidget {
  final Color? color; // Circle background
  final IconData? icon; // For Icon-based tiles
  final Color? iconColor; // Icon color override
  final double? iconSize; // Icon size override
  final String? svgPath; // For SVG-based tiles
  final double? svgWidth; // Optional SVG size
  final double? svgHeight; // Optional SVG size
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _ProfileTile({
    this.color,
    this.icon,
    this.iconColor,
    this.svgPath,
    this.svgWidth,
    this.svgHeight,
    this.title,
    this.subtitle,
    this.onTap,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final leading = CircleAvatar(
      radius: 26,
      backgroundColor: color ?? Colors.grey, // badge fill
      child: svgPath != null
          ? SizedBox(
              width: svgWidth ?? 20,
              height: svgHeight ?? 20,
              child: SvgPicture.asset(
                svgPath!,
                fit: BoxFit.contain,
                // Optional: colorFilter: ColorFilter.mode(iconColor ?? Colors.white, BlendMode.srcIn),
              ),
            )
          : Icon(
              icon ?? Icons.help_outline,
              color: iconColor ?? Colors.white, // icon tint
              size: iconSize ?? 20,
            ),
    );

    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 1),
                  Text(
                    title ?? 'Title',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF2C2C2C),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14.5,
                        color: AppColors.black,
                        fontWeight: FontWeight.w400,
                        fontFamily: 'Manrope',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
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
    );
  }
}
