import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:peach_iq/Providers/profile_update_provider.dart';
import 'package:peach_iq/QR/qr_code_widget.dart';
import 'package:peach_iq/models/caregiver_profile_model.dart';
import 'package:peach_iq/screens/profile/edit_profile/address_edit_widget.dart';
import 'package:peach_iq/screens/profile/edit_profile/custom_edit_popup_widget.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/routes.dart';
import 'package:peach_iq/constants/loading/shimmer_gate.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  ProfileData? _detailedProfileData;
  bool _isFetchingDetails = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetails();
    });
  }

  Future<void> _fetchDetails() async {
    setState(() {
      _isFetchingDetails = true;
    });
    final provider = context.read<ProfileUpdateProvider>();
    final data = await provider.fetchCaregiverDetailsForUpdate();
    if (mounted) {
      setState(() {
        _detailedProfileData = data;
        _isFetchingDetails = false;
      });
    }
  }

  String _formatAddress(CaregiverDetails? details) {
    if (details == null) {
      return 'No address available';
    }
    final parts = [
      details.addressLine,
      details.city?.cityName,
      details.state?.stateName,
      details.country?.countryName,
      details.postalCode,
    ];
    final validParts = parts.where((p) => p != null && p.trim().isNotEmpty);
    return validParts.isEmpty ? 'No address provided' : validParts.join(', ');
  }

  @override
  Widget build(BuildContext context) {
    final headerProvider = context.watch<ProfileProvider>();
    final updateProvider = context.watch<ProfileUpdateProvider>();

    final profileData = _detailedProfileData;
    final caregiverDetails = profileData?.caregiverDetails;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(children: [
          Stack(
            children: [
              HeaderCard(
                name: headerProvider.fullName,
                subtitle: headerProvider.email,
                pageheader: '       Edit profile',
                onQrCodeTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const QRCodeDialog(),
                    );
                  },
              ),
              Positioned(
                left: 4,
                bottom: 3,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios,
                      color: AppColors.white, size: 22),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
          Expanded(
            child: ShimmerGate(
              isLoading: _isFetchingDetails,
              child: profileData == null
                  ? Center(
                      child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                              'Error: ${updateProvider.errorMessage ?? "Could not load profile details."}'),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: _fetchDetails,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    ))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 18),
                          _ProfileCardGroup(
                            children: [
                              _ProfileTile(
                                color: Colors.black,
                                icon: Icons.email_outlined,
                                iconSize: 26,
                                title: 'Email',
                                subtitle: profileData.email ?? 'Not available',
                              ),
                              const SizedBox(height: 8),
                              _ProfileTile(
                                color: const Color(0xFFFFB020),
                                icon: CupertinoIcons.phone_fill,
                                iconSize: 26,
                                iconColor: Colors.black,
                                title: 'Mobile Number',
                                subtitle:
                                    '${caregiverDetails?.phone1Code ?? ''} ${caregiverDetails?.phone1 ?? ''}'
                                        .trim(),
                                onTap: () {
                                  if (caregiverDetails == null) return;
                                  showEditProfilePopup(
                                    context: context,
                                    title: 'Mobile Number',
                                    prefixText:
                                        caregiverDetails.phone1Code ?? '',
                                    currentValue: caregiverDetails.phone1 ?? '',
                                    hintText: 'Enter your mobile number',
                                    keyboardType: TextInputType.phone,
                                    onSave: (newMobile) async {
                                      final success = await context
                                          .read<ProfileUpdateProvider>()
                                          .updatePhoneNumber(
                                            context: context,
                                            profileData: profileData,
                                            newPhoneNumber: newMobile,
                                          );

                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(success
                                                ? 'Mobile number updated!'
                                                : updateProvider.errorMessage ??
                                                    'Update failed.'),
                                            backgroundColor: success
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        );
                                        if (success) {
                                          _fetchDetails();
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _ProfileTile(
                                color: const Color.fromARGB(255, 230, 231, 241),
                                icon: CupertinoIcons.house_fill,
                                iconSize: 26,
                                iconColor: const Color(0xFF7C4DFF),
                                title: 'Address',
                                subtitle: _formatAddress(caregiverDetails),
                                onTap: () {
                                  final details = caregiverDetails;
                                  if (details == null) return;

                                  final currentAddress = AddressData(
                                    country: details.country?.countryName ?? '',
                                    stateProvince:
                                        details.state?.stateName ?? '',
                                    city: details.city?.cityName ?? '',
                                    addressLine: details.addressLine ?? '',
                                    postalCode: details.postalCode ?? '',
                                    location: details.location ?? '',
                                    about: details.about ?? '',
                                  );
                                  showAddressEditPopup(
                                    context: context,
                                    currentAddress: currentAddress,
                                    onSave: ({
                                      required countryId,
                                      required stateId,
                                      required cityId,
                                      required addressLine,
                                      required postalCode,
                                      required location,
                                      required about,
                                    }) async {
                                      final updateProvider =
                                          context.read<ProfileUpdateProvider>();
                                      final success =
                                          await updateProvider.updateAddress(
                                        context: context,
                                        profileData: profileData,
                                        newCountryId: countryId,
                                        newStateId: stateId,
                                        newCityId: cityId,
                                        newAddressLine: addressLine,
                                        newPostalCode: postalCode,
                                        newLocation: location,
                                        newAbout: about,
                                      );

                                      if (mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(success
                                                ? 'Address updated successfully!'
                                                : updateProvider.errorMessage ??
                                                    'Update failed.'),
                                            backgroundColor: success
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        );
                                        if (success) {
                                          _fetchDetails();
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 8),
                              _ProfileTile(
                                color: const Color(0xFF17C964),
                                icon: CupertinoIcons.pencil,
                                iconSize: 26,
                                title: 'Change Password',
                                onTap: () {
                                  AppNavigator.toChangePassword(context);
                                },
                              ),
                              const SizedBox(height: 8),
                              _ProfileTile(
                                color: const Color(0xFFFF7043),
                                icon: CupertinoIcons.doc_text_fill,
                                iconSize: 26,
                                title: 'Documents',
                                subtitle: 'Upload required documents',
                                onTap: () {
                                  AppNavigator.toDocumentUpload(context);
                                },
                              ),
                              const SizedBox(height: 8),
                              _ProfileTile(
                                color: const Color(0xFF3B82F6),
                                icon: Icons.switch_account,
                                iconSize: 26,
                                title: 'Switch Profile',
                                subtitle: 'Change to another profile',
                                onTap: () {
                                  // TODO: Implement switch profile logic
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                      ),
                    ),
            ),
          )
        ]),
      ),
    );
  }
}

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

class _ProfileTile extends StatelessWidget {
  final Color? color;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final String? title;
  final String? subtitle;
  final VoidCallback? onTap;

  const _ProfileTile({
    this.color,
    this.icon,
    this.iconColor,
    this.title,
    this.subtitle,
    this.onTap,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final leading = CircleAvatar(
      radius: 26,
      backgroundColor: color ?? Colors.grey,
      child: Icon(
        icon ?? Icons.help_outline,
        color: iconColor ?? Colors.white,
        size: iconSize ?? 20,
      ),
    );

    return InkWell(
      onTap: onTap,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF2C2C2C),
                      fontFamily: 'Manrope',
                    ),
                  ),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: AppColors.black,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Manrope',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (onTap != null)
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
