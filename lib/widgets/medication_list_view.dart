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
        return Card(
          elevation: 1,
          margin: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          child: ListTile(
            title: Text(event.name),
            trailing: Text(formatMg(event.value)),
            onLongPress: () => showDeleteConfirmationDialog(context, ref, event),
          ),
        );
      },
    );
  }
}
