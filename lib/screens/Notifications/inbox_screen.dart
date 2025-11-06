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
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: notification.isRead
                          ? FontWeight.w600
                          : FontWeight.w700,
                      fontSize: 15,
                      color: AppColors.black,
                    ),
                  ),
                ),
                if (!notification.isRead)
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // This is the partial message
                  Text(
                    notification.message.length > 80
                        ? '${notification.message.substring(0, 80)}...'
                        : notification.message,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                      height: 1.2,
                    ),
                  ),
                  // --- 2. ADDED TIMESTAMP DISPLAY ---
                  const SizedBox(height: 4), 
                  Text( 
                    DateFormat('d MMM yyyy, h:mm a').format(notification.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  // --- END OF ADDITION ---
                ],
              ),
            ),
            onTap: () async {
              // This correctly passes all required data
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationDetailsScreen(
                    // Pass the full object
                    notification: notification,
                  ),
                ),
              );
            },
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
                                // --- THIS IS THE FIX ---
                                onPressed: () {
                                  // Call the provider method directly
                                  context
                                      .read<NotificationProvider>()
                                      .markAllAsRead();
                                },
                                // --- END OF FIX ---
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