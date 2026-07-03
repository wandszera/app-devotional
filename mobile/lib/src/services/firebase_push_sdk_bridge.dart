import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'push_sdk_bridge.dart';

class FirebasePushSdkBridge implements PushSdkBridge {
  FirebasePushSdkBridge() {
    _initFirebaseMessaging();
  }

  void _initFirebaseMessaging() {
    if (kIsWeb) return;
    
    // Opcional: configurar handler em background se necessario futuramente
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  @override
  Future<PushSdkState> loadState() async {
    return _buildState();
  }

  @override
  Future<PushSdkState> refreshStatus() async {
    return _buildState();
  }

  @override
  Future<PushSdkState> requestPermission() async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      return _buildState();
    }

    final settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    return _buildState(permissionSettings: settings);
  }

  Future<PushSdkState> _buildState({NotificationSettings? permissionSettings}) async {
    if (kIsWeb || (defaultTargetPlatform != TargetPlatform.android && defaultTargetPlatform != TargetPlatform.iOS)) {
      return const PushSdkState(
        sdkReady: false,
        isSupported: false,
        permissionStatus: PushPermissionStatus.notSupported,
        pushToken: null,
        statusMessage: 'Plataforma não suportada nativamente',
        helpMessage: 'Push nativo suportado apenas no Android e iOS. No momento, o lembrete salvará apenas o horário.',
      );
    }

    final settings = permissionSettings ?? await FirebaseMessaging.instance.getNotificationSettings();
    final permissionStatus = _mapPermissionStatus(settings.authorizationStatus);

    String? token;
    if (permissionStatus == PushPermissionStatus.granted) {
      try {
        token = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint('Erro ao capturar push token: \$e');
      }
    }

    return PushSdkState(
      sdkReady: true,
      isSupported: true,
      permissionStatus: permissionStatus,
      pushToken: token,
      statusMessage: _buildStatusMessage(permissionStatus, token),
      helpMessage: _buildHelpMessage(permissionStatus),
    );
  }

  PushPermissionStatus _mapPermissionStatus(AuthorizationStatus status) {
    switch (status) {
      case AuthorizationStatus.authorized:
      case AuthorizationStatus.provisional:
        return PushPermissionStatus.granted;
      case AuthorizationStatus.denied:
        return PushPermissionStatus.denied;
      case AuthorizationStatus.notDetermined:
        return PushPermissionStatus.notDetermined;
    }
  }

  String _buildStatusMessage(PushPermissionStatus status, String? token) {
    if (status == PushPermissionStatus.granted) {
      return token != null ? 'Pronto para receber notificações!' : 'Permissão concedida, gerando token...';
    }
    if (status == PushPermissionStatus.denied) {
      return 'Notificações bloqueadas pelo usuário.';
    }
    return 'Aguardando permissão do usuário.';
  }

  String _buildHelpMessage(PushPermissionStatus status) {
    if (status == PushPermissionStatus.denied) {
      return 'Você precisará ir nas Configurações do seu celular para liberar o acesso caso mude de ideia.';
    }
    return 'Toque no botão para liberar o acesso a notificações no seu dispositivo.';
  }
}
