import 'dart:io';

import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _key = 'pending_completions_anonymous';

ApiClient _client(MockClient mock) =>
    ApiClient(authStore: AuthStore(), baseUrl: 'http://test', client: mock);

void main() {
  test('envia todas as datas pendentes em ordem e esvazia a fila', () async {
    SharedPreferences.setMockInitialValues({
      _key: ['2026-11-11', '2026-11-09'],
    });
    final dates = <String?>[];
    final api = _client(MockClient((request) async {
      expect(request.url.path, '/devotional/complete');
      dates.add(request.url.queryParameters['completed_date']);
      return http.Response('{}', 200);
    }));

    await api.syncPendingCompletions();

    expect(dates, ['2026-11-09', '2026-11-11']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(_key), isNull);
  });

  test('mantém datas na fila quando o servidor falha e para no primeiro erro',
      () async {
    SharedPreferences.setMockInitialValues({
      _key: ['2026-11-09', '2026-11-10'],
    });
    var calls = 0;
    final api = _client(MockClient((request) async {
      calls++;
      return http.Response('erro', 500);
    }));

    await api.syncPendingCompletions();

    expect(calls, 1);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(_key), ['2026-11-09', '2026-11-10']);
  });

  test('sem rede não perde nada; erro 404 descarta só a data inválida',
      () async {
    SharedPreferences.setMockInitialValues({
      _key: ['2026-11-09'],
    });
    final offline = _client(MockClient(
      (request) async => throw const SocketException('sem rede'),
    ));
    await offline.syncPendingCompletions();
    var prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(_key), ['2026-11-09']);

    final notFound = _client(MockClient(
      (request) async => http.Response('{"detail":"not found"}', 404),
    ));
    await notFound.syncPendingCompletions();
    prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList(_key), isNull);
  });

  test('migra a data única do formato antigo para a fila', () async {
    SharedPreferences.setMockInitialValues({
      'pending_completion_anonymous': '2026-11-08',
    });
    final dates = <String?>[];
    final api = _client(MockClient((request) async {
      dates.add(request.url.queryParameters['completed_date']);
      return http.Response('{}', 200);
    }));

    await api.syncPendingCompletions();

    expect(dates, ['2026-11-08']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('pending_completion_anonymous'), isNull);
    expect(prefs.getStringList(_key), isNull);
  });
}
