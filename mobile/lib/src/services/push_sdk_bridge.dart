import 'package:flutter/foundation.dart';

enum PushPermissionStatus {
  notSupported,
  notDetermined,
  denied,
  granted,
}

class PushSdkState {
  const PushSdkState({
    required this.sdkReady,
    required this.isSupported,
    required this.permissionStatus,
    required this.pushToken,
    required this.statusMessage,
    required this.helpMessage,
  });

  final bool sdkReady;
  final bool isSupported;
  final PushPermissionStatus permissionStatus;
  final String? pushToken;
  final String statusMessage;
  final String helpMessage;

  bool get hasPushToken => pushToken != null && pushToken!.isNotEmpty;
  bool get canRefresh => true;
}

abstract class PushSdkBridge {
  Future<PushSdkState> loadState();
  Future<PushSdkState> refreshStatus();
  Future<PushSdkState> requestPermission();
}

class PlatformPushSdkBridge implements PushSdkBridge {
  const PlatformPushSdkBridge({
    this.platformOverride,
    this.isWebOverride,
  });

  final TargetPlatform? platformOverride;
  final bool? isWebOverride;

  @override
  Future<PushSdkState> loadState() async {
    return _stateForCurrentPlatform();
  }

  @override
  Future<PushSdkState> refreshStatus() async {
    return _stateForCurrentPlatform();
  }

  @override
  Future<PushSdkState> requestPermission() async {
    return _stateForCurrentPlatform();
  }

  PushSdkState _stateForCurrentPlatform() {
    final isWeb = isWebOverride ?? kIsWeb;
    final platform = platformOverride ?? defaultTargetPlatform;

    if (isWeb) {
      return const PushSdkState(
        sdkReady: false,
        isSupported: false,
        permissionStatus: PushPermissionStatus.notSupported,
        pushToken: null,
        statusMessage: 'Lembretes funcionando sem push nativo',
        helpMessage:
            'Nesta etapa o app salva apenas o horario do lembrete no backend. O navegador continua sem push nativo configurado.',
      );
    }

    if (platform == TargetPlatform.android || platform == TargetPlatform.iOS) {
      return const PushSdkState(
        sdkReady: false,
        isSupported: false,
        permissionStatus: PushPermissionStatus.notSupported,
        pushToken: null,
        statusMessage: 'Lembrete diario salvo sem SDK nativo',
        helpMessage:
            'Android e iOS seguem usando apenas a configuracao de horario no backend. A captura de permissao e token do dispositivo ficou para uma etapa futura.',
      );
    }

    return const PushSdkState(
      sdkReady: false,
      isSupported: false,
      permissionStatus: PushPermissionStatus.notSupported,
      pushToken: null,
      statusMessage: 'Lembretes sem push nativo nesta plataforma',
      helpMessage:
          'O app continua permitindo salvar horario e timezone do lembrete, mesmo sem integracao nativa de notificacao.',
    );
  }
}
