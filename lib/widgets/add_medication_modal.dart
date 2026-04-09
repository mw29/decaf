import 'package:tapermind/pages/manage_medication_options.dart';
import 'package:tapermind/providers/caffeine_options_provider.dart';
import 'package:tapermind/providers/date_provider.dart';
import 'package:tapermind/providers/events_provider.dart';
import 'package:tapermind/providers/settings_provider.dart';
import 'package:tapermind/utils/analytics.dart';
import 'package:tapermind/utils/format_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMedicationModal extends ConsumerStatefulWidget {
  const AddMedicationModal({super.key});

  @override
  ConsumerState<AddMedicationModal> createState() => _AddMedicationModalState();
}

class _AddMedicationModalState extends ConsumerState<AddMedicationModal> {
  double _doseAmount = 0;
  String? _selectedChipKey;

  @override
  Widget build(BuildContext context) {
    final medicationOptions = ref.watch(medicationOptionsProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 16.0),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Add Medication',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setState(() {
                            _doseAmount = (_doseAmount - 5).clamp(
                              0,
                              double.infinity,
                            );
                          });
                        },
                      ),
                      Text(
                        formatMg(_doseAmount),
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            _doseAmount = _doseAmount + 5;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Flexible(
                    child: Wrap(
                      spacing: 8.0,
                      children: [
                        ...medicationOptions.when(
                          data: (options) {
                            return options.where((option) => option.enabled).map((
                              option,
                            ) {
                              final name = '${option.emoji} ${option.name}';
                              return ChoiceChip(
                                label: Text(
                                  '$name (${formatMg(option.doseAmount)})',
                                ),
                                selected: _selectedChipKey == name,
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedChipKey = name;
                                      _doseAmount = option.doseAmount;
                                    } else {
                                      _selectedChipKey = null;
                                      _doseAmount = 0;
                                    }
                                  });
                                },
                              );
                            }).toList();
                          },
                          loading: () => [const CircularProgressIndicator()],
                          error: (error, stackTrace) => [Text('Error: $error')],
                        ),
                        ChoiceChip(
                          label: const Text('⚙️ Update Options'),
                          selected: false,
                          onSelected: (selected) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) =>
                                        const ManageMedicationOptionsPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: ElevatedButton(
                      onPressed:
                          _doseAmount > 0
                              ? () async {
                                Analytics.track(
                                  AnalyticsEvent.addMedicationEntry,
                                  {
                                    'amount': _doseAmount,
                                    'source': _selectedChipKey ?? 'Custom',
                                    'is_custom': _selectedChipKey == null,
                                  },
                                );
                                final selectedDate = ref.read(
                                  selectedDateProvider,
                                );
                                final now = DateTime.now();
                                final timestamp = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  now.hour,
                                  now.minute,
                                  now.second,
                                );

                                // Record first app usage
                                await ref.read(settingsProvider.notifier).recordFirstAppUsage();

                                // Add the event
                                await ref
                                    .read(eventsProvider.notifier)
                                    .addEvent(
                                      EventType.medication,
                                      _selectedChipKey ?? 'Custom Medication',
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
      ),
    );
  }
}
