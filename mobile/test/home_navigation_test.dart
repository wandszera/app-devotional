import 'package:app_devocional_mobile/src/features/home/home_navigation.dart';
import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:app_devocional_mobile/src/services/push_sdk_bridge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('monta abas padrao para usuario comum', () {
    final authStore = _FakeAuthStore();

    final tabs = buildHomeTabDefinitions(
      apiClient: _FakeApiClient(authStore: authStore),
      authStore: authStore,
      pushSdkBridge: const _FakePushSdkBridge(),
      onLogout: () {},
    );

    expect(tabs.map((tab) => tab.destination.label), [
      'Hoje',
      'Progresso',
      'Ajustes',
    ]);
  });

  test('inclui abas administrativas para admin', () {
    final authStore = _FakeAuthStore()..isAdmin = true;

    final tabs = buildHomeTabDefinitions(
      apiClient: _FakeApiClient(authStore: authStore),
      authStore: authStore,
      pushSdkBridge: const _FakePushSdkBridge(),
      onLogout: () {},
    );

    expect(tabs.map((tab) => tab.destination.label), [
      'Hoje',
      'Progresso',
      'Ajustes',
      'Admin',
      'Dispatch',
    ]);
  });
}

class _FakeAuthStore extends AuthStore {}

class _FakeApiClient extends ApiClient {
  _FakeApiClient({required super.authStore}) : super(baseUrl: 'http://localhost');
}

class _FakePushSdkBridge implements PushSdkBridge {
  const _FakePushSdkBridge();

  @override
  Future<PushSdkState> loadState() {
    throw UnimplementedError();
  }

  @override
  Future<PushSdkState> refreshStatus() {
    throw UnimplementedError();
  }

  @override
  Future<PushSdkState> requestPermission() {
    throw UnimplementedError();
  }
}
