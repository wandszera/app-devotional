import 'package:app_devocional_mobile/src/features/app_shell.dart';
import 'package:app_devocional_mobile/src/features/auth/login_page.dart';
import 'package:app_devocional_mobile/src/features/home/home_page.dart';
import 'package:app_devocional_mobile/src/features/onboarding/notification_prompt_page.dart';
import 'package:app_devocional_mobile/src/features/onboarding/onboarding_page.dart';
import 'package:app_devocional_mobile/src/models/devotional_models.dart';
import 'package:app_devocional_mobile/src/models/notification_models.dart';
import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:app_devocional_mobile/src/services/push_sdk_bridge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('mostra login quando usuario nao esta autenticado', (
    WidgetTester tester,
  ) async {
    final authStore = _FakeAuthStore();

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          apiClient: _FakeApiClient(authStore: authStore),
          authStore: authStore,
          pushSdkBridge: const _FakePushSdkBridge(),
        ),
      ),
    );

    expect(find.byType(LoginPage), findsOneWidget);
  });

  testWidgets('mostra onboarding quando usuario autenticado ainda nao viu intro', (
    WidgetTester tester,
  ) async {
    final authStore = _FakeAuthStore()
      ..token = 'token'
      ..onboardingSeen = false
      ..notificationPromptSeen = false;

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          apiClient: _FakeApiClient(authStore: authStore),
          authStore: authStore,
          pushSdkBridge: const _FakePushSdkBridge(),
        ),
      ),
    );

    expect(find.byType(OnboardingPage), findsOneWidget);
  });

  testWidgets(
    'mostra setup de notificacao quando onboarding ja foi visto',
    (WidgetTester tester) async {
      final authStore = _FakeAuthStore()
        ..token = 'token'
        ..onboardingSeen = true
        ..notificationPromptSeen = false;

      await tester.pumpWidget(
        MaterialApp(
          home: AppShell(
            apiClient: _FakeApiClient(authStore: authStore),
            authStore: authStore,
            pushSdkBridge: const _FakePushSdkBridge(),
          ),
        ),
      );

      expect(find.byType(NotificationPromptPage), findsOneWidget);
    },
  );

  testWidgets('mostra home quando fluxo inicial ja foi concluido', (
    WidgetTester tester,
  ) async {
    final authStore = _FakeAuthStore()
      ..token = 'token'
      ..onboardingSeen = true
      ..notificationPromptSeen = true;

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          apiClient: _FakeApiClient(authStore: authStore),
          authStore: authStore,
          pushSdkBridge: const _FakePushSdkBridge(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(HomePage), findsOneWidget);
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Progresso'), findsOneWidget);
  });

  testWidgets('mostra tom e contexto de streak na fila admin de notificacoes', (
    WidgetTester tester,
  ) async {
    final authStore = _FakeAuthStore()
      ..token = 'token'
      ..isAdmin = true
      ..onboardingSeen = true
      ..notificationPromptSeen = true;

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          apiClient: _FakeApiClient(authStore: authStore),
          authStore: authStore,
          pushSdkBridge: const _FakePushSdkBridge(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Dispatch'));
    await tester.pumpAndSettle();

    expect(find.text('Marco'), findsOneWidget);
    expect(find.textContaining('Streak 2'), findsOneWidget);
    expect(find.textContaining('Proximo marco 3'), findsOneWidget);
    expect(find.textContaining('chegar a 3 dias'), findsOneWidget);
  });

  testWidgets('mostra insight humano na aba de progresso', (
    WidgetTester tester,
  ) async {
    final authStore = _FakeAuthStore()
      ..token = 'token'
      ..onboardingSeen = true
      ..notificationPromptSeen = true;

    await tester.pumpWidget(
      MaterialApp(
        home: AppShell(
          apiClient: _FakeApiClient(authStore: authStore),
          authStore: authStore,
          pushSdkBridge: const _FakePushSdkBridge(),
        ),
      ),
    );

    await tester.pumpAndSettle();
    await tester.tap(find.text('Progresso'));
    await tester.pumpAndSettle();

    expect(find.text('Status do habito'), findsWidgets);
    expect(find.textContaining('4 dias na ultima semana'), findsOneWidget);
    expect(find.textContaining('Marco 3'), findsOneWidget);
  });
}

class _FakeAuthStore extends AuthStore {}

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

class _FakeApiClient extends ApiClient {
  _FakeApiClient({required super.authStore}) : super(baseUrl: 'http://localhost');

  @override
  Future<DevotionalCardModel> getTodayDevotional() async {
    return DevotionalCardModel(
      id: 1,
      title: 'Devocional de teste',
      content: 'Conteudo de teste',
      date: '2026-05-01',
      completed: false,
      guidance: DevotionalGuidanceModel(
        title: 'Marco proximo',
        body: 'Falta so hoje para voce chegar a 3 dias seguidos. Vale a pena proteger esse ritmo.',
        accentLabel: 'Meta curta e clara',
        tone: 'milestone',
        currentStreak: 2,
        nextMilestone: 3,
      ),
    );
  }

  @override
  Future<DevotionalCompletionResultModel> completeTodayDevotional() async {
    return DevotionalCompletionResultModel(
      message: 'devotional completed',
      devotionalId: 1,
      feedback: DevotionalCompletionFeedbackModel(
        title: 'Marco alcançado',
        body: 'Voce chegou a 3 dias seguidos. Continue firme nesse ritmo simples e constante.',
        tone: 'milestone',
        currentStreak: 3,
        longestStreak: 3,
        milestoneHit: 3,
        nextMilestone: 7,
      ),
      streak: StreakModel(
        currentStreak: 3,
        longestStreak: 3,
        lastActivityDate: '2026-05-01',
        latestMilestone: 3,
      ),
    );
  }

  @override
  Future<StreakModel> getStreak() async {
    return StreakModel(
      currentStreak: 2,
      longestStreak: 4,
      lastActivityDate: '2026-04-30',
      latestMilestone: 3,
    );
  }

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    return NotificationSettingsModel(
      enabled: true,
      reminderTime: '08:00',
      timezone: 'America/Sao_Paulo',
      pushToken: 'push-token',
    );
  }

  @override
  Future<List<DueNotificationModel>> listDueNotifications() async {
    return [
      DueNotificationModel(
        userId: 7,
        email: 'user@example.com',
        reminderTime: '08:00',
        timezone: 'America/Sao_Paulo',
        tone: 'milestone',
        currentStreak: 2,
        nextMilestone: 3,
        message:
            'Esperanca para hoje ja esta pronto. Falta so hoje para voce chegar a 3 dias seguidos.',
        devotionalTitle: 'Esperanca para hoje',
      ),
    ];
  }

  @override
  Future<List<NotificationDeliveryModel>> listNotificationDeliveries() async {
    return [
      NotificationDeliveryModel(
        id: 1,
        userId: 7,
        scheduledFor: '2026-05-01T08:00:00Z',
        status: 'sent',
        provider: 'mock',
        title: 'Esperanca para hoje',
        message: 'Mensagem enviada',
        pushTokenSnapshot: 'push-token',
        providerMessageId: 'mock:1',
        errorMessage: '',
        createdAt: '2026-05-01T08:00:00Z',
        sentAt: '2026-05-01T08:00:00Z',
      ),
    ];
  }

  @override
  Future<List<ProgressEntry>> getProgress() async {
    return [
      ProgressEntry(date: '2026-05-01', completed: true),
      ProgressEntry(date: '2026-04-30', completed: true),
      ProgressEntry(date: '2026-04-29', completed: true),
      ProgressEntry(date: '2026-04-25', completed: true),
    ];
  }
}
