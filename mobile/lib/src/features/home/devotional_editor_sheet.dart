import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';
import '../../services/api_client.dart';
import 'devotional_editor_controller.dart';
import 'devotional_editor_form.dart';

class DevotionalEditorSheet extends StatefulWidget {
  const DevotionalEditorSheet({
    required this.apiClient,
    this.devotional,
    super.key,
  });

  final ApiClient apiClient;
  final AdminDevotional? devotional;

  @override
  State<DevotionalEditorSheet> createState() => _DevotionalEditorSheetState();
}

class _DevotionalEditorSheetState extends State<DevotionalEditorSheet> {
  late final TextEditingController titleController;
  late final TextEditingController contentController;
  late final TextEditingController dateController;
  late final DevotionalEditorController controller;

  @override
  void initState() {
    super.initState();
    controller = DevotionalEditorController(
      apiClient: widget.apiClient,
      devotional: widget.devotional,
    );
    titleController = TextEditingController(text: widget.devotional?.title ?? '');
    contentController = TextEditingController(text: widget.devotional?.content ?? '');
    dateController = TextEditingController(text: widget.devotional?.date ?? '');
  }

  @override
  void dispose() {
    controller.dispose();
    titleController.dispose();
    contentController.dispose();
    dateController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    try {
      await controller.save(
        title: titleController.text,
        content: contentController.text,
        date: dateController.text,
      );
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on ApiException {
      if (!mounted) {
        return;
      }
    }
  }

  Future<void> _pickDate() async {
    final initialDate = _tryParseDate(dateController.text.trim()) ?? DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (selected == null) {
      return;
    }

    setState(() {
      dateController.text =
          '${selected.year.toString().padLeft(4, '0')}-${selected.month.toString().padLeft(2, '0')}-${selected.day.toString().padLeft(2, '0')}';
    });
  }

  DateTime? _tryParseDate(String value) {
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        return Padding(
          padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                widget.devotional == null ? 'Novo devocional' : 'Editar devocional',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              DevotionalEditorForm(
                titleController: titleController,
                dateController: dateController,
                contentController: contentController,
                onPickDate: _pickDate,
                errorMessage: state.status.errorMessage,
                submitting: state.status.submitting,
                onSave: _save,
              ),
            ],
          ),
        );
      },
    );
  }
}
