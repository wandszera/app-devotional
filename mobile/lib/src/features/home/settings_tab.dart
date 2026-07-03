import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/push_sdk_bridge.dart';
import 'favorites_page.dart';
import 'home_feedback.dart';
import 'home_state_widgets.dart';
import 'settings_support.dart';
import 'settings_tab_controller.dart';
import 'settings_tab_content.dart';
import 'settings_widgets.dart';

class SettingsTab extends StatefulWidget {
  const SettingsTab({
    required this.apiClient,
    required this.authStore,
    required this.pushSdkBridge,
    required this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;
  final PushSdkBridge pushSdkBridge;
  final VoidCallback onLogout;

  @override
  State<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends State<SettingsTab> {
  late final SettingsTabController controller;
  final timeController = TextEditingController();
  final timezoneController = TextEditingController();
  final pushTokenController = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller = SettingsTabController(
      apiClient: widget.apiClient,
      pushSdkBridge: widget.pushSdkBridge,
    );
    controller.addListener(_syncFieldsFromState);
    controller.load();
    controller.loadPushSdkState();
  }

  @override
  void dispose() {
    controller.removeListener(_syncFieldsFromState);
    controller.dispose();
    timeController.dispose();
    timezoneController.dispose();
    pushTokenController.dispose();
    super.dispose();
  }

  void _syncFieldsFromState() {
    final settings = controller.state.settings;
    if (settings == null) {
      return;
    }
    SettingsSupport.syncTextController(timeController, settings.reminderTime);
    SettingsSupport.syncTextController(timezoneController, settings.timezone);
    SettingsSupport.syncTextController(pushTokenController, settings.pushToken);
  }

  Future<void> _save() async {
    try {
      final current = controller.state.settings;
      if (current == null) {
        return;
      }
      await controller.save(
        enabled: current.enabled,
        reminderTime: timeController.text,
        timezone: timezoneController.text,
        pushToken: pushTokenController.text,
      );
      if (!mounted) {
        return;
      }
      HomeFeedback.showSuccess(context, 'Notificacoes atualizadas');
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      HomeFeedback.showError(context, error.message);
    }
  }

  Future<void> _toggleEnabled(bool value) async {
    try {
      await controller.toggleEnabled(value);
      if (!mounted) {
        return;
      }
      HomeFeedback.showSuccess(context, 'Notificacoes atualizadas');
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      HomeFeedback.showError(context, error.message);
    }
  }

  Future<void> _logout() async {
    await widget.authStore.clear();
    widget.onLogout();
  }

  Future<void> _pickReminderTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: SettingsSupport.initialReminderTime(timeController.text),
    );
    if (selected == null) {
      return;
    }

    setState(() {
      timeController.text = SettingsSupport.formatReminderTime(selected);
    });
  }

  void _openFavorites() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FavoritesPage(apiClient: widget.apiClient),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        if (state.status.errorMessage != null) {
          return HomeErrorView(message: state.status.errorMessage!);
        }

        final settings = state.settings;
        if (state.status.loading || settings == null) {
          return const HomeLoadingView();
        }

        return SettingsTabContent(
          apiClient: widget.apiClient,
          authStore: widget.authStore,
          baseUrl: widget.apiClient.baseUrl,
          settings: settings,
          pushSdkState: state.pushSdkState,
          timeController: timeController,
          timezoneController: timezoneController,
          pushTokenController: pushTokenController,
          submitting: state.status.submitting,
          onLogout: _logout,
          onRefreshPushState: controller.refreshPushSdkState,
          onRequestPermission: controller.requestPushPermission,
          onToggleEnabled: _toggleEnabled,
          onPickReminderTime: _pickReminderTime,
          onSave: _save,
          onOpenFavorites: _openFavorites,
        );
      },
    );
  }
}
