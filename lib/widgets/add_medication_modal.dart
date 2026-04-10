import 'package:tapermind/providers/caffeine_options_provider.dart';
import 'package:tapermind/providers/date_provider.dart';
import 'package:tapermind/providers/events_provider.dart';
import 'package:tapermind/providers/settings_provider.dart';
import 'package:tapermind/utils/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMedicationModal extends ConsumerStatefulWidget {
  const AddMedicationModal({super.key});

  @override
  ConsumerState<AddMedicationModal> createState() => _AddMedicationModalState();
}

class _AddMedicationModalState extends ConsumerState<AddMedicationModal> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _doseAmount => double.tryParse(_controller.text.trim()) ?? 0;

  @override
  String _getMedName(WidgetRef ref) {
    final options = ref.read(medicationOptionsProvider).value ?? [];
    final enabled = options.where((o) => o.enabled).toList();
    if (enabled.isEmpty) return 'Medication';
    // Derive the group name from the first enabled option
    final name = enabled.first.name;
    for (final group in [
      'Adderall', 'Vyvanse', 'Dexedrine', 'Zenzedi', 'Ritalin',
      'Concerta', 'Focalin', 'Strattera', 'Qelbree', 'Intuniv',
      'Kapvay', 'Wellbutrin',
    ]) {
      if (name.startsWith(group)) return group;
    }
    return name;
  }

  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Text(
                      'Log Dose',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Quantity input
                Text(
                  'Quantity (mg)',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _controller,
                  autofocus: false,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(
                      fontSize: 28, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    suffixText: 'mg',
                    suffixStyle:
                        TextStyle(fontSize: 16, color: Colors.grey[500]),
                    hintText: '0',
                  ),
                ),
                const SizedBox(height: 20),

                // Add button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _doseAmount > 0
                        ? () async {
                            Analytics.track(
                              AnalyticsEvent.addMedicationEntry,
                              {
                                'amount': _doseAmount,
                                'source': 'Custom',
                                'is_custom': true,
                              },
                            );
                            final selectedDate =
                                ref.read(selectedDateProvider);
                            final now = DateTime.now();
                            final timestamp = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              now.hour,
                              now.minute,
                              now.second,
                            );
                            await ref
                                .read(settingsProvider.notifier)
                                .recordFirstAppUsage();
                            await ref
                                .read(eventsProvider.notifier)
                                .addEvent(
                                  EventType.medication,
                                  _getMedName(ref),
                                  _doseAmount,
                                  timestamp,
                                );
                            Navigator.pop(context);
                          }
                        : null,
                    child: const Text('Add'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
