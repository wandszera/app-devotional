import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';
import 'hero_card.dart';

class TodayDevotionalPreview extends StatelessWidget {
  const TodayDevotionalPreview({
    required this.devotional,
    required this.onOpen,
    required this.onToggleFavorite,
    super.key,
  });

  final DevotionalCardModel devotional;
  final VoidCallback onOpen;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onOpen,
      child: HeroCard(
        title: devotional.title,
        body: devotional.content,
        date: devotional.date,
        isFavorited: devotional.isFavorited,
        onToggleFavorite: onToggleFavorite,
      ),
    );
  }
}
