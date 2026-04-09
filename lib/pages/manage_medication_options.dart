
import 'package:tapermind/providers/caffeine_options_provider.dart';
import 'package:tapermind/utils/analytics.dart';
import 'package:tapermind/widgets/add_or_edit_medication_option_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageMedicationOptionsPage extends ConsumerWidget {
  const ManageMedicationOptionsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = ref.watch(medicationOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Medication Options'),
      ),
      body: options.when(
        data: (options) {
          return ReorderableListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: options.length,
            onReorder: (oldIndex, newIndex) {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final reorderedOptions = List<MedicationOption>.from(options);
              final option = reorderedOptions.removeAt(oldIndex);
              reorderedOptions.insert(newIndex, option);
              ref.read(medicationOptionsProvider.notifier).reorderOptions(reorderedOptions);
            },
            itemBuilder: (context, index) {
              final option = options[index];
              return ListTile(
                key: ValueKey(option.id),
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.drag_handle, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Text(option.emoji, style: const TextStyle(fontSize: 24)),
                  ],
                ),
                title: Text(
                  option.name,
                  style: TextStyle(
                    color: option.enabled ? null : Colors.grey,
                    fontWeight: option.enabled ? FontWeight.normal : FontWeight.w300,
                  ),
                ),
                subtitle: Text(
                  '${option.doseAmount}mg',
                  style: TextStyle(
                    color: option.enabled ? null : Colors.grey,
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Switch(
                      value: option.enabled,
                      onChanged: (value) {
                        Analytics.track(
                          AnalyticsEvent.toggleMedicationOption,
                          {
                            'option_name': option.name,
                            'enabled': value,
                            'amount': option.doseAmount,
                          },
                        );
                        ref.read(medicationOptionsProvider.notifier).toggleOption(option.id!, value);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        Analytics.track(
                          AnalyticsEvent.editMedicationOption,
                          {
                            'option_name': option.name,
                            'amount': option.doseAmount,
                          },
                        );
                        showDialog(
                          context: context,
                          builder: (context) => AddOrEditMedicationOptionDialog(option: option),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        Analytics.track(
                          AnalyticsEvent.deleteMedicationOption,
                          {
                            'option_name': option.name,
                            'amount': option.doseAmount,
                          },
                        );
                        ref.read(medicationOptionsProvider.notifier).deleteOption(option.id!);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Analytics.track(AnalyticsEvent.addCustomMedicationOption);
          showDialog(
            context: context,
            builder: (context) => const AddOrEditMedicationOptionDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
