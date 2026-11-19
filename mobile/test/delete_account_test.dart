import 'dart:convert';

import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuthStore _store() => AuthStore()
  ..token = 'access'
  ..refreshToken = 'refresh'
  ..userId = 7
  ..email = 'a@b.com';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({
        'pending_completions_7': ['2026-11-18'],
      }));

  test('204 limpa sessão e fila offline', () async {
    final store = _store();
    late http.Request seen;
    final api = ApiClient(
      authStore: store,
      baseUrl: 'http://test',
      client: MockClient((request) async {
        seen = request;
        return http.Response('', 204);
      }),
    );

    await api.deleteAccount(password: 'segredo');

    expect(seen.method, 'DELETE');
    expect(seen.url.path, '/auth/me');
    expect(seen.headers['Authorization'], 'Bearer access');
    expect(jsonDecode(seen.body), {'password': 'segredo'});
    expect(store.isAuthenticated, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('pending_completions_7'), isNull);
  });

  test('envia id_token para conta Google', () async {
    final api = ApiClient(
      authStore: _store(),
      baseUrl: 'http://test',
      client: MockClient((request) async {
        expect(jsonDecode(request.body), {'id_token': 'tok'});
        return http.Response('', 204);
      }),
    );
    await api.deleteAccount(idToken: 'tok');
  });

  test('403 mantém a sessão e mostra a mensagem do servidor', () async {
    final store = _store();
    final api = ApiClient(
      authStore: store,
      baseUrl: 'http://test',
      client: MockClient((_) async =>
          http.Response(jsonEncode({'detail': 'senha incorreta'}), 403)),
    );

    await expectLater(
      api.deleteAccount(password: 'errada'),
      throwsA(isA<ApiException>()
          .having((e) => e.message, 'message', 'senha incorreta')),
    );
    expect(store.isAuthenticated, isTrue);
  });
}
