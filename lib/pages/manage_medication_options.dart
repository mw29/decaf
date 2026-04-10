import 'package:tapermind/constants/colors.dart';
import 'package:tapermind/providers/caffeine_options_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const _medicationGroups = [
  'Adderall',
  'Vyvanse',
  'Dexedrine',
  'Zenzedi',
  'Ritalin',
  'Concerta',
  'Focalin',
  'Strattera',
  'Qelbree',
  'Intuniv',
  'Kapvay',
  'Wellbutrin',
  'Other',
];

class ManageMedicationOptionsPage extends ConsumerWidget {
  const ManageMedicationOptionsPage({super.key});

  String? _currentSelection(List<MedicationOption> options) {
    final enabled = options.where((o) => o.enabled).toList();
    if (enabled.isEmpty) return null;
    // Try to match enabled options back to a group name
    for (final group in _medicationGroups) {
      if (group == 'Other') continue;
      final groupOptions = options.where((o) => o.name.startsWith(group));
      final allEnabled = groupOptions.isNotEmpty &&
          groupOptions.every((o) => o.enabled) &&
          enabled.every((o) => o.name.startsWith(group));
      if (allEnabled) return group;
    }
    // If all options are enabled, it's "Other"
    if (enabled.length == options.length) return 'Other';
    return null;
  }

  Future<void> _selectMed(
    WidgetRef ref,
    List<MedicationOption> options,
    String name,
  ) async {
    final notifier = ref.read(medicationOptionsProvider.notifier);
    for (final opt in options) {
      if (opt.id != null) await notifier.toggleOption(opt.id!, false);
    }
    if (name == 'Other') {
      for (final opt in options) {
        if (opt.id != null) await notifier.toggleOption(opt.id!, true);
      }
    } else {
      for (final opt in options) {
        if (opt.id != null && opt.name.startsWith(name)) {
          await notifier.toggleOption(opt.id!, true);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final optionsAsync = ref.watch(medicationOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medication'),
      ),
      body: optionsAsync.when(
        data: (options) {
          final selected = _currentSelection(options);
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Which medication are you tapering?',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'This determines which dose options appear when logging.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: _medicationGroups.map((name) {
                    final isSelected = selected == name;
                    return ChoiceChip(
                      label: Text(name),
                      selected: isSelected,
                      onSelected: (_) => _selectMed(ref, options, name),
                      selectedColor: AppColors.medication,
                      disabledColor: Colors.white,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : AppColors.textPrimary,
                        fontWeight: isSelected
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.medication
                            : AppColors.border,
                      ),
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
