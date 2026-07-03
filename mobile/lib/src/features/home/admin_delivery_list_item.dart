import 'package:flutter/material.dart';

import '../../models/notification_models.dart';

class AdminDeliveryListItem extends StatelessWidget {
  const AdminDeliveryListItem({
    required this.item,
    super.key,
  });

  final NotificationDeliveryModel item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      leading: Icon(
        item.status == 'sent' ? Icons.check_circle : Icons.error,
        color: item.status == 'sent' ? Colors.green : Colors.red,
      ),
      title: Text(item.title),
      subtitle: Text(
        'Usuario ${item.userId} â€¢ ${item.status}\n${item.scheduledFor}',
      ),
      isThreeLine: true,
    );
  }
}
