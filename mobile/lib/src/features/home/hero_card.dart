import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/cross_ornament.dart';

class HeroCard extends StatelessWidget {
  const HeroCard({
    required this.title,
    required this.body,
    required this.date,
    this.liturgicalTitle = '',
    this.gospelReference = '',
    this.isFavorited = false,
    this.onToggleFavorite,
    super.key,
  });

  final String title;
  final String body;
  final String date;
  final String liturgicalTitle;
  final String gospelReference;
  final bool isFavorited;
  final VoidCallback? onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.55)),
        boxShadow: [
          BoxShadow(
            color: AppColors.blueDeep.withValues(alpha: 0.22),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
        gradient: const LinearGradient(
          colors: [AppColors.blueDeep, AppColors.blue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const CrossMark(size: 18),
                  const SizedBox(width: 10),
                  Text(
                    date.toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.goldLight,
                      fontSize: 12,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              if (onToggleFavorite != null)
                IconButton(
                  onPressed: () {
                    // Prevent inkwell from triggering open
                    onToggleFavorite?.call();
                  },
                  icon: Icon(
                    isFavorited ? Icons.favorite : Icons.favorite_border,
                    color: isFavorited ? AppColors.goldLight : Colors.white70,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontSize: 30,
                ),
          ),
          const SizedBox(height: 14),
          const OrnamentDivider(),
          if (liturgicalTitle.isNotEmpty) ...[
            const SizedBox(height: 14),
            Text(
              liturgicalTitle,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.goldLight,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
            ),
          ],
          if (gospelReference.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'Evangelho: $gospelReference',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text(
            body,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white,
                  height: 1.5,
                ),
          ),
        ],
      ),
    );
  }
}
