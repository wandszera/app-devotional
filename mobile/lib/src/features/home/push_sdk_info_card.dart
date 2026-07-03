import 'package:flutter/material.dart';

import '../../services/push_sdk_bridge.dart';
import 'home_form_widgets.dart';

class PushSdkInfoCard extends StatelessWidget {
  const PushSdkInfoCard({
    required this.state,
    required this.savedPushToken,
    required this.onRefresh,
    required this.onRequestPermission,
    super.key,
  });

  final PushSdkState? state;
  final String savedPushToken;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onRequestPermission;

  @override
  Widget build(BuildContext context) {
    final currentState = state;
    final tokenStatus = currentState == null
        ? 'Carregando status dos lembretes...'
        : currentState.hasPushToken
            ? 'Token do dispositivo pronto para sincronizar.'
            : savedPushToken.isNotEmpty
                ? 'Existe um token salvo anteriormente no backend.'
                : 'Nenhum token nativo foi configurado nesta etapa.';

    return HomeFormSection(
      backgroundColor: const Color(0xFFF3ECE2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            currentState?.statusMessage ?? 'Aguardando leitura do status dos lembretes',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF7A4B2A),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            currentState?.helpMessage ??
                'Esta area acompanha como o app vai tratar lembretes e futuras integracoes nativas.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFF5F4B39),
                ),
          ),
          const SizedBox(height: 10),
          Text(
            tokenStatus,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: const Color(0xFF5F4B39),
                ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: onRefresh,
                icon: const Icon(Icons.sync),
                label: const Text('Atualizar status'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
