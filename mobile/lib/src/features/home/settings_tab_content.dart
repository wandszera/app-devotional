import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/push_sdk_bridge.dart';
import '../../models/notification_models.dart';
import 'settings_widgets.dart';
import 'profile_page.dart';

class SettingsTabContent extends StatelessWidget {
  const SettingsTabContent({
    required this.apiClient,
    required this.authStore,
    required this.baseUrl,
    required this.settings,
    required this.pushSdkState,
    required this.timeController,
    required this.timezoneController,
    required this.pushTokenController,
    required this.submitting,
    required this.onLogout,
    required this.onRefreshPushState,
    required this.onRequestPermission,
    required this.onToggleEnabled,
    required this.onPickReminderTime,
    required this.onSave,
    required this.onOpenFavorites,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;
  final String baseUrl;
  final NotificationSettingsModel settings;
  final PushSdkState? pushSdkState;
  final TextEditingController timeController;
  final TextEditingController timezoneController;
  final TextEditingController pushTokenController;
  final bool submitting;
  final VoidCallback onLogout;
  final Future<void> Function() onRefreshPushState;
  final Future<void> Function() onRequestPermission;
  final ValueChanged<bool> onToggleEnabled;
  final VoidCallback onPickReminderTime;
  final VoidCallback onSave;
  final VoidCallback onOpenFavorites;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.favorite, color: Colors.redAccent),
          title: const Text('Meus Favoritos'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onOpenFavorites,
        ),
        const Divider(),
        ListenableBuilder(
          listenable: Listenable.merge([]), // Não temos um listenable direto pro authStore, mas o rebuild acontece no state
          builder: (context, _) => SettingsAccountCard(
            email: authStore.email,
            name: authStore.name,
            bio: authStore.bio,
            onLogout: onLogout,
            onEditProfile: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ProfilePage(
                    apiClient: apiClient,
                    authStore: authStore,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        SettingsApiBaseCard(
          baseUrl: baseUrl,
        ),
        const SizedBox(height: 12),
        PushSdkInfoCard(
          state: pushSdkState,
          savedPushToken: settings.pushToken,
          onRefresh: onRefreshPushState,
          onRequestPermission: onRequestPermission,
        ),
        const SizedBox(height: 12),
        SettingsReminderForm(
          enabled: settings.enabled,
          timeController: timeController,
          timezoneController: timezoneController,
          pushTokenController: pushTokenController,
          onToggleEnabled: onToggleEnabled,
          onPickReminderTime: onPickReminderTime,
          onSave: onSave,
          submitting: submitting,
        ),
      ],
    );
  }
}
