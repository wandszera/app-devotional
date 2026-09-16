import '../models/gospel_models.dart';
import 'bundled_gospel_catalogue.dart';
import 'catalog_source.dart';
import 'local_db_service.dart';

/// Fonte editorial pública. A implementação empacotada pode ser substituída no
/// futuro por uma fonte de API/CMS sem mudar telas ou preferências privadas.
class BundledGospelCatalogSource implements CatalogSource<GospelModel> {
  const BundledGospelCatalogSource();

  @override
  Future<VersionedCatalog<GospelModel>> load() async {
    final entries = await BundledGospelCatalogue.instance.loadAll();
    return VersionedCatalog(
      version: '1',
      items: entries.values
          .map(
            (entry) => GospelModel(
              date: entry.date,
              title: entry.liturgicalTitle,
              reference: entry.gospelReference,
              text: entry.reflection,
              sourceUrl: entry.sourceUrl,
            ),
          )
          .toList(),
    );
  }
}

abstract interface class GospelLibraryRepository {
  Future<List<GospelCalendarEntry>> loadMonth(DateTime month);
  Future<void> setFavorite(String date, bool isFavorite);
  Future<void> saveNote(String date, String note);
}

class GospelLibraryStore implements GospelLibraryRepository {
  GospelLibraryStore({
    LocalDbService? localDb,
    CatalogSource<GospelModel>? catalogSource,
  })  : _localDb = localDb ?? LocalDbService(),
        _catalogSource = catalogSource ?? const BundledGospelCatalogSource();

  final LocalDbService _localDb;
  final CatalogSource<GospelModel> _catalogSource;

  @override
  Future<List<GospelCalendarEntry>> loadMonth(DateTime month) async {
    await _localDb.init();
    final catalog = await _catalogSource.load();
    final prefix = _monthPrefix(month);
    final personalStates = await _localDb.getGospelPersonalStates();

    return catalog.items
        .where((gospel) => gospel.date.startsWith(prefix))
        .map(
          (gospel) => GospelCalendarEntry(
            gospel: gospel,
            personalState: personalStates[gospel.date] ??
                const GospelPersonalState(isFavorite: false, note: null),
          ),
        )
        .toList()
      ..sort((left, right) => left.gospel.date.compareTo(right.gospel.date));
  }

  @override
  Future<void> setFavorite(String date, bool isFavorite) async {
    await _localDb.init();
    await _localDb.setGospelFavorite(date, isFavorite);
  }

  @override
  Future<void> saveNote(String date, String note) async {
    await _localDb.init();
    await _localDb.saveGospelNote(date, note);
  }

  String _monthPrefix(DateTime month) {
    return '${month.year.toString().padLeft(4, '0')}-${month.month.toString().padLeft(2, '0')}-';
  }
}

