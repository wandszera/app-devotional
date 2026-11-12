import 'dart:convert';
import 'dart:io';

import 'package:app_devocional_mobile/src/models/gospel_models.dart';
import 'package:app_devocional_mobile/src/services/api_client.dart';
import 'package:app_devocional_mobile/src/services/auth_store.dart';
import 'package:app_devocional_mobile/src/services/catalog_source.dart';
import 'package:app_devocional_mobile/src/services/gospel_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

class _FallbackSource implements CatalogSource<GospelModel> {
  @override
  Future<VersionedCatalog<GospelModel>> load() async => const VersionedCatalog(
        version: 'bundle',
        items: [
          GospelModel(
            date: '2026-09-01',
            title: 'Do bundle',
            reference: 'Lc 4,31-37',
            text: 'Texto do bundle',
          ),
        ],
      );
}

ApiGospelCatalogSource _source() => ApiGospelCatalogSource(
      apiClient: ApiClient(authStore: AuthStore(), baseUrl: 'http://test'),
      fallback: _FallbackSource(),
    );

void main() {
  test('usa o conteúdo da API como fonte canônica', () async {
    final catalog = await http.runWithClient(
      () => _source().load(),
      () => MockClient((request) async {
        expect(request.url.path, '/devotional/calendar');
        return http.Response(
          jsonEncode({
            'devotionals': [
              {
                'id': 1,
                'title': 'Evangelho do dia',
                'content': 'Texto da API',
                'date': '2026-09-01',
                'liturgical_title': 'Da API',
                'gospel_reference': 'Mc 1,1-8',
                'source_url': 'https://exemplo.org',
              },
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    expect(catalog.version, 'api');
    expect(catalog.items.single.text, 'Texto da API');
    expect(catalog.items.single.reference, 'Mc 1,1-8');
  });

  test('cai no bundle quando a API está offline', () async {
    final catalog = await http.runWithClient(
      () => _source().load(),
      () => MockClient((request) async => throw const SocketException('off')),
    );

    expect(catalog.version, 'bundle');
  });

  test('cai no bundle quando a API não tem conteúdo publicado', () async {
    final catalog = await http.runWithClient(
      () => _source().load(),
      () => MockClient(
        (request) async => http.Response(
          jsonEncode({'devotionals': []}),
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );

    expect(catalog.version, 'bundle');
  });
}
