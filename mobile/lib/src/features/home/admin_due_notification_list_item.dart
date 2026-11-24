import 'package:flutter/material.dart';

import '../../models/notification_models.dart';
import '../../theme/app_palette.dart';
import 'retention_primitives.dart';

class AdminDueNotificationListItem extends StatelessWidget {
  const AdminDueNotificationListItem({
    required this.item,
    super.key,
  });

  final DueNotificationModel item;

  @override
  Widget build(BuildContext context) {
    // Material próprio: a cor do tile e o splash ficam visíveis mesmo
    // quando há um fundo colorido entre o ListTile e o Material da tela.
    return Material(
      type: MaterialType.transparency,
      child: ListTile(
        tileColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        leading: Icon(
          Icons.schedule_send,
          color: context.palette.primary,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(item.devotionalTitle)),
                const SizedBox(width: 8),
                ToneBadge(tone: item.tone),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.palette.muted,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MetaPill(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Streak ${item.currentStreak}',
                ),
                if (item.nextMilestone != null)
                  MetaPill(
                    icon: Icons.flag_outlined,
                    label: 'Próximo marco ${item.nextMilestone}',
                  ),
              ],
            ),
          ],
        ),
        subtitle: Text(
          '${item.email}\n${item.timezone} • ${item.reminderTime}',
        ),
        isThreeLine: true,
      ),
    );
  }
}
