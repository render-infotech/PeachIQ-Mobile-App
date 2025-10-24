import 'dart:convert';
// Removed: dart:io, dart:typed_data, dart:ui, flutter/rendering.dart, path_provider, share_plus
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Kept for Clipboard
import 'package:qr_flutter/qr_flutter.dart';
import 'package:peach_iq/Models/profile_model.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:provider/provider.dart';

class QRCodeWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Consumer<ProfileProvider>(
      builder: (context, profileProvider, _) {
        final profile = profileProvider.profile;

        if (profile == null) {
          return Container(
            width: size ?? 160,
            height: size ?? 160,
            decoration: BoxDecoration(
              color: Colors.grey[300],
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

        final qrData = _createQRData(profile);

        return QrImageView(
          data: qrData,
          version: QrVersions.auto,
          size: size ?? 160,
          foregroundColor: foregroundColor ?? Colors.black,
          backgroundColor: backgroundColor ?? Colors.white,
          errorCorrectionLevel: QrErrorCorrectLevel.M,
        );
      },
    );
  }

  String _createQRData(Profile profile) {
    // Creates a formatted, human-readable string
    final List<String> lines = [
      '--- User Profile ---',
      'Name: ${profile.firstName} ${profile.lastName}',
      'Email: ${profile.email}',
      'User ID: ${profile.id}',
      'Role: ${profile.dashboard}',
    ];
    return lines.join('\n');
  }
}

//
// --- THIS WIDGET IS NOW A STATELESSWIDGET ---
//
class QRCodeDialog extends StatelessWidget {
  const QRCodeDialog({super.key});

  /// Copies the QR code's text content to the clipboard
  Future<void> _copyQrText(BuildContext context) async {
    // 1. Get the profile (listen: false because we're in a function)
    final profile = Provider.of<ProfileProvider>(context, listen: false).profile;
    if (profile == null) return;

    // 2. Re-create the same formatted string
    final List<String> lines = [
      '--- User Profile ---',
      'Name: ${profile.firstName} ${profile.lastName}',
      'Email: ${profile.email}',
      'User ID: ${profile.id}',
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Your QR Code',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            // No RepaintBoundary or Key needed anymore
            const QRCodeWidget(
              size: 170,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            const SizedBox(height: 16),
            const Text(
              'Scan this QR code to view your profile information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 10),
            // Simplified the button row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
                ElevatedButton(
                  onPressed: () => _copyQrText(context),
                  child: const Text('Copy Text'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

//
// --- NO CHANGES TO THIS WIDGET ---
//
class QRCodePage extends StatelessWidget {
  const QRCodePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
        centerTitle: true,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QRCodeWidget(size: 250),
            SizedBox(height: 24),
            Text(
              'Your Profile QR Code',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Share this QR code to let others view your profile information',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}