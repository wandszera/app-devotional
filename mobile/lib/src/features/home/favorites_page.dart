import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';
import '../../services/api_client.dart';
import 'devotional_reader_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Future<List<AdminDevotional>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    setState(() {
      _favoritesFuture = widget.apiClient.getFavorites();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Favoritos'),
      ),
      body: FutureBuilder<List<AdminDevotional>>(
        future: _favoritesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erro ao carregar favoritos',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            );
          }

          final favorites = snapshot.data ?? [];
          if (favorites.isEmpty) {
            return const Center(
              child: Text('Nenhum devocional favoritado ainda.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final fav = favorites[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(fav.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(fav.date),
                  trailing: const Icon(Icons.favorite, color: Colors.redAccent),
                  onTap: () {
                    // Abrir em modo leitura
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => DevotionalReaderPage(
                          devotional: DevotionalCardModel(
                            id: fav.id,
                            title: fav.title,
                            content: fav.content,
                            date: fav.date,
                            completed: true,
                            isFavorited: true,
                            guidance: DevotionalGuidanceModel(
                              title: '',
                              body: '',
                              accentLabel: '',
                              tone: '',
                              currentStreak: 0,
                              nextMilestone: null,
                            ),
                          ),
                          streak: StreakModel(
                            currentStreak: 0,
                            longestStreak: 0,
                            lastActivityDate: null,
                            latestMilestone: null,
                          ),
                          onComplete: null,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
