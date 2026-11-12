import 'dart:async';

import 'api_client.dart';
import 'push_sdk_bridge.dart';

/// Mantém o token FCM do aparelho em sincronia com o backend.
///
/// Sem isso o token só chegava ao servidor quando o usuário salvava as
/// configurações; se o FCM rotacionasse o token (ou o backend o limpasse por
/// estar inválido), os lembretes silenciavam.
class PushTokenSync {
  PushTokenSync({required this.apiClient, required this.bridge});

  final ApiClient apiClient;
  final PushSdkBridge bridge;

  StreamSubscription<String>? _subscription;
  bool _running = false;
  String? _pendingToken;
  bool _rerun = false;

  /// Sincroniza agora e passa a ouvir renovações de token do FCM.
  void start() {
    final source = bridge;
    if (_subscription == null && source is PushTokenRefreshSource) {
      _subscription = source.onTokenRefresh.listen(
        (token) => unawaited(sync(knownToken: token)),
        onError: (Object _) {},
      );
    }
    unawaited(sync());
  }

  void stop() {
    _subscription?.cancel();
    _subscription = null;
  }

  /// Retorna true se o backend foi atualizado. Nunca lança: é um trabalho de
  /// fundo e a próxima abertura do app tenta de novo.
  Future<bool> sync({String? knownToken}) async {
    if (_running) {
      _rerun = true;
      _pendingToken = knownToken ?? _pendingToken;
      return false;
    }
    _running = true;
    var updated = false;
    try {
      var token = knownToken;
      do {
        _rerun = false;
        token ??= _pendingToken;
        _pendingToken = null;
        updated = await _syncOnce(token) || updated;
        token = null;
      } while (_rerun);
    } finally {
      _running = false;
    }
    return updated;
  }

  Future<bool> _syncOnce(String? knownToken) async {
    try {
      var token = knownToken;
      if (token == null || token.isEmpty) {
        final state = await bridge.loadState();
        if (!state.hasPushToken) {
          return false;
        }
        token = state.pushToken;
      }
      if (token == null || token.isEmpty) {
        return false;
      }
      final current = await apiClient.getNotificationSettings();
      if (current.pushToken == token) {
        return false;
      }
      await apiClient.updateNotificationSettings(
        current.copyWith(pushToken: token),
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
