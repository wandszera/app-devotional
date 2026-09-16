import '../models/prayer_models.dart';
import 'catalog_source.dart';
import 'local_db_service.dart';

class BundledPrayerCatalogSource implements CatalogSource<PrayerModel> {
  const BundledPrayerCatalogSource();

  static final DateTime _publishedAt = DateTime.utc(2026, 9, 3);

  @override
  Future<VersionedCatalog<PrayerModel>> load() async {
    return VersionedCatalog(
      version: '1',
      items: [
        PrayerModel(
          id: 'discernimento-inaciano-exemplo',
          title: 'Discernimento no cotidiano',
          text:
              'Exemplo editorial: conduze meus passos para escolhas simples, honestas e voltadas ao bem.',
          referenceAuthor: 'Santo Inácio de Loyola (referência temática)',
          category: 'Discernimento',
          isFavorite: false,
          createdAt: _publishedAt,
          updatedAt: _publishedAt,
        ),
        PrayerModel(
          id: 'confianca-teresiana-exemplo',
          title: 'Confiança e presença',
          text:
              'Exemplo editorial: dá-me serenidade para acolher este dia, presença para amar e coragem para recomeçar.',
          referenceAuthor: "Santa Teresa d'Ávila (referência temática)",
          category: 'Confiança',
          isFavorite: false,
          createdAt: _publishedAt,
          updatedAt: _publishedAt,
        ),
      ],
    );
  }
}

abstract interface class PrayerLibraryRepository {
  Future<List<PrayerModel>> list();
  Future<void> setFavorite(String prayerId, bool isFavorite);
}

class PrayerLibraryStore implements PrayerLibraryRepository {
  PrayerLibraryStore({
    LocalDbService? localDb,
    CatalogSource<PrayerModel>? catalogSource,
  })  : _localDb = localDb ?? LocalDbService(),
        _catalogSource = catalogSource ?? const BundledPrayerCatalogSource();

  final LocalDbService _localDb;
  final CatalogSource<PrayerModel> _catalogSource;

  @override
  Future<List<PrayerModel>> list() async {
    await _localDb.init();
    final catalog = await _catalogSource.load();
    final favoriteIds = await _localDb.getFavoritePrayerIds();
    return catalog.items
        .map(
          (prayer) => prayer.copyWith(
            isFavorite: favoriteIds.contains(prayer.id),
          ),
        )
        .toList()
      ..sort((left, right) {
        if (left.isFavorite != right.isFavorite) {
          return left.isFavorite ? -1 : 1;
        }
        return left.title.compareTo(right.title);
      });
  }

  @override
  Future<void> setFavorite(String prayerId, bool isFavorite) async {
    await _localDb.init();
    await _localDb.setPrayerFavorite(prayerId, isFavorite);
  }
}

