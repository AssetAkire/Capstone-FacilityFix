import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum MaintenanceChoice { internal, external }

Future<void> showCreateMaintenanceTaskDialog(
  BuildContext context, {
  VoidCallback? onInternal,
  VoidCallback? onExternal,
}) async {
  final choice = await _showMaintenanceTypeDialog(context);
  if (choice == null) return;

  if (choice == MaintenanceChoice.internal) {
    if (onInternal != null) {
      onInternal();
    } else {
      // Navigate to internal maintenance form
      context.go('/work/maintenance/create/internal');
    }
  } else if (choice == MaintenanceChoice.external) {
    if (onExternal != null) {
      onExternal();
    } else {
      // Navigate to external maintenance form
      context.go('/work/maintenance/create/external');
    }
  }
}

Future<MaintenanceChoice?> _showMaintenanceTypeDialog(BuildContext context) {
  return showDialog<MaintenanceChoice>(
    context: context,
    builder:
        (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select type of maintenance',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16),
              Divider(thickness: 1, height: 1),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed:
                        () => Navigator.of(ctx).pop(MaintenanceChoice.internal),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Internal Preventive Maintenance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '(Handled by in-house staff)',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: OutlinedButton(
                    onPressed:
                        () => Navigator.of(ctx).pop(MaintenanceChoice.external),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue, width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'External Preventive Maintenance',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '(Outsourced to contractor/service provider)',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        ),
  );
}
