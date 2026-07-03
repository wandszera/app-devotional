import 'package:flutter/material.dart';

import 'home_form_widgets.dart';

class DevotionalEditorForm extends StatelessWidget {
  const DevotionalEditorForm({
    required this.titleController,
    required this.dateController,
    required this.contentController,
    required this.onPickDate,
    required this.errorMessage,
    required this.submitting,
    required this.onSave,
    super.key,
  });

  final TextEditingController titleController;
  final TextEditingController dateController;
  final TextEditingController contentController;
  final VoidCallback onPickDate;
  final String? errorMessage;
  final bool submitting;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        HomeFormSection(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titulo'),
              ),
              const HomeFormFieldSpacing(),
              HomeReadOnlyPickerField(
                controller: dateController,
                labelText: 'Data',
                hintText: '2026-04-30',
                onTap: onPickDate,
                suffixIcon: const Icon(Icons.calendar_month),
              ),
              const HomeFormFieldSpacing(),
              HomeMultilineField(
                controller: contentController,
                labelText: 'Conteudo',
              ),
            ],
          ),
        ),
        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          HomeFormErrorText(message: errorMessage!),
        ],
        const SizedBox(height: 20),
        FilledButton(
          onPressed: submitting ? null : onSave,
          child: Text(submitting ? 'Salvando...' : 'Salvar'),
        ),
      ],
    );
  }
}
