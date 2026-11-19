import 'package:flutter/material.dart';

import 'widgets/cross_ornament.dart';

import 'config/app_config.dart';
import 'features/app_shell.dart';
import 'services/api_client.dart';
import 'services/auth_store.dart';
import 'services/firebase_push_sdk_bridge.dart';
import 'services/local_db_service.dart';
import 'services/push_sdk_bridge.dart';
import 'theme/app_theme.dart';

class DevotionalApp extends StatefulWidget {
  const DevotionalApp({super.key});

  @override
  State<DevotionalApp> createState() => _DevotionalAppState();
}

class _DevotionalAppState extends State<DevotionalApp> {
  final authStore = AuthStore();
  late final PushSdkBridge pushSdkBridge = FirebasePushSdkBridge();
  late final ApiClient apiClient = ApiClient(
    authStore: authStore,
    baseUrl: AppConfig.apiBaseUrl,
  );
  bool initialized = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await LocalDbService().init();
    await authStore.load();
    if (!mounted) {
      return;
    }
    setState(() {
      initialized = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Devocional',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: initialized
          ? AppShell(
              apiClient: apiClient,
              authStore: authStore,
              pushSdkBridge: pushSdkBridge,
            )
          : const _SplashScreen(),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CrossMark(size: 44),
            SizedBox(height: 24),
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ],
        ),
      ),
    );
  }
}
