import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';

class AdminDevotionalListItem extends StatelessWidget {
  const AdminDevotionalListItem({
    required this.devotional,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final AdminDevotional devotional;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      title: Text(devotional.title),
      subtitle: Text('${devotional.date}\n${devotional.content}'),
      isThreeLine: true,
      trailing: PopupMenuButton<String>(
        onSelected: (value) {
          if (value == 'edit') {
            onEdit();
          }
          if (value == 'delete') {
            onDelete();
          }
        },
        itemBuilder: (context) => const [
          PopupMenuItem(
            value: 'edit',
            child: Text('Editar'),
          ),
          PopupMenuItem(
            value: 'delete',
            child: Text('Excluir'),
          ),
        ],
      ),
    );
  }
}
