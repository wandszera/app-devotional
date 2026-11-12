import 'dart:convert';

import 'package:app_devocional_mobile/src/services/auth_refreshing_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

AuthStore _store() => AuthStore()
  ..token = 'old-access'
  ..refreshToken = 'old-refresh';

http.Response _json(Object body, int status) => http.Response(
      jsonEncode(body),
      status,
      headers: {'content-type': 'application/json'},
    );

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('renova a sessão em 401 e repete a requisição com o novo token',
      () async {
    final store = _store();
    final seenTokens = <String?>[];
    final client = AuthRefreshingClient(
      authStore: store,
      baseUrl: 'http://test',
      inner: MockClient((request) async {
        if (request.url.path == '/auth/refresh') {
          expect(jsonDecode(request.body)['refresh_token'], 'old-refresh');
          return _json({
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          }, 200);
        }
        seenTokens.add(request.headers['Authorization']);
        return request.headers['Authorization'] == 'Bearer new-access'
            ? _json({'ok': true}, 200)
            : _json({'detail': 'expired'}, 401);
      }),
    );

    final response = await client.get(
      Uri.parse('http://test/streak'),
      headers: {'Authorization': 'Bearer old-access'},
    );

    expect(response.statusCode, 200);
    expect(seenTokens, ['Bearer old-access', 'Bearer new-access']);
    expect(store.token, 'new-access');
    expect(store.refreshToken, 'new-refresh');
  });

  test('devolve o 401 original quando a renovação é recusada', () async {
    final store = _store();
    final client = AuthRefreshingClient(
      authStore: store,
      baseUrl: 'http://test',
      inner: MockClient((request) async => _json({'detail': 'no'}, 401)),
    );

    final response = await client.get(
      Uri.parse('http://test/streak'),
      headers: {'Authorization': 'Bearer old-access'},
    );

    expect(response.statusCode, 401);
    expect(store.refreshToken, 'old-refresh');
  });

  test('requisições simultâneas compartilham uma única renovação', () async {
    final store = _store();
    var refreshCalls = 0;
    final client = AuthRefreshingClient(
      authStore: store,
      baseUrl: 'http://test',
      inner: MockClient((request) async {
        if (request.url.path == '/auth/refresh') {
          refreshCalls++;
          return _json({
            'access_token': 'new-access',
            'refresh_token': 'new-refresh',
          }, 200);
        }
        return request.headers['Authorization'] == 'Bearer new-access'
            ? _json({'ok': true}, 200)
            : _json({'detail': 'expired'}, 401);
      }),
    );
    final headers = {'Authorization': 'Bearer old-access'};

    final responses = await Future.wait([
      client.get(Uri.parse('http://test/streak'), headers: headers),
      client.get(Uri.parse('http://test/progress'), headers: headers),
    ]);

    expect(responses.map((item) => item.statusCode), [200, 200]);
    expect(refreshCalls, 1);
  });

  test('não tenta renovar chamadas de /auth nem sem refresh token', () async {
    final store = _store();
    var calls = 0;
    final client = AuthRefreshingClient(
      authStore: store,
      baseUrl: 'http://test',
      inner: MockClient((request) async {
        calls++;
        return _json({'detail': 'invalid'}, 401);
      }),
    );

    final login = await client.post(
      Uri.parse('http://test/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: '{}',
    );
    expect(login.statusCode, 401);
    expect(calls, 1);

    store.refreshToken = null;
    final anonymous = await client.get(Uri.parse('http://test/streak'));
    expect(anonymous.statusCode, 401);
    expect(calls, 2);
  });
}
