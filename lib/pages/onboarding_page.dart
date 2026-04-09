import 'package:tapermind/constants/colors.dart';
import 'package:tapermind/providers/caffeine_options_provider.dart';
import 'package:tapermind/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _step = 0;
  String? _selectedMedName;
  final _mgController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _mgController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final mg = double.tryParse(_mgController.text.trim());
    if (_selectedMedName == null || mg == null || _isSaving) return;
    setState(() => _isSaving = true);

    final notifier = ref.read(medicationOptionsProvider.notifier);
    final options = ref.read(medicationOptionsProvider).value ?? [];

    // Disable all, then enable matching
    for (final opt in options) {
      if (opt.id != null) await notifier.toggleOption(opt.id!, false);
    }
    if (_selectedMedName != 'Other') {
      for (final opt in options) {
        if (opt.id != null && opt.name.startsWith(_selectedMedName!)) {
          await notifier.toggleOption(opt.id!, true);
        }
      }
    } else {
      // Enable everything for "Other"
      for (final opt in options) {
        if (opt.id != null) await notifier.toggleOption(opt.id!, true);
      }
    }

    await ref.read(settingsProvider.notifier).completeOnboarding();
    setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    final optionsAsync = ref.watch(medicationOptionsProvider);
    return Scaffold(
      body: SafeArea(
        child: optionsAsync.when(
          data: (_) => _step == 0
              ? _buildStepMed(context)
              : _buildStepDosage(context),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  // ── Step 1: Pick medication ──────────────────────────────────────────────

  Widget _buildStepMed(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('💊', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'What medication\nare you tapering?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select the medication you want to taper off.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _medicationGroups.map((name) {
              final isSelected = _selectedMedName == name;
              return ChoiceChip(
                label: Text(name),
                selected: isSelected,
                onSelected: (_) => setState(() => _selectedMedName = name),
                selectedColor: AppColors.medication,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? AppColors.medication
                      : Colors.grey.withValues(alpha: 0.3),
                ),
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 10),
              );
            }).toList(),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _selectedMedName != null
                  ? () => setState(() => _step = 1)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.medication,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Colors.grey.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Next',
                style:
                    TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Step 2: Enter dosage ─────────────────────────────────────────────────

  Widget _buildStepDosage(BuildContext context) {
    final canFinish = _mgController.text.trim().isNotEmpty &&
        double.tryParse(_mgController.text.trim()) != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          const Text('📏', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            "What's your\ncurrent dosage?",
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'How many mg of $_selectedMedName do you take per day?',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 40),
          TextField(
            controller: _mgController,
            autofocus: true,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            onChanged: (_) => setState(() {}),
            style:
                const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              suffixText: 'mg / day',
              suffixStyle: TextStyle(fontSize: 18, color: Colors.grey[500]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                    color: AppColors.medication, width: 2),
              ),
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: () => setState(() => _step = 0),
            child: const Text('← Back'),
          ),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: canFinish ? _finish : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.medication,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    Colors.grey.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Get Started',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
