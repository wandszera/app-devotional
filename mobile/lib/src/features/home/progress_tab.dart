import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import 'home_state_widgets.dart';
import 'progress_tab_content.dart';
import 'progress_support.dart';
import 'progress_tab_controller.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  late final ProgressTabController controller;

  @override
  void initState() {
    super.initState();
    controller = ProgressTabController(apiClient: widget.apiClient);
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
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

        if (state.progress.isEmpty) {
          return const HomeEmptyView(
            message: 'Seu historico aparecera aqui quando voce concluir dias.',
          );
        }
        final presentation = ProgressSupport.buildPresentation(
          progress: state.progress,
          streak: state.streak,
        );

        return ProgressTabContent(
          insights: presentation.insights,
          referenceDate: presentation.referenceDate,
          leadingOffset: presentation.leadingOffset,
          daysInMonth: presentation.daysInMonth,
          completedMap: presentation.completedMap,
          monthLabel: presentation.monthLabel,
          isSameDay: ProgressSupport.isSameDay,
          progress: state.progress,
          streak: state.streak!,
          onRefresh: controller.load,
        );
      },
    );
  }
}
