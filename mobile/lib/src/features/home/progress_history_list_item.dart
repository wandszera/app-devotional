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
          completed ? Icons.check_circle : Icons.circle_outlined,
          color: const Color(0xFF3E6B52),
        ),
        title: Text(date),
        subtitle: const Text('Devocional marcado como concluído'),
      ),
    );
  }
}
