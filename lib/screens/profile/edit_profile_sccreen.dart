import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:peach_iq/screens/auth/change_password_page.dart';
import 'package:peach_iq/screens/profile/address_edit_widget.dart';
import 'package:peach_iq/screens/profile/cuctom_edit_popup_widget.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (route) => false,
                );
              }
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
                          SizedBox(
                            width: 190,
                          ),
                        ],
                      ),
                    ),

                    _ProfileCardGroup(
                      children: [
                        SizedBox(
                          height: 8,
                        ),
                        _ProfileTile(
                          color: Colors.black,
                          icon: Icons.email_outlined,
                          iconSize: 26,
                          title: 'Email',
                          subtitle: '123456789@gmail.com',
                          onTap: () {
                            showEditProfilePopup(
                              context: context,
                              title: 'Email',
                              currentValue:
                                  '123456789@gmail.com', // You can get this from a variable/state
                              hintText: 'Enter your email address',
                              keyboardType: TextInputType.emailAddress,
                              onSave: (newEmail) {
                                // Handle the save logic here
                                print('New email: $newEmail');

                                // Update your state/database/API call here
                                // Example:
                                // setState(() {
                                //   userEmail = newEmail;
                                // });

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Email updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          },
                        ),
                        SizedBox(
                          height: 8,
                        ),

                        _ProfileTile(
                          color: const Color(0xFFFFB020),
                          icon: CupertinoIcons.phone_fill,
                          iconSize: 26,
                          iconColor: Colors.black,
                          title: 'Mobile Number',
                          subtitle: '+1-555-555-5555',
                          onTap: () {
                            showEditProfilePopup(
                              context: context,
                              title: 'Mobile Number',
                              currentValue: '+1-555-555-5555',
                              hintText: 'Enter your mobile number',
                              keyboardType: TextInputType.phone,
                              onSave: (newMobile) {
                                print('New mobile: $newMobile');

                                // Update your state/database/API call here
                                // Example:
                                // setState(() {
                                //   userMobile = newMobile;
                                // });

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Mobile number updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        SizedBox(
                          height: 8,
                        ),

                        _ProfileTile(
                          color: const Color.fromARGB(255, 230, 231, 241),
                          icon: CupertinoIcons.house_fill,
                          iconSize: 26,
                          iconColor: const Color(0xFF7C4DFF),
                          title: 'Address',
                          subtitle: '1234, John Street, Toronto, M1L 1V3',
                          onTap: () {
                            // Create current address data from your existing data
                            final currentAddress = AddressData(
                              country: 'CANADA',
                              stateProvince: 'ONTARIO',
                              city: 'AJAX',
                              addressLine: '1234, John Street',
                              postalCode: 'M1L 1V3',
                              location: '', // Add if you have this data
                              about: '', // Add if you have this data
                            );

                            showAddressEditPopup(
                              context: context,
                              currentAddress: currentAddress,
                              onSave: (AddressData newAddressData) {
                                // Handle the save logic here
                                print(
                                    'New address data: ${newAddressData.country}, ${newAddressData.stateProvince}');

                                // Update your state/database/API call here
                                // Example:
                                // setState(() {
                                //   userAddress = '${newAddressData.addressLine}, ${newAddressData.city}, ${newAddressData.postalCode}';
                                // });

                                // Show success message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content:
                                        Text('Address updated successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        SizedBox(
                          height: 8,
                        ),
                        _ProfileTile(
                          color: const Color(0xFF17C964),
                          icon: CupertinoIcons.pencil,
                          iconSize: 26,
                          title: 'Change Password',
                          subtitle: null,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const ChangePasswordScreen(),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 8),
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
                          color: const Color(0xFF3B82F6),
                          icon: Icons.switch_account,
                          iconSize: 26,
                          title: 'Switch Profile',
                          subtitle: 'Change to another profile',
                          onTap: () {},
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
