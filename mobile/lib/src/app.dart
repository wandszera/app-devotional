import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import 'config/app_config.dart';
import 'features/app_shell.dart';
import 'services/api_client.dart';
import 'services/auth_store.dart';
import 'services/firebase_push_sdk_bridge.dart';
import 'services/local_db_service.dart';
import 'services/push_sdk_bridge.dart';

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
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A3619),
          primary: const Color(0xFF5A3619),
          secondary: const Color(0xFFB88645),
          surface: const Color(0xFFFCF9F2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF4EBE1),
        textTheme: GoogleFonts.interTextTheme(),
        useMaterial3: true,
      ),
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
        child: CircularProgressIndicator(),
      ),
    );
  }
}
