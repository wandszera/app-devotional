import 'package:flutter/material.dart';

import '../../models/devotional_models.dart';
import '../../services/api_client.dart';
import 'admin_list_widgets.dart';
import 'admin_devotionals_tab_controller.dart';
import 'devotional_editor_sheet.dart';
import 'home_feedback.dart';
import 'home_state_widgets.dart';

class AdminDevotionalsTab extends StatefulWidget {
  const AdminDevotionalsTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<AdminDevotionalsTab> createState() => _AdminDevotionalsTabState();
}

class _AdminDevotionalsTabState extends State<AdminDevotionalsTab> {
  late final AdminDevotionalsTabController controller;

  @override
  void initState() {
    super.initState();
    controller = AdminDevotionalsTabController(apiClient: widget.apiClient);
    controller.load();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _openEditor({AdminDevotional? devotional}) async {
    final changed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DevotionalEditorSheet(
          apiClient: widget.apiClient,
          devotional: devotional,
        );
      },
    );

    if (changed == true) {
      await controller.load();
    }
  }

  Future<void> _delete(AdminDevotional devotional) async {
    try {
      await controller.delete(devotional.id);
      if (!mounted) {
        return;
      }
      HomeFeedback.showSuccess(context, 'Devocional removido');
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

        return Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _openEditor,
            icon: const Icon(Icons.add),
            label: const Text('Novo'),
          ),
          body: state.devotionals.isEmpty
              ? const HomeEmptyView(message: 'Nenhum devocional cadastrado ainda.')
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: state.devotionals.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = state.devotionals[index];
                    return AdminDevotionalListItem(
                      devotional: item,
                      onEdit: () => _openEditor(devotional: item),
                      onDelete: () => _delete(item),
                    );
                  },
                ),
        );
      },
    );
  }
}
