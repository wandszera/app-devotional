import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import 'admin_notifications_tab_content.dart';
import 'admin_notifications_tab_controller.dart';
import 'home_feedback.dart';
import 'home_state_widgets.dart';

class AdminNotificationsTab extends StatefulWidget {
  const AdminNotificationsTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<AdminNotificationsTab> createState() => _AdminNotificationsTabState();
}

class _AdminNotificationsTabState extends State<AdminNotificationsTab> {
  late final AdminNotificationsTabController controller;

  @override
  void initState() {
    super.initState();
    controller = AdminNotificationsTabController(apiClient: widget.apiClient);
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _dispatch() async {
    try {
      final sent = await controller.dispatch();
      if (!mounted) {
        return;
      }
      HomeFeedback.showSuccess(
        context,
        '${sent.length} notificacoes processadas',
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      HomeFeedback.showError(context, error.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final state = controller.state;
        if (state.status.loading) {
          return const HomeLoadingView();
        }

        if (state.status.errorMessage != null) {
          return HomeErrorView(message: state.status.errorMessage!);
        }

        return AdminNotificationsTabContent(
          dueNotifications: state.dueNotifications,
          deliveries: state.deliveries,
          submitting: state.status.submitting,
          onDispatch: _dispatch,
          onRefresh: controller.load,
        );
      },
    );
  }
}
