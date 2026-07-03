import 'package:flutter/material.dart';
import '../../models/devotional_models.dart';
import 'home_layout_widgets.dart';

class ProgressBadgesWidget extends StatelessWidget {
  const ProgressBadgesWidget({
    required this.streak,
    super.key,
  });

  final StreakModel streak;

  static const List<int> _milestones = [3, 7, 14, 30, 60, 100];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const HomeSectionTitle(title: 'Meus Emblemas'),
        const HomeGap12(),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            itemCount: _milestones.length,
            itemBuilder: (context, index) {
              final milestone = _milestones[index];
              final isUnlocked = streak.longestStreak >= milestone;
              
              return _BadgeItem(
                milestone: milestone,
                isUnlocked: isUnlocked,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _BadgeItem extends StatelessWidget {
  const _BadgeItem({
    required this.milestone,
    required this.isUnlocked,
  });

  final int milestone;
  final bool isUnlocked;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 60,
          width: 60,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [
                      colorScheme.secondary,
                      colorScheme.secondary.withOpacity(0.7),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isUnlocked ? null : Colors.grey.shade200,
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: colorScheme.secondary.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Center(
            child: Icon(
              isUnlocked ? Icons.emoji_events_rounded : Icons.lock_rounded,
              color: isUnlocked ? Colors.white : Colors.grey.shade400,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$milestone dias',
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: isUnlocked ? FontWeight.bold : FontWeight.normal,
                color: isUnlocked ? colorScheme.primary : Colors.grey.shade500,
              ),
        ),
      ],
    );
  }
}
