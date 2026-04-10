import 'package:tapermind/constants/colors.dart';
import 'package:tapermind/providers/events_provider.dart';
import 'package:tapermind/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicationListView extends ConsumerWidget {
  final List<Event> medicationEvents;
  final Future<void> Function(BuildContext, WidgetRef, Event) showDeleteConfirmationDialog;

  const MedicationListView({
    super.key,
    required this.medicationEvents,
    required this.showDeleteConfirmationDialog,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (medicationEvents.isEmpty) {
      return const Center(child: Text('No medication logged for this day.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: medicationEvents.length,
      itemBuilder: (context, index) {
        final event = medicationEvents[index];
        return Dismissible(
          key: ValueKey(event.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: AppColors.negativeEffect,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.delete_outline, color: Colors.white),
          ),
          confirmDismiss: (_) async {
            return await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Delete entry?'),
                content: Text('Remove ${formatMg(event.value)} from today?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.negativeEffect,
                    ),
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'),
                  ),
                ],
              ),
            ) ?? false;
          },
          onDismissed: (_) {
            ref.read(eventsProvider.notifier).deleteEvent(event.id!);
          },
          child: Card(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: ListTile(
              title: Text(event.name),
              trailing: Text(formatMg(event.value)),
            ),
          ),
        );
      },
    );
  }
}
