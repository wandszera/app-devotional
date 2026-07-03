import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_store.dart';
import '../services/push_sdk_bridge.dart';
import 'auth/login_page.dart';
import 'home/home_page.dart';
import 'onboarding/notification_prompt_page.dart';
import 'onboarding/onboarding_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.apiClient,
    required this.authStore,
    required this.pushSdkBridge,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;
  final PushSdkBridge pushSdkBridge;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.authStore,
      builder: (context, _) {
        if (!widget.authStore.isAuthenticated) {
          return LoginPage(
            apiClient: widget.apiClient,
            authStore: widget.authStore,
            onAuthenticated: () {}, // O ListenableBuilder ja cuida do rebuild
          );
        }

        if (!widget.authStore.onboardingSeen) {
          return OnboardingPage(
            onFinished: () async {
              await widget.authStore.markOnboardingSeen();
            },
          );
        }

        if (!widget.authStore.notificationPromptSeen) {
          return NotificationPromptPage(
            apiClient: widget.apiClient,
            authStore: widget.authStore,
            pushSdkBridge: widget.pushSdkBridge,
            onFinished: () {}, // O ListenableBuilder cuida do rebuild se notificationPromptSeen mudar
          );
        }

        return HomePage(
          apiClient: widget.apiClient,
          authStore: widget.authStore,
          pushSdkBridge: widget.pushSdkBridge,
          onLogout: () {}, // O ListenableBuilder ja cuida do rebuild no logout
        );
      },
    );
  }
}
