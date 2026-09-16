import 'package:app_devocional_mobile/src/features/home/prayers_tab.dart';
import 'package:app_devocional_mobile/src/models/prayer_models.dart';
import 'package:app_devocional_mobile/src/services/prayer_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('catálogo empacotado tem versão e exemplos editoriais identificados', () async {
    const source = BundledPrayerCatalogSource();

    final catalog = await source.load();

    expect(catalog.version, '1');
    expect(catalog.items, hasLength(2));
    expect(catalog.items.first.text, contains('Exemplo editorial'));
    expect(catalog.items.map((prayer) => prayer.referenceAuthor), contains(
      contains('Santo Inácio de Loyola'),
    ));
  });

  testWidgets('exibe catálogo público e salva favorito apenas no repositório local', (
    WidgetTester tester,
  ) async {
    final store = _FakePrayerLibrary();

    await tester.pumpWidget(
      MaterialApp(home: PrayersTab(store: store)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Orações publicadas'), findsOneWidget);
    expect(find.text('Oração de teste'), findsOneWidget);
    expect(find.textContaining('Catálogo editorial'), findsOneWidget);

    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pumpAndSettle();

    expect(store.favoriteUpdates, [('prayer-1', true)]);
    expect(find.byTooltip('Remover dos favoritos'), findsOneWidget);

    await tester.tap(find.text('Oração de teste'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Texto publicado no catálogo do app.'), findsOneWidget);
    expect(find.text('Texto de oração de teste.'), findsOneWidget);
  });
}

class _FakePrayerLibrary implements PrayerLibraryRepository {
  final List<(String, bool)> favoriteUpdates = [];
  var _isFavorite = false;

  @override
  Future<List<PrayerModel>> list() async {
    return [
      PrayerModel(
        id: 'prayer-1',
        title: 'Oração de teste',
        text: 'Texto de oração de teste.',
        referenceAuthor: 'Referência editorial',
        category: 'Gratidão',
        isFavorite: _isFavorite,
        createdAt: DateTime.utc(2026, 9, 3),
        updatedAt: DateTime.utc(2026, 9, 3),
      ),
    ];
  }

  @override
  Future<void> setFavorite(String prayerId, bool isFavorite) async {
    favoriteUpdates.add((prayerId, isFavorite));
    _isFavorite = isFavorite;
  }
}

