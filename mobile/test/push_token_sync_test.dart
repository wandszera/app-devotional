import 'dart:async';
import 'dart:convert';

import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:app_devocional_mobile/src/services/push_sdk_bridge.dart';
import 'package:app_devocional_mobile/src/services/push_token_sync.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Bridge implements PushSdkBridge, PushTokenRefreshSource {
  _Bridge(this.token, {this.granted = true});

  final String? token;
  final bool granted;
  final controller = StreamController<String>.broadcast();

  @override
  Stream<String> get onTokenRefresh => controller.stream;

  @override
  Future<PushSdkState> loadState() async => PushSdkState(
        sdkReady: true,
        isSupported: true,
        permissionStatus: granted
            ? PushPermissionStatus.granted
            : PushPermissionStatus.notDetermined,
        pushToken: granted ? token : null,
        statusMessage: '',
        helpMessage: '',
      );

  @override
  Future<PushSdkState> refreshStatus() => loadState();

  @override
  Future<PushSdkState> requestPermission() => loadState();
}

class _Server {
  _Server(this.pushToken);

  String pushToken;
  final puts = <String>[];

  MockClient get client => MockClient((request) async {
        if (request.method == 'PUT') {
          pushToken = (jsonDecode(request.body) as Map)['push_token'] as String;
          puts.add(pushToken);
        }
        return http.Response(
          jsonEncode({
            'enabled': true,
            'reminder_time': '07:30',
            'timezone': 'America/Sao_Paulo',
            'push_token': pushToken,
          }),
          200,
        );
      });
}

ApiClient _api(_Server server) => ApiClient(
      authStore: AuthStore(),
      baseUrl: 'http://test',
      client: server.client,
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('envia o token do aparelho quando o backend tem outro', () async {
    final server = _Server('');
    final sync = PushTokenSync(apiClient: _api(server), bridge: _Bridge('tok-1'));

    expect(await sync.sync(), isTrue);
    expect(server.puts, ['tok-1']);
  });

  test('preserva horário e fuso das configurações ao trocar o token', () async {
    final server = _Server('antigo');
    Map<String, dynamic>? body;
    final api = ApiClient(
      authStore: AuthStore(),
      baseUrl: 'http://test',
      client: MockClient((request) async {
        if (request.method == 'PUT') {
          body = jsonDecode(request.body) as Map<String, dynamic>;
        }
        return http.Response(
          jsonEncode({
            'enabled': false,
            'reminder_time': '07:30',
            'timezone': 'America/Sao_Paulo',
            'push_token': server.pushToken,
          }),
          200,
        );
      }),
    );

    await PushTokenSync(apiClient: api, bridge: _Bridge('novo')).sync();

    expect(body!['push_token'], 'novo');
    expect(body!['enabled'], false);
    expect(body!['reminder_time'], '07:30');
    expect(body!['timezone'], 'America/Sao_Paulo');
  });

  test('não faz PUT quando o token já está igual', () async {
    final server = _Server('tok-1');
    final sync = PushTokenSync(apiClient: _api(server), bridge: _Bridge('tok-1'));

    expect(await sync.sync(), isFalse);
    expect(server.puts, isEmpty);
  });

  test('não faz nada sem permissão/token do aparelho', () async {
    final server = _Server('');
    final sync = PushTokenSync(
      apiClient: _api(server),
      bridge: _Bridge(null, granted: false),
    );

    expect(await sync.sync(), isFalse);
    expect(server.puts, isEmpty);
  });

  test('engole erros de rede e devolve false', () async {
    final api = ApiClient(
      authStore: AuthStore(),
      baseUrl: 'http://test',
      client: MockClient((_) async => http.Response('erro', 500)),
    );

    expect(await PushTokenSync(apiClient: api, bridge: _Bridge('t')).sync(), isFalse);
  });

  test('reenvia quando o FCM renova o token', () async {
    final server = _Server('tok-1');
    final bridge = _Bridge('tok-1');
    final sync = PushTokenSync(apiClient: _api(server), bridge: bridge)..start();
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    bridge.controller.add('tok-2');
    await Future<void>.delayed(const Duration(milliseconds: 50));

    expect(server.puts, ['tok-2']);
    sync.stop();
  });
}
