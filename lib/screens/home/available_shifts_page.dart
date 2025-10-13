import 'package:flutter/material.dart';
import 'package:peach_iq/screens/home/available_shift_card.dart'; // Ensure this import path is correct
import 'package:peach_iq/widgets/header_card_widget.dart'; // Ensure this import path is correct
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/profile_provider.dart'; // Ensure this import path is correct
import 'package:peach_iq/Providers/available_shifts_provider.dart'; // Ensure this import path is correct
import 'package:peach_iq/shared/themes/Appcolors.dart'; // Ensure this import path is correct

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
      if (shiftsProvider.allSchedules.isEmpty) {
        shiftsProvider.fetchAvailableShifts();
      }
    });
  }

  void _handleSignOut() {
    // Your sign out logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Consumer<ProfileProvider>(
                  builder: (context, p, _) => HeaderCard(
                    name: p.fullName,
                    pageheader: '       Available Shifts',
                    onSignOut: _handleSignOut,
                  ),
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
            const SizedBox(height: 10),
            Expanded(
              child: Consumer<AvailableShiftsProvider>(
                builder: (context, shiftsProvider, child) {
                  if (shiftsProvider.isLoading &&
                      shiftsProvider.allSchedules.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (shiftsProvider.errorMessage != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(shiftsProvider.errorMessage!,
                                textAlign: TextAlign.center),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: () => shiftsProvider.retry(),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            )
                          ],
                        ),
                      ),
                    );
                  }

                  if (shiftsProvider.allSchedules.isEmpty) {
                    return RefreshIndicator(
                      onRefresh: () => shiftsProvider.fetchAvailableShifts(),
                      child: ListView(
                        children: [
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.2),
                          Center(
                            child: Text(
                              'No available shifts right now.',
                              style: TextStyle(color: AppColors.black),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // --- NEW SORTING LOGIC ---
                  final sortedSchedules = List.of(shiftsProvider.allSchedules);
                  sortedSchedules.sort((a, b) {
                    // Group 1: Shifts needing a response (0)
                    // Group 2: Responded shifts (1, -1)
                    final aGroup = a.caregiverDecision == 0 ? 1 : 2;
                    final bGroup = b.caregiverDecision == 0 ? 1 : 2;

                    if (aGroup != bGroup) {
                      return aGroup.compareTo(bGroup); // Sort by group
                    }

                    // Within each group, sort by earliest start date (ascending)
                    return a.startDate.compareTo(b.startDate);
                  });
                  // --- END OF SORTING LOGIC ---

                  return RefreshIndicator(
                    onRefresh: () => shiftsProvider.fetchAvailableShifts(),
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      itemCount: sortedSchedules.length,
                      itemBuilder: (context, index) {
                        final schedule = sortedSchedules[index];
                        return AvailableShiftCard(
                          shift: schedule,
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
