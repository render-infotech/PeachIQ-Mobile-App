import 'package:flutter/material.dart';
import 'package:peach_iq/screens/home/available_shift_card.dart';
import 'package:peach_iq/widgets/header_card_widget.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart';
import 'package:peach_iq/screens/auth/login.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';

class AvailableShifts extends StatefulWidget {
  const AvailableShifts({super.key});

  @override
  State<AvailableShifts> createState() => _AvailableShiftsState();
}

class _AvailableShiftsState extends State<AvailableShifts> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shiftsProvider =
          Provider.of<AvailableShiftsProvider>(context, listen: false);
      shiftsProvider.fetchAvailableShifts();
      // Start auto-refresh when the screen loads
      shiftsProvider.startAutoRefresh();
    });
  }

  @override
  void dispose() {
    // Stop auto-refresh when leaving the screen
    Provider.of<AvailableShiftsProvider>(context, listen: false)
        .stopAutoRefresh();
    super.dispose();
  }

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
              final profileProvider =
                  Provider.of<ProfileProvider>(context, listen: false);
              final shiftsProvider =
                  Provider.of<AvailableShiftsProvider>(context, listen: false);

              await profileProvider.logout();
              shiftsProvider.clear();

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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Consumer<ProfileProvider>(
              builder: (context, p, _) => HeaderCard(
                name: p.fullName,
                subtitle: p.email.isNotEmpty ? p.email : null,
                pageheader: 'Available Shifts',
                onSignOut: () => _handleSignOut(context),
              ),
            ),
            // Auto-refresh indicator
            Consumer<AvailableShiftsProvider>(
              builder: (context, shiftsProvider, _) {
                if (shiftsProvider.autoRefreshEnabled) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    // child: Row(
                    //   children: [
                    //     Icon(
                    //       Icons.refresh,
                    //       size: 16,
                    //       color: Colors.green[600],
                    //     ),
                    //     const SizedBox(width: 4),
                    //     Text(
                    //       'Auto-refresh enabled',
                    //       style: TextStyle(
                    //         fontSize: 12,
                    //         color: Colors.green[600],
                    //         fontWeight: FontWeight.w500,
                    //       ),
                    //     ),
                    //     const Spacer(),
                    //     GestureDetector(
                    //       onTap: () => shiftsProvider.toggleAutoRefresh(),
                    //       child: Text(
                    //         'Turn off',
                    //         style: TextStyle(
                    //           fontSize: 12,
                    //           color: Colors.grey[600],
                    //           decoration: TextDecoration.underline,
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                  );
                } else {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.refresh_outlined,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Auto-refresh disabled',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => shiftsProvider.toggleAutoRefresh(),
                          child: Text(
                            'Turn on',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue[600],
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<AvailableShiftsProvider>(
                builder: (context, shiftsProvider, child) {
                  if (shiftsProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (shiftsProvider.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              shiftsProvider.errorMessage!,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                              onPressed: () => shiftsProvider.retry(),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (!shiftsProvider.hasSchedules) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'No available shifts right now.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () => shiftsProvider.fetchAvailableShifts(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: shiftsProvider.schedules.length,
                      itemBuilder: (context, index) {
                        final schedule = shiftsProvider.schedules[index];
                        return AvailableShiftCard(
                          name: schedule.name,
                          dateLine: schedule.dateLine,
                          timeLine: schedule.timeLine,
                          notifyId: schedule.notifyId,
                          role: schedule.role,
                          shiftType: schedule.shiftType,
                          unitArea: schedule.unitArea,
                        );
                      },
                    ),
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
