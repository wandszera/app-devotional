import 'package:flutter/material.dart';

import '../../models/prayer_models.dart';
import '../../services/prayer_store.dart';
import 'home_state_widgets.dart';
import 'prayer_detail_page.dart';

class PrayersTab extends StatefulWidget {
  const PrayersTab({
    this.store,
    super.key,
  });

  final PrayerLibraryRepository? store;

  @override
  State<PrayersTab> createState() => _PrayersTabState();
}

class _PrayersTabState extends State<PrayersTab> {
  late final PrayerLibraryRepository _store =
      widget.store ?? PrayerLibraryStore();
  List<PrayerModel> _prayers = const [];
  bool _loading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    try {
      final prayers = await _store.list();
      if (!mounted) {
        return;
      }
      setState(() {
        _prayers = prayers;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _errorMessage = 'Não foi possível abrir o catálogo de orações.';
      });
    }
  }

  Future<void> _openPrayer(PrayerModel prayer) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => PrayerDetailPage(prayer: prayer, store: _store),
      ),
    );
    await _load();
  }

  Future<void> _toggleFavorite(PrayerModel prayer) async {
    try {
      await _store.setFavorite(prayer.id, !prayer.isFavorite);
      await _load();
    } catch (_) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o favorito.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const HomeLoadingView();
    }
    if (_errorMessage != null) {
      return HomeErrorView(message: _errorMessage!);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Orações publicadas',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF382315),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Catálogo editorial incluído nesta versão do app. Seus favoritos ficam apenas neste dispositivo.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF6E5A47),
                ),
          ),
          const SizedBox(height: 20),
          if (_prayers.isEmpty)
            const HomeEmptyCard(
              message: 'Novas orações serão publicadas nas próximas atualizações do app.',
            )
          else
            ..._prayers.map(
              (prayer) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  title: Text(
                    prayer.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    prayer.referenceAuthor?.isNotEmpty ?? false
                        ? prayer.referenceAuthor!
                        : 'Oração publicada',
                  ),
                  leading: prayer.category?.isNotEmpty ?? false
                      ? CircleAvatar(child: Text(prayer.category![0]))
                      : const CircleAvatar(child: Icon(Icons.auto_stories)),
                  trailing: IconButton(
                    tooltip: prayer.isFavorite
                        ? 'Remover dos favoritos'
                        : 'Adicionar aos favoritos',
                    onPressed: () => _toggleFavorite(prayer),
                    icon: Icon(
                      prayer.isFavorite
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: prayer.isFavorite ? Colors.redAccent : null,
                    ),
                  ),
                  onTap: () => _openPrayer(prayer),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

