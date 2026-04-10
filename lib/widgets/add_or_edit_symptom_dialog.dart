import 'package:tapermind/constants/colors.dart';
import 'package:tapermind/providers/symptoms_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddOrEditSymptomDialog extends ConsumerStatefulWidget {
  final Symptom? symptom;

  const AddOrEditSymptomDialog({super.key, this.symptom});

  @override
  ConsumerState<AddOrEditSymptomDialog> createState() =>
      _AddOrEditSymptomDialogState();
}

class _AddOrEditSymptomDialogState
    extends ConsumerState<AddOrEditSymptomDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late SymptomConnotation _connotation;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.symptom?.name ?? '');
    _connotation =
        widget.symptom?.connotation ?? SymptomConnotation.negative;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.symptom != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Symptom' : 'Add Symptom'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Name'),
              textCapitalization: TextCapitalization.words,
              validator: (value) =>
                  (value == null || value.trim().isEmpty)
                      ? 'Please enter a name'
                      : null,
            ),
            const SizedBox(height: 16),
            // Connotation toggle
            Row(
              children: [
                _TypeChip(
                  label: 'Positive',
                  selected: _connotation == SymptomConnotation.positive,
                  color: AppColors.positiveEffect,
                  onTap: () => setState(
                      () => _connotation = SymptomConnotation.positive),
                ),
                const SizedBox(width: 8),
                _TypeChip(
                  label: 'Negative',
                  selected: _connotation == SymptomConnotation.negative,
                  color: AppColors.negativeEffect,
                  onTap: () => setState(
                      () => _connotation = SymptomConnotation.negative),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final symptom = Symptom(
                id: widget.symptom?.id,
                name: _nameController.text.trim(),
                emoji: widget.symptom?.emoji ?? '💊',
                connotation: _connotation,
              );
              if (isEditing) {
                ref.read(symptomsProvider.notifier).updateSymptom(symptom);
              } else {
                ref.read(symptomsProvider.notifier).addSymptom(symptom);
              }
              Navigator.of(context).pop();
            }
          },
          child: Text(isEditing ? 'Save' : 'Add'),
        ),
      ],
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? color : AppColors.textSecondary,
            fontWeight:
                selected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
