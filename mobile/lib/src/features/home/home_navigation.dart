import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/push_sdk_bridge.dart';
import 'admin_devotionals_tab.dart';
import 'admin_notifications_tab.dart';
import 'liturgical_calendar_tab.dart';
import 'progress_tab.dart';
import 'prayers_tab.dart';
import 'settings_tab.dart';
import 'today_tab.dart';

typedef HomeTabBuilder = Widget Function();

class HomeTabDefinition {
  const HomeTabDefinition({
    required this.builder,
    required this.destination,
  });

  final HomeTabBuilder builder;
  final NavigationDestination destination;
}

List<HomeTabDefinition> buildHomeTabDefinitions({
  required ApiClient apiClient,
  required AuthStore authStore,
  required PushSdkBridge pushSdkBridge,
  required VoidCallback onLogout,
}) {
  final tabs = <HomeTabDefinition>[
    HomeTabDefinition(
      builder: () => TodayTab(apiClient: apiClient),
      destination: const NavigationDestination(
        icon: Icon(Icons.menu_book_outlined),
        selectedIcon: Icon(Icons.menu_book),
        label: 'Hoje',
      ),
    ),
    const HomeTabDefinition(
      builder: LiturgicalCalendarTab.new,
      destination: NavigationDestination(
        icon: Icon(Icons.calendar_month_outlined),
        selectedIcon: Icon(Icons.calendar_month),
        label: 'Calendário',
      ),
    ),
    HomeTabDefinition(
      builder: () => ProgressTab(apiClient: apiClient),
      destination: const NavigationDestination(
        icon: Icon(Icons.insights_outlined),
        selectedIcon: Icon(Icons.insights),
        label: 'Progresso',
      ),
    ),
    const HomeTabDefinition(
      builder: PrayersTab.new,
      destination: NavigationDestination(
        icon: Icon(Icons.auto_stories_outlined),
        selectedIcon: Icon(Icons.auto_stories),
        label: 'Orações',
      ),
    ),
    HomeTabDefinition(
      builder: () => SettingsTab(
        apiClient: apiClient,
        authStore: authStore,
        pushSdkBridge: pushSdkBridge,
        onLogout: onLogout,
      ),
      destination: const NavigationDestination(
        icon: Icon(Icons.settings_outlined),
        selectedIcon: Icon(Icons.settings),
        label: 'Ajustes',
      ),
    ),
  ];

  if (!authStore.isAdmin) {
    return tabs;
  }

  return [
    ...tabs,
    HomeTabDefinition(
      builder: () => AdminDevotionalsTab(apiClient: apiClient),
      destination: const NavigationDestination(
        icon: Icon(Icons.edit_calendar_outlined),
        selectedIcon: Icon(Icons.edit_calendar),
        label: 'Admin',
      ),
    ),
    HomeTabDefinition(
      builder: () => AdminNotificationsTab(apiClient: apiClient),
      destination: const NavigationDestination(
        icon: Icon(Icons.notifications_active_outlined),
        selectedIcon: Icon(Icons.notifications_active),
        label: 'Dispatch',
      ),
    ),
  ];
}
