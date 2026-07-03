import 'package:app_devocional_mobile/src/features/home/admin_devotionals_tab_controller.dart';
import 'package:app_devocional_mobile/src/features/home/admin_notifications_tab_controller.dart';
import 'package:app_devocional_mobile/src/features/home/progress_tab_controller.dart';
import 'package:app_devocional_mobile/src/features/home/settings_tab_controller.dart';
import 'package:app_devocional_mobile/src/features/home/today_tab_controller.dart';
import 'package:app_devocional_mobile/src/models/devotional_models.dart';
import 'package:app_devocional_mobile/src/models/notification_models.dart';
import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:app_devocional_mobile/src/services/push_sdk_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TodayTabController', () {
    test('carrega devocional e streak com sucesso', () async {
      final controller = TodayTabController(
        apiClient: _FakeApiClient(authStore: _FakeAuthStore()),
      );

      await controller.load();

      expect(controller.state.devotional?.title, 'Devocional de teste');
      expect(controller.state.streak?.currentStreak, 2);
      expect(controller.state.status.loading, isFalse);
      expect(controller.state.status.errorMessage, isNull);
    });

    test('mantem erro amigavel quando a API falha', () async {
      final controller = TodayTabController(
        apiClient: _FakeApiClient(
          authStore: _FakeAuthStore(),
          failTodayLoad: true,
        ),
      );

      await controller.load();

      expect(controller.state.devotional, isNull);
      expect(controller.state.status.loading, isFalse);
      expect(controller.state.status.errorMessage, 'Falha ao carregar hoje');
    });

    test('completa o devocional e recarrega o estado', () async {
      final apiClient = _FakeApiClient(authStore: _FakeAuthStore());
      final controller = TodayTabController(apiClient: apiClient);

      await controller.complete();

      expect(apiClient.completeCalls, 1);
      expect(controller.state.devotional?.completed, isTrue);
      expect(controller.state.streak?.currentStreak, 3);
      expect(controller.state.status.submitting, isFalse);
    });
  });

  group('ProgressTabController', () {
    test('carrega progresso e streak', () async {
      final controller = ProgressTabController(
        apiClient: _FakeApiClient(authStore: _FakeAuthStore()),
      );

      await controller.load();

      expect(controller.state.progress, hasLength(3));
      expect(controller.state.streak?.longestStreak, 4);
      expect(controller.state.status.loading, isFalse);
    });
  });

  group('SettingsTabController', () {
    test('carrega ajustes e estado do SDK', () async {
      final controller = SettingsTabController(
        apiClient: _FakeApiClient(authStore: _FakeAuthStore()),
        pushSdkBridge: const _FakePushSdkBridge(),
      );

      await controller.load();
      await controller.loadPushSdkState();

      expect(controller.state.settings?.reminderTime, '08:00');
      expect(controller.state.pushSdkState?.hasPushToken, isTrue);
      expect(controller.state.status.errorMessage, isNull);
    });

    test('salva ajustes usando token do SDK quando disponivel', () async {
      final apiClient = _FakeApiClient(authStore: _FakeAuthStore());
      final controller = SettingsTabController(
        apiClient: apiClient,
        pushSdkBridge: const _FakePushSdkBridge(),
      );

      await controller.load();
      final saved = await controller.save(
        enabled: false,
        reminderTime: ' 09:30 ',
        timezone: ' America/Sao_Paulo ',
      );

      expect(saved?.enabled, isFalse);
      expect(saved?.reminderTime, '09:30');
      expect(saved?.timezone, 'America/Sao_Paulo');
      expect(saved?.pushToken, 'push-token');
      expect(apiClient.lastSavedSettings?.pushToken, 'push-token');
      expect(controller.state.status.submitting, isFalse);
    });

    test('toggleEnabled atualiza estado local e persiste mudanca', () async {
      final apiClient = _FakeApiClient(authStore: _FakeAuthStore());
      final controller = SettingsTabController(
        apiClient: apiClient,
        pushSdkBridge: const _FakePushSdkBridge(),
      );

      await controller.load();
      final saved = await controller.toggleEnabled(false);

      expect(controller.state.settings?.enabled, isFalse);
      expect(saved?.enabled, isFalse);
      expect(apiClient.lastSavedSettings?.enabled, isFalse);
    });
  });

  group('AdminNotificationsTabController', () {
    test('carrega fila e historico de entregas', () async {
      final controller = AdminNotificationsTabController(
        apiClient: _FakeApiClient(authStore: _FakeAuthStore()),
      );

      await controller.load();

      expect(controller.state.dueNotifications, hasLength(1));
      expect(controller.state.deliveries, hasLength(1));
      expect(controller.state.status.loading, isFalse);
    });

    test('dispatch envia notificacoes e recarrega os dados', () async {
      final apiClient = _FakeApiClient(authStore: _FakeAuthStore());
      final controller = AdminNotificationsTabController(apiClient: apiClient);

      final items = await controller.dispatch();

      expect(items, hasLength(1));
      expect(apiClient.dispatchCalls, 1);
      expect(controller.state.status.submitting, isFalse);
      expect(controller.state.deliveries, hasLength(1));
    });
  });

  group('AdminDevotionalsTabController', () {
    test('carrega lista de devocionais administrativos', () async {
      final controller = AdminDevotionalsTabController(
        apiClient: _FakeApiClient(authStore: _FakeAuthStore()),
      );

      await controller.load();

      expect(controller.state.devotionals, hasLength(2));
      expect(controller.state.devotionals.first.title, 'Esperanca para hoje');
      expect(controller.state.status.loading, isFalse);
      expect(controller.state.status.errorMessage, isNull);
    });

    test('mantem erro amigavel quando o carregamento falha', () async {
      final controller = AdminDevotionalsTabController(
        apiClient: _FakeApiClient(
          authStore: _FakeAuthStore(),
          failAdminDevotionalsLoad: true,
        ),
      );

      await controller.load();

      expect(controller.state.devotionals, isEmpty);
      expect(controller.state.status.loading, isFalse);
      expect(
        controller.state.status.errorMessage,
        'Falha ao carregar devocionais',
      );
    });

    test('delete remove item e recarrega estado', () async {
      final apiClient = _FakeApiClient(authStore: _FakeAuthStore());
      final controller = AdminDevotionalsTabController(apiClient: apiClient);

      await controller.load();
      await controller.delete(1);

      expect(apiClient.deletedDevotionalIds, [1]);
      expect(controller.state.devotionals, hasLength(1));
      expect(controller.state.devotionals.single.id, 2);
      expect(controller.state.status.loading, isFalse);
    });
  });
}

