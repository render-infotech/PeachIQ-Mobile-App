import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:provider/provider.dart'; // <-- 1. IMPORT PROVIDER

// <-- 2. IMPORT MODEL AND PROVIDER -->
import 'package:peach_iq/Models/notifications_model.dart';
import 'package:peach_iq/Providers/notifications_provider.dart';

class NotificationDetailsScreen extends StatelessWidget {
  // --- 3. UPDATED CONSTRUCTOR ---
  // We now accept the full model, which gives us access to the ID.
  final NotificationModel notification;

  const NotificationDetailsScreen({
    super.key,
    required this.notification,
  });
  // --- END OF UPDATE ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Notification Details',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: notification.isRead // <-- Use model
                        ? Colors.grey.withValues(alpha: 0.2)
                        : AppColors.primary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: notification.isRead // <-- Use model
                          ? Colors.grey.withValues(alpha: 0.4)
                          : AppColors.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    notification.isRead ? 'Read' : 'Unread', // <-- Use model
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: notification.isRead // <-- Use model
                          ? Colors.grey[700]
                          : AppColors.primary,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  // <-- Use model
                  DateFormat('d MMM yyyy, h:mm a').format(notification.timestamp),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              notification.title, // <-- Use model
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                notification.message, // <-- Use model
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[800],
                  height: 1.6,
                  letterSpacing: 0.3,
                ),
              ),
            ),
            const SizedBox(height: 30),
            
            // --- 4. UPDATED BUTTON LOGIC ---
            if (!notification.isRead)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    // Call the provider method
                    context
                        .read<NotificationProvider>()
                        .markOneAsRead(notification.id);
                    // Pop the screen
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.check_circle_outline,
                    size: 18,
                    color: AppColors.primary,
                  ),
                  label: const Text(
                    'Mark as Read',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}