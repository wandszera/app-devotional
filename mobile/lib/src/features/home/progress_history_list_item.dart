import 'package:flutter/material.dart';

class ProgressHistoryListItem extends StatelessWidget {
  const ProgressHistoryListItem({
    required this.date,
    required this.completed,
    super.key,
  });

  final String date;
  final bool completed;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      leading: Icon(
        completed ? Icons.check_circle : Icons.circle_outlined,
        color: const Color(0xFF7A4B2A),
      ),
      title: Text(date),
      subtitle: const Text('Devocional marcado como concluido'),
    );
  }
}
