import 'package:flutter/material.dart';

class InboxTabs extends StatelessWidget {
  const InboxTabs({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TabBar(
      // Full-width equal tabs
      isScrollable: false,

      // Remove the moving underline for the selected tab
      indicator: const BoxDecoration(),

      // Add a subtle full-width divider line under the TabBar
      dividerColor: theme.colorScheme.onSurface.withOpacity(0.5),
      dividerHeight: .4,

      // Extra vertical space between the tabs and the divider
      padding: const EdgeInsets.only(bottom: 4),

      // Typography and spacing
      labelPadding: const EdgeInsets.symmetric(horizontal: 0),
      labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      unselectedLabelStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),

      // Colors
      labelColor: theme.colorScheme.onSurface,
      unselectedLabelColor: theme.colorScheme.onSurface.withOpacity(0.5),

      tabs: const [
        Tab(text: 'Notifications'),
        Tab(text: 'Read'),
        // Tab(text: 'Unread'),
      ],
    );
  }
}
