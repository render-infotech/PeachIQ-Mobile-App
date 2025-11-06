import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // <-- 1. Import for date formatting
import 'package:peach_iq/Models/notifications_model.dart';
import 'package:peach_iq/Providers/notifications_provider.dart';
import 'package:peach_iq/QR/qr_code_widget.dart';
import 'package:peach_iq/screens/Notifications/notification_details_screen.dart';
import 'package:peach_iq/shared/themes/Appcolors.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';

import 'package:peach_iq/Providers/profile_provider.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  @override
  void initState() {
    super.initState();
    // Fetches notifications on first load
    Future.microtask(() =>
        Provider.of<NotificationProvider>(context, listen: false)
            .fetchNotifications());
  }



  Widget _buildNotificationsList(List<NotificationModel> notificationList) {
    if (notificationList.isEmpty) {
      return const Center(
        child: Text(
          'No notifications',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: notificationList.length,
      itemBuilder: (context, index) {
        final notification = notificationList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: notification.isRead
                ? Colors.white
                : AppColors.primary.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: notification.isRead
                  ? Colors.grey.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Notification content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Use message as main content (no title)
                      Text(
                        notification.message,
                        style: TextStyle(
                          fontWeight: notification.isRead
                              ? FontWeight.w500
                              : FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.black,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Timestamp
                      Text(
                        DateFormat('d MMM yyyy, h:mm a').format(notification.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Mark as read radio button
                Tooltip(
                  message: 'Mark as read',
                  child: GestureDetector(
                    onTap: () async {
                      if (!notification.isRead) {
                        // Mark as read using the correct method
                        await Provider.of<NotificationProvider>(context, listen: false)
                            .markOneAsRead(notification.id);
                      }
                    },
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: notification.isRead 
                              ? Colors.green 
                              : Colors.grey.withValues(alpha: 0.4),
                          width: 2,
                        ),
                        color: notification.isRead 
                            ? Colors.green 
                            : Colors.transparent,
                      ),
                      child: notification.isRead
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<ProfileProvider>(
              builder: (context, p, _) => HeaderCard(
                name: p.fullName,
                subtitle: p.email.isNotEmpty ? p.email : null,
                pageheader: 'Notifications',
                onQrCodeTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const QRCodeDialog(),
                  );
                },
              ),
            ),
            Expanded(
              child: Consumer<NotificationProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    );
                  }

                  if (provider.errorMessage.isNotEmpty) {
                    return Center(
                      child: Text(
                        provider.errorMessage,
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  final hasUnread = provider.notifications.any((n) => !n.isRead);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (hasUnread)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  // Call the provider method directly
                                  context
                                      .read<NotificationProvider>()
                                      .markAllAsRead();
                                },
                                child: const Text(
                                  'Mark All as Read',
                                  style: TextStyle(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Expanded(
                        child: _buildNotificationsList(provider.notifications),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}