import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:peach_iq/screens/Notifications/inbox_tabbar.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:peach_iq/loading/shimmer_gate.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';

class InboxScreen extends StatelessWidget {
  const InboxScreen({super.key});

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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Consumer<ProfileProvider>(
                builder: (context, p, _) => HeaderCard(
                  name: p.fullName,
                  subtitle: p.email.isNotEmpty ? p.email : null,
                  pageheader: 'Notifications',
                  onSignOut: () => _handleSignOut(context),
                ),
              ),

              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    // child: Row(
                    //   children: [
                    //     Expanded(
                    //       child: Text(
                    //         'Inbox',
                    //         textAlign: TextAlign.center,
                    //         style: TextStyle(
                    //           fontSize: 20,
                    //           fontWeight: FontWeight.w600,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  ),

                  // Reusable styled TabBar (left-aligned)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const InboxTabs(),
                  ),
                ],
              ),

              // Reserve remaining space for future content
            ],
          ),
        ),
      ),
    );
  }
}
