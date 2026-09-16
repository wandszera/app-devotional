/// Contrato reutilizável para conteúdo editorial distribuído com o app hoje e
/// por uma API/CMS no futuro. Itens de catálogo nunca são criados no dispositivo
/// do usuário; apenas preferências privadas podem ser mantidas localmente.
class VersionedCatalog<T> {
  const VersionedCatalog({
    required this.version,
    required this.items,
  });

  final String version;
  final List<T> items;
}

abstract interface class CatalogSource<T> {
  Future<VersionedCatalog<T>> load();
}