class _FakeAuthStore extends AuthStore {}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({
    required super.authStore,
    this.failTodayLoad = false,
    this.failAdminDevotionalsLoad = false,
  }) : super(baseUrl: 'http://localhost');

  final bool failTodayLoad;
  final bool failAdminDevotionalsLoad;

  int completeCalls = 0;
  int dispatchCalls = 0;
  final List<int> deletedDevotionalIds = [];
  NotificationSettingsModel? lastSavedSettings;
  bool _completedToday = false;
  final List<AdminDevotional> _adminDevotionals = [
    AdminDevotional(
      id: 1,
      title: 'Esperanca para hoje',
      content: 'Conteudo do primeiro dia',
      date: '2026-05-01',
    ),
    AdminDevotional(
      id: 2,
      title: 'Constancia de amanha',
      content: 'Conteudo do segundo dia',
      date: '2026-05-02',
    ),
  ];

  @override
  Future<DevotionalCardModel> getTodayDevotional() async {
    if (failTodayLoad) {
      throw ApiException('Falha ao carregar hoje');
    }

    return DevotionalCardModel(
      id: 1,
      title: 'Devocional de teste',
      content: 'Conteudo',
      date: '2026-05-01',
      completed: _completedToday,
      guidance: DevotionalGuidanceModel(
        title: 'Siga no ritmo',
        body: 'Hoje ainda conta.',
        accentLabel: 'Continue',
        tone: 'building',
        currentStreak: _completedToday ? 3 : 2,
        nextMilestone: 3,
      ),
    );
  }

  @override
  Future<DevotionalCompletionResultModel> completeTodayDevotional() async {
    completeCalls += 1;
    _completedToday = true;
    return DevotionalCompletionResultModel(
      message: 'ok',
      devotionalId: 1,
      feedback: DevotionalCompletionFeedbackModel(
        title: 'Concluido',
        body: 'Bom trabalho',
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
      currentStreak: _completedToday ? 3 : 2,
      longestStreak: 4,
      lastActivityDate: '2026-05-01',
      latestMilestone: 3,
    );
  }

  @override
  Future<List<ProgressEntry>> getProgress() async {
    return [
      ProgressEntry(date: '2026-05-01', completed: true),
      ProgressEntry(date: '2026-04-30', completed: true),
      ProgressEntry(date: '2026-04-29', completed: false),
    ];
  }

  @override
  Future<NotificationSettingsModel> getNotificationSettings() async {
    return lastSavedSettings ??
        NotificationSettingsModel(
          enabled: true,
          reminderTime: '08:00',
          timezone: 'America/Sao_Paulo',
          pushToken: '',
        );
  }

  @override
  Future<NotificationSettingsModel> updateNotificationSettings(
    NotificationSettingsModel settings,
  ) async {
    lastSavedSettings = settings;
    return settings;
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
        message: 'Falta so hoje.',
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
  Future<List<NotificationDispatchItemModel>> dispatchDueNotifications() async {
    dispatchCalls += 1;
    return [
      NotificationDispatchItemModel(
        userId: 7,
        status: 'sent',
        delivery: NotificationDeliveryModel(
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
      ),
    ];
  }

  @override
  Future<List<AdminDevotional>> listAdminDevotionals() async {
    if (failAdminDevotionalsLoad) {
      throw ApiException('Falha ao carregar devocionais');
    }

    return List<AdminDevotional>.unmodifiable(_adminDevotionals);
  }

  @override
  Future<void> deleteAdminDevotional(int devotionalId) async {
    deletedDevotionalIds.add(devotionalId);
    _adminDevotionals.removeWhere((item) => item.id == devotionalId);
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
      helpMessage: 'Bridge fake',
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
