import 'package:flutter/material.dart';

class TodayActionButtons extends StatelessWidget {
  const TodayActionButtons({
    required this.completed,
    required this.submitting,
    required this.onComplete,
    required this.onOpenReader,
    required this.onShare,
    super.key,
  });

  final bool completed;
  final bool submitting;
  final VoidCallback onComplete;
  final VoidCallback onOpenReader;
  final VoidCallback onShare;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: completed || submitting ? null : onComplete,
          child: Text(
            completed
                ? 'Concluido hoje'
                : submitting
                    ? 'Enviando...'
                    : 'Concluir hoje',
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onShare,
                icon: const Icon(Icons.share, size: 18),
                label: const Text('Compartilhar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onOpenReader,
                child: const Text('Abrir leitura'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
