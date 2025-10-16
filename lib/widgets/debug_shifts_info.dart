import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:peach_iq/Providers/available_shifts_provider.dart';

/// Debug widget to display current shifts provider state
/// Only shows in debug mode
class DebugShiftsInfo extends StatelessWidget {
  const DebugShiftsInfo({super.key});

  @override
  Widget build(BuildContext context) {
    // Only show in debug mode
    if (!kDebugMode) return const SizedBox.shrink();

    return Consumer<AvailableShiftsProvider>(
      builder: (context, provider, child) {
        final debug = provider.getDebugInfo();

        return Container(
          margin: const EdgeInsets.all(8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange, width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '🐛 DEBUG: Shifts State',
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${debug['totalShifts']} | Actionable: ${debug['actionableShifts']} | Expected: ${debug['lastKnownActionableCount']}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                'Pending: ${debug['pendingUpdates']} updates ${debug['pendingUpdateIds']}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              Text(
                'Status: ${debug['updateStatus']}',
                style: const TextStyle(color: Colors.cyan, fontSize: 10),
              ),
              Text(
                'Auto-refresh: ${debug['autoRefreshEnabled']} | Paused: ${debug['autoRefreshPaused']} | Loading: ${debug['isLoading']}',
                style: const TextStyle(color: Colors.white, fontSize: 10),
              ),
              if (debug['hasError'])
                Text(
                  'Error: ${debug['errorMessage']}',
                  style: const TextStyle(color: Colors.red, fontSize: 10),
                ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDebugButton(
                    'Force Refresh',
                    () => provider.forceRefresh(),
                  ),
                  const SizedBox(width: 8),
                  _buildDebugButton(
                    'Log State',
                    () => provider.logCurrentState('Manual'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDebugButton(String label, VoidCallback onPressed) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
