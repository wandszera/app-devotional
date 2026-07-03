import 'package:flutter/material.dart';
import 'package:animations/animations.dart';

import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/push_sdk_bridge.dart';
import 'home_navigation.dart';
import 'home_navigation_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({
    required this.apiClient,
    required this.authStore,
    required this.pushSdkBridge,
    required this.onLogout,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;
  final PushSdkBridge pushSdkBridge;
  final VoidCallback onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late final HomeNavigationController navigationController;

  @override
  void initState() {
    super.initState();
    navigationController = HomeNavigationController();
  }

  @override
  void dispose() {
    navigationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tabs = buildHomeTabDefinitions(
      apiClient: widget.apiClient,
      authStore: widget.authStore,
      pushSdkBridge: widget.pushSdkBridge,
      onLogout: widget.onLogout,
    );

    return ListenableBuilder(
      listenable: navigationController,
      builder: (context, _) {
        final safeIndex = navigationController.safeIndexForLength(tabs.length);

        return Scaffold(
          appBar: AppBar(
            title: const Text('App Devocional'),
            backgroundColor: Colors.transparent,
          ),
          body: PageTransitionSwitcher(
            transitionBuilder: (child, animation, secondaryAnimation) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(safeIndex),
              child: tabs[safeIndex].builder(),
            ),
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: safeIndex,
            onDestinationSelected: navigationController.selectIndex,
            destinations: tabs.map((tab) => tab.destination).toList(),
          ),
        );
      },
    );
  }
}
