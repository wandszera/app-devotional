import 'package:flutter/material.dart';

import '../../models/notification_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/push_sdk_bridge.dart';

class NotificationPromptPage extends StatefulWidget {
  const NotificationPromptPage({
    required this.apiClient,
    required this.authStore,
    required this.pushSdkBridge,
    required this.onFinished,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;
  final PushSdkBridge pushSdkBridge;
  final VoidCallback onFinished;

  @override
  State<NotificationPromptPage> createState() => _NotificationPromptPageState();
}

class _NotificationPromptPageState extends State<NotificationPromptPage> {
  static const quickTimeOptions = [
    ('Manha', '07:00'),
    ('Almoco', '12:00'),
    ('Noite', '20:30'),
  ];
  final timeController = TextEditingController(text: '08:00');
  final timezoneController = TextEditingController(text: 'America/Sao_Paulo');
  final pushTokenController = TextEditingController();
  bool enabled = true;
  bool saving = false;
  PushSdkState? pushSdkState;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadPushSdkState();
  }

  @override
  void dispose() {
    timeController.dispose();
    timezoneController.dispose();
    pushTokenController.dispose();
    super.dispose();
  }

  Future<void> _loadPushSdkState() async {
    final state = await widget.pushSdkBridge.loadState();
    if (!mounted) {
      return;
    }
    setState(() {
      pushSdkState = state;
    });
  }

  Future<void> _refreshPushSdkState() async {
    final state = await widget.pushSdkBridge.refreshStatus();
    if (!mounted) {
      return;
    }
    setState(() {
      pushSdkState = state;
    });
  }

  Future<void> _requestPushPermission() async {
    final state = await widget.pushSdkBridge.requestPermission();
    if (!mounted) {
      return;
    }
    setState(() {
      pushSdkState = state;
    });
  }

  Future<void> _pickReminderTime() async {
    final currentText = timeController.text.trim();
    final parts = currentText.split(':');
    final initialTime = parts.length == 2
        ? TimeOfDay(
            hour: int.tryParse(parts[0]) ?? 8,
            minute: int.tryParse(parts[1]) ?? 0,
          )
        : const TimeOfDay(hour: 8, minute: 0);

    final selected = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
    if (selected == null) {
      return;
    }

    timeController.text =
        '${selected.hour.toString().padLeft(2, '0')}:${selected.minute.toString().padLeft(2, '0')}';
    setState(() {});
  }

  Future<void> _finishWithoutSaving() async {
    await widget.authStore.markNotificationPromptSeen();
    widget.onFinished();
  }

  void _applyQuickTime(String value) {
    setState(() {
      timeController.text = value;
    });
  }

  Future<void> _saveReminder() async {
    setState(() {
      saving = true;
      errorMessage = null;
    });

    try {
      final sdkState = await widget.pushSdkBridge.loadState();
      await widget.apiClient.updateNotificationSettings(
        NotificationSettingsModel(
          enabled: enabled,
          reminderTime: timeController.text.trim(),
          timezone: timezoneController.text.trim(),
          pushToken: sdkState.pushToken ?? pushTokenController.text.trim(),
        ),
      );
      await widget.authStore.markNotificationPromptSeen();
      widget.onFinished();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFFFF3E2),
              Color(0xFFE9D8BE),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: saving ? null : _finishWithoutSaving,
                  child: const Text('Depois'),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  size: 42,
                  color: Color(0xFF7A4B2A),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Escolha seu lembrete diario',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF4B3320),
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'Esse horario ajuda voce a voltar todos os dias. Escolha um momento simples e realista.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: const Color(0xFF5F4B39),
                    ),
              ),
              const SizedBox(height: 28),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Primeira meta sugerida',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7A4B2A),
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Tente manter 3 dias seguidos. E uma meta curta o bastante para comecar bem e forte o bastante para criar ritmo.',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _PushSdkStatusCard(
                state: pushSdkState,
                onRefresh: saving ? null : _refreshPushSdkState,
                onRequestPermission: null,
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                value: enabled,
                onChanged: saving
                    ? null
                    : (value) {
                        setState(() {
                          enabled = value;
                        });
                      },
                contentPadding: EdgeInsets.zero,
                title: const Text('Ativar lembrete diario'),
                subtitle: const Text('Voce podera mudar isso depois'),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: quickTimeOptions.map((item) {
                  final isSelected = timeController.text.trim() == item.$2;
                  return ChoiceChip(
                    label: Text('${item.$1} • ${item.$2}'),
                    selected: isSelected,
                    onSelected: saving ? null : (_) => _applyQuickTime(item.$2),
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timeController,
                readOnly: true,
                onTap: saving ? null : _pickReminderTime,
                decoration: const InputDecoration(
                  labelText: 'Horario',
                  suffixIcon: Icon(Icons.access_time),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: timezoneController,
                readOnly: saving,
                decoration: const InputDecoration(
                  labelText: 'Timezone',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: pushTokenController,
                readOnly: saving,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Push token manual (opcional)',
                  hintText: 'Cole um token se quiser testar dispatch depois',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Voce pode deixar em branco agora e preencher depois nos ajustes.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF5F4B39),
                    ),
              ),
              if (errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECE8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              FilledButton(
                onPressed: saving ? null : _saveReminder,
                child: Text(saving ? 'Salvando...' : 'Salvar lembrete'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PushSdkStatusCard extends StatelessWidget {
  const _PushSdkStatusCard({
    required this.state,
    required this.onRefresh,
    required this.onRequestPermission,
  });

  final PushSdkState? state;
  final Future<void> Function()? onRefresh;
  final Future<void> Function()? onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF3ECE2),
        borderRadius: BorderRadius.circular(22),
      ),
      child: currentState == null
          ? const Row(
              children: [
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Carregando status dos lembretes...'),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  currentState.statusMessage,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF7A4B2A),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentState.helpMessage,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF5F4B39),
                      ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      OutlinedButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.sync),
                        label: const Text('Atualizar status'),
                      ),
                      if (currentState.isSupported &&
                          currentState.permissionStatus !=
                              PushPermissionStatus.granted)
                        FilledButton.icon(
                          onPressed: onRequestPermission,
                          icon: const Icon(Icons.notifications_active),
                          label: const Text('Pedir permissao'),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
