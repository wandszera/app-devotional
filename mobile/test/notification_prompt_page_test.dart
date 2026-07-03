import 'package:app_devocional_mobile/src/features/onboarding/notification_prompt_page.dart';
import 'package:app_devocional_mobile/src/models/notification_models.dart';
import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:app_devocional_mobile/src/services/push_sdk_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('salva lembrete padrao e conclui etapa do setup inicial', (
    WidgetTester tester,
  ) async {
    final authStore = _FakeAuthStore();
    final apiClient = _FakeNotificationApiClient(authStore: authStore);
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationPromptPage(
          apiClient: apiClient,
          authStore: authStore,
          pushSdkBridge: const _FakePushSdkBridge(),
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    final saveButton = find.text('Salvar lembrete');

    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      saveButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(apiClient.savedSettings, isNotNull);
    expect(apiClient.savedSettings!.enabled, isTrue);
    expect(apiClient.savedSettings!.reminderTime, '08:00');
    expect(apiClient.savedSettings!.timezone, 'America/Sao_Paulo');
    expect(apiClient.savedSettings!.pushToken, 'push-token');
    expect(authStore.notificationPromptMarked, isTrue);
    expect(finished, isTrue);
  });

  testWidgets('permite pular o setup inicial sem salvar configuracoes', (
    WidgetTester tester,
  ) async {
    final authStore = _FakeAuthStore();
    final apiClient = _FakeNotificationApiClient(authStore: authStore);
    var finished = false;

    await tester.pumpWidget(
      MaterialApp(
        home: NotificationPromptPage(
          apiClient: apiClient,
          authStore: authStore,
          pushSdkBridge: const _FakePushSdkBridge(),
          onFinished: () {
            finished = true;
          },
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Depois'));
    await tester.pumpAndSettle();

    expect(apiClient.savedSettings, isNull);
    expect(authStore.notificationPromptMarked, isTrue);
    expect(finished, isTrue);
  });
}

class _FakeAuthStore extends AuthStore {
  bool notificationPromptMarked = false;

  @override
  Future<void> markNotificationPromptSeen() async {
    notificationPromptSeen = true;
    notificationPromptMarked = true;
  }
}

class _FakePushSdkBridge implements PushSdkBridge {
  const _FakePushSdkBridge();

  @override
  Future<PushSdkState> loadState() async {
    return const PushSdkState(
      sdkReady: true,
      isSupported: true,
      permissionStatus: PushPermissionStatus.granted,
      pushToken: 'push-token',
      statusMessage: 'SDK pronto',
      helpMessage: 'Bridge fake para testes.',
    );
  }

  @override
  Future<PushSdkState> refreshStatus() async {
    return loadState();
  }

  @override
  Future<PushSdkState> requestPermission() async {
    return loadState();
  }
}

class _FakeNotificationApiClient extends ApiClient {
  _FakeNotificationApiClient({required super.authStore})
    : super(baseUrl: 'http://localhost');

  NotificationSettingsModel? savedSettings;

  @override
  Future<NotificationSettingsModel> updateNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    savedSettings = settings;
    return settings;
  }
}
