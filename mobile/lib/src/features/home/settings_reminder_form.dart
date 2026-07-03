import 'package:flutter/material.dart';

import 'home_form_widgets.dart';

class SettingsReminderForm extends StatelessWidget {
  const SettingsReminderForm({
    required this.enabled,
    required this.timeController,
    required this.timezoneController,
    required this.pushTokenController,
    required this.onToggleEnabled,
    required this.onPickReminderTime,
    required this.onSave,
    required this.submitting,
    super.key,
  });

  final bool enabled;
  final TextEditingController timeController;
  final TextEditingController timezoneController;
  final TextEditingController pushTokenController;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback onPickReminderTime;
  final VoidCallback onSave;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SwitchListTile(
          value: enabled,
          onChanged: onToggleEnabled,
          title: const Text('Lembrete diario'),
          subtitle: const Text('Ativa o envio do devocional diario'),
        ),
        const SizedBox(height: 12),
        HomeReadOnlyPickerField(
          controller: timeController,
          labelText: 'Horario',
          hintText: '08:00',
          onTap: onPickReminderTime,
          suffixIcon: const Icon(Icons.access_time),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: timezoneController,
          decoration: const InputDecoration(
            labelText: 'Timezone',
            hintText: 'America/Sao_Paulo',
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: pushTokenController,
          minLines: 2,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Push token manual (opcional)',
            hintText: 'Cole aqui um token do provedor, se voce tiver um',
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sem SDK nativo, este campo permite testar dispatch manualmente pelo backend.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: const Color(0xFF5F4B39),
              ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: submitting ? null : onSave,
          child: Text(submitting ? 'Salvando...' : 'Salvar ajustes'),
        ),
      ],
    );
  }
}
