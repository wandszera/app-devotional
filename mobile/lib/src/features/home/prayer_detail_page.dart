import 'package:flutter/material.dart';

import '../../models/prayer_models.dart';
import '../../services/prayer_store.dart';

class PrayerDetailPage extends StatefulWidget {
  const PrayerDetailPage({
    required this.prayer,
    required this.store,
    super.key,
  });

  final PrayerModel prayer;
  final PrayerLibraryRepository store;

  @override
  State<PrayerDetailPage> createState() => _PrayerDetailPageState();
}

class _PrayerDetailPageState extends State<PrayerDetailPage> {
  late PrayerModel prayer = widget.prayer;
  bool _savingFavorite = false;

  Future<void> _toggleFavorite() async {
    setState(() => _savingFavorite = true);
    final nextFavorite = !prayer.isFavorite;
    try {
      await widget.store.setFavorite(prayer.id, nextFavorite);
      if (!mounted) {
        return;
      }
      setState(() {
        prayer = prayer.copyWith(isFavorite: nextFavorite);
        _savingFavorite = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _savingFavorite = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível atualizar o favorito.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final metadata = [
      if (prayer.referenceAuthor?.isNotEmpty ?? false) prayer.referenceAuthor!,
      if (prayer.category?.isNotEmpty ?? false) prayer.category!,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Oração'),
        actions: [
          IconButton(
            tooltip: prayer.isFavorite
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: _savingFavorite ? null : _toggleFavorite,
            icon: Icon(
              prayer.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: prayer.isFavorite ? Colors.redAccent : null,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              prayer.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF382315),
                  ),
            ),
            if (metadata.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: metadata
                    .map((item) => Chip(label: Text(item)))
                    .toList(),
              ),
            ],
            const SizedBox(height: 28),
            SelectableText(
              prayer.text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    height: 1.75,
                    color: const Color(0xFF2C241B),
                  ),
            ),
            const SizedBox(height: 28),
            Text(
              'Texto publicado no catálogo do app. Favoritos são privados e ficam neste dispositivo.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF6E5A47),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

