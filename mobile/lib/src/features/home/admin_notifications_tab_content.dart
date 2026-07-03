import 'package:flutter/material.dart';

import '../../models/notification_models.dart';
import 'admin_list_widgets.dart';
import 'home_content_widgets.dart';
import 'home_layout_widgets.dart';
import 'home_state_widgets.dart';

class AdminNotificationsTabContent extends StatelessWidget {
  const AdminNotificationsTabContent({
    required this.dueNotifications,
    required this.deliveries,
    required this.submitting,
    required this.onDispatch,
    required this.onRefresh,
    super.key,
  });

  final List<DueNotificationModel> dueNotifications;
  final List<NotificationDeliveryModel> deliveries;
  final bool submitting;
  final VoidCallback onDispatch;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              Expanded(
                child: MetricCard(
                  label: 'Devidas agora',
                  value: '${dueNotifications.length}',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: MetricCard(
                  label: 'Historico',
                  value: '${deliveries.length}',
                ),
              ),
            ],
          ),
          const HomeGap16(),
          FilledButton.icon(
            onPressed: submitting ? null : onDispatch,
            icon: const Icon(Icons.send),
            label: Text(
              submitting ? 'Disparando...' : 'Disparar agora',
            ),
          ),
          const HomeGap20(),
          const HomeSectionTitle(title: 'Fila pronta para envio'),
          const HomeGap12(),
          if (dueNotifications.isEmpty)
            const HomeEmptyCard(
              message: 'Nenhuma notificacao devida no momento.',
            )
          else
            ...dueNotifications.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AdminDueNotificationListItem(item: item),
              ),
            ),
          const HomeGap24(),
          const HomeSectionTitle(title: 'Entregas recentes'),
          const HomeGap12(),
          if (deliveries.isEmpty)
            const HomeEmptyCard(
              message: 'Nenhum envio registrado ainda.',
            )
          else
            ...deliveries.take(10).map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AdminDeliveryListItem(item: item),
              ),
            ),
        ],
      ),
    );
  }
}
