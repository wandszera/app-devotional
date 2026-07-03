import 'package:app_devocional_mobile/src/services/push_sdk_bridge.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('reporta web como fluxo sem push nativo configurado', () async {
    const bridge = PlatformPushSdkBridge(isWebOverride: true);

    final state = await bridge.loadState();

    expect(state.isSupported, isFalse);
    expect(state.permissionStatus, PushPermissionStatus.notSupported);
    expect(state.statusMessage, contains('Lembretes'));
  });

  test('reporta android como etapa sem sdk nativo', () async {
    const bridge = PlatformPushSdkBridge(
      platformOverride: TargetPlatform.android,
      isWebOverride: false,
    );

    final state = await bridge.loadState();

    expect(state.isSupported, isFalse);
    expect(state.sdkReady, isFalse);
    expect(state.permissionStatus, PushPermissionStatus.notSupported);
    expect(state.statusMessage, contains('sem SDK'));
  });

  test('reporta windows como plataforma sem push nativo', () async {
    const bridge = PlatformPushSdkBridge(
      platformOverride: TargetPlatform.windows,
      isWebOverride: false,
    );

    final state = await bridge.refreshStatus();

    expect(state.isSupported, isFalse);
    expect(state.permissionStatus, PushPermissionStatus.notSupported);
    expect(state.statusMessage, contains('indisponivel'));
  });
}
