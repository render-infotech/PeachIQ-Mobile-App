// Removed: dart:io, dart:typed_data, dart:ui, flutter/rendering.dart, path_provider, share_plus
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Kept for Clipboard
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:peach_iq/Models/profile_model.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/Providers/profile_update_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QRCodeWidget extends StatefulWidget {
  final double? size;
  final Color? foregroundColor;
  final Color? backgroundColor;

  const QRCodeWidget({
    super.key,
    this.size,
    this.foregroundColor,
    this.backgroundColor,
  });

  @override
  State<QRCodeWidget> createState() => _QRCodeWidgetState();
}

class _QRCodeWidgetState extends State<QRCodeWidget> {
  String? caregiverIdentifier;

  @override
  void initState() {
    super.initState();
    _loadCaregiverIdentifier();
  }

  Future<void> _loadCaregiverIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    String? identifier = prefs.getString('caregiver_identifier');
    
    // If identifier is not in SharedPreferences, fetch it from API
    if (identifier == null || identifier.isEmpty) {
      try {
        final profileUpdateProvider = Provider.of<ProfileUpdateProvider>(context, listen: false);
        final profileData = await profileUpdateProvider.fetchCaregiverDetailsForUpdate();
        if (profileData != null) {
          identifier = profileData.caregiverDetails.caregiverIdentifier;
        }
      } catch (e) {
        // Handle error silently, identifier will remain null
      }
    }
    
    if (mounted) {
      setState(() {
        caregiverIdentifier = identifier;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;

        if (profile == null) {
          return Container(
            width: widget.size ?? 160,
            height: widget.size ?? 160,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(
              child: Text(
                'Loading...',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          );
        }

        final qrData = _createQRData(profile, caregiverIdentifier);

        return QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: widget.size ?? 160,
          dataModuleStyle: QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: widget.foregroundColor ?? Colors.black,
          ),
          eyeStyle: QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: widget.foregroundColor ?? Colors.black,
          ),
          backgroundColor: widget.backgroundColor ?? Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
        );
      },
    );
  }

  String _createQRData(Profile profile, String? caregiverIdentifier) {
    // Creates a formatted, human-readable string using caregiver identifier instead of user ID
    final List<String> lines = [
      '--- User Profile ---',
      'Name: ${profile.firstName} ${profile.lastName}',
      'Email: ${profile.email}',
      'Caregiver ID: ${caregiverIdentifier ?? 'Loading...'}',
      'Role: ${profile.dashboard}',
    ];
    return lines.join('\n');
  }
}

//
// --- THIS WIDGET IS NOW A STATELESSWIDGET ---
//
class QRCodeDialog extends StatefulWidget {
  const QRCodeDialog({super.key});

  @override
  State<QRCodeDialog> createState() => _QRCodeDialogState();
}

class _QRCodeDialogState extends State<QRCodeDialog> {
  String? caregiverIdentifier;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCaregiverIdentifier();
  }

  Future<void> _loadCaregiverIdentifier() async {
    final prefs = await SharedPreferences.getInstance();
    String? identifier = prefs.getString('caregiver_identifier');
    
    // If identifier is not in SharedPreferences, fetch it from API
    if (identifier == null || identifier.isEmpty) {
      try {
        final profileUpdateProvider = Provider.of<ProfileUpdateProvider>(context, listen: false);
        final profileData = await profileUpdateProvider.fetchCaregiverDetailsForUpdate();
        if (profileData != null) {
          identifier = profileData.caregiverDetails.caregiverIdentifier;
        }
      } catch (e) {
        // Handle error silently, identifier will remain null
      }
    }
    
    if (mounted) {
      setState(() {
        caregiverIdentifier = identifier;
        isLoading = false;
      });
    }
  }

  /// Copies the QR code's text content to the clipboard
  Future<void> _copyQrText(BuildContext context) async {
    // 1. Get the profile (listen: false because we're in a function)
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile == null) return;

    // 2. Re-create the same formatted string using caregiver identifier
    final List<String> lines = [
      '--- User Profile ---',
      'Name: ${profile.firstName} ${profile.lastName}',
      'Email: ${profile.email}',
      'Caregiver ID: ${caregiverIdentifier ?? 'Loading...'}',
      'Role: ${profile.dashboard}',
    ];
    final String qrData = lines.join('\n');

    // 3. Save to clipboard
    await Clipboard.setData(ClipboardData(text: qrData));

    // 4. Show confirmation and close dialog
    // Check if the widget is still mounted before interacting with context
    if (context.mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile details copied to clipboard!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(12)),
      
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black
              ),
            ),
            const SizedBox(height: 12),
            // Show loading or QR code based on state
            isLoading
                ? Container(
                    width: 170,
                    height: 170,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  )
                : const QRCodeWidget(
                    size: 170,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
            const SizedBox(height: 16),
            const Text(
              'Scan this QR code to view your profile information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: 10),
            // Simplified the button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close',style: TextStyle(color: AppColors.primary,fontWeight: FontWeight.w700),),
                ),
                // GestureDetector(
                //   onTap: () => _copyQrText(context),
                //   child: const Text('Copy Text', style: TextStyle(color: AppColors.primary,fontWeight: FontWeight.w700),),
                // ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


