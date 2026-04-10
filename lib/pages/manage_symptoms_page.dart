import 'package:tapermind/constants/colors.dart';
import 'package:tapermind/providers/symptoms_provider.dart';
import 'package:tapermind/utils/analytics.dart';
import 'package:tapermind/widgets/add_or_edit_symptom_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ManageSymptomsPage extends ConsumerWidget {
  const ManageSymptomsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final symptoms = ref.watch(symptomsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Symptoms'),
      ),
      body: symptoms.when(
        data: (symptoms) {
          final positiveSymptoms = symptoms.where((s) => s.connotation == SymptomConnotation.positive).toList();
          final negativeSymptoms = symptoms.where((s) => s.connotation == SymptomConnotation.negative).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 116.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (positiveSymptoms.isNotEmpty)
                  _buildSection(context, ref, 'Positive Effects', positiveSymptoms, AppColors.positiveEffect),
                if (positiveSymptoms.isNotEmpty && negativeSymptoms.isNotEmpty)
                  const SizedBox(height: 24),
                if (negativeSymptoms.isNotEmpty)
                  _buildSection(context, ref, 'Negative Effects', negativeSymptoms, AppColors.negativeEffect),
                if (symptoms.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No symptoms added yet'),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(child: Text('Error: $error')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Analytics.track(AnalyticsEvent.addCustomSymptom);
          showDialog(
            context: context,
            builder: (context) => const AddOrEditSymptomDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context,
    WidgetRef ref,
    String title,
    List<Symptom> symptoms,
    Color accentColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...symptoms.map((symptom) => _buildSymptomRow(context, ref, symptom)),
      ],
    );
  }

  Widget _buildSymptomRow(BuildContext context, WidgetRef ref, Symptom symptom) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              symptom.name,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: symptom.enabled ? null : AppColors.textSecondary,
                    fontWeight: symptom.enabled ? FontWeight.w500 : FontWeight.normal,
                  ),
            ),
          ),
          Switch(
            value: symptom.enabled,
            onChanged: (value) {
              Analytics.track(
                AnalyticsEvent.toggleSymptom,
                {
                  'symptom_name': symptom.name,
                  'enabled': value,
                  'connotation': symptom.connotation.name,
                },
              );
              ref.read(symptomsProvider.notifier).toggleSymptom(symptom.id!, value);
            },
          ),
        ],
      ),
    );
  }
}
