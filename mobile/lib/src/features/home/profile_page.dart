import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/google_auth_service.dart';
import '../../theme/app_palette.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.apiClient,
    required this.authStore,
    this.onAccountDeleted,
    this.googleAuthService,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;

  /// Chamado depois que a conta foi excluída (volta ao login).
  final VoidCallback? onAccountDeleted;

  /// Usado para reautenticar contas Google antes de excluir.
  final GoogleAuthService? googleAuthService;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _submitting = false;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.authStore.name ?? '';
    _bioController.text = widget.authStore.bio ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    try {
      final name = _nameController.text.trim();
      final bio = _bioController.text.trim();
      
      await widget.apiClient.updateProfile(name: name, bio: bio);
      await widget.authStore.updateProfile(newName: name, newBio: bio);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil atualizado com sucesso!')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar perfil: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  Future<void> _confirmDeleteAccount() async {
    final result = await showDialog<_DeleteConfirmation>(
      context: context,
      builder: (_) => const _DeleteAccountDialog(),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() => _deleting = true);
    try {
      String? idToken;
      if (result.useGoogle) {
        idToken = await (widget.googleAuthService ??
                FirebaseGoogleAuthService())
            .signIn();
      }
      await widget.apiClient.deleteAccount(
        password: result.password,
        idToken: idToken,
      );
      if (!mounted) {
        return;
      }
      final callback = widget.onAccountDeleted;
      Navigator.of(context).popUntil((route) => route.isFirst);
      callback?.call();
    } on ApiException catch (e) {
      _showDeleteError(e.message);
    } catch (_) {
      _showDeleteError('Não foi possível excluir a conta agora. Tente de novo.');
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  void _showDeleteError(String message) {
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Nome ou Apelido',
              border: OutlineInputBorder(),
            ),
            enabled: !_submitting,
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _bioController,
            decoration: const InputDecoration(
              labelText: 'Biografia (Opcional)',
              border: OutlineInputBorder(),
              hintText: 'Fale um pouco sobre sua caminhada...',
            ),
            enabled: !_submitting,
            maxLines: 3,
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              onPressed: (_submitting || _deleting) ? null : _save,
              child: _submitting
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: context.palette.onPrimary,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Salvar Alterações'),
            ),
          ),
          const SizedBox(height: 40),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Zona de perigo',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Excluir a conta apaga seu progresso, favoritos, sequência e '
            'configurações. Essa ação não pode ser desfeita.',
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            key: const Key('delete-account-button'),
            onPressed: (_submitting || _deleting) ? null : _confirmDeleteAccount,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red.shade700,
              side: BorderSide(color: Colors.red.shade700),
              minimumSize: const Size.fromHeight(48),
            ),
            icon: _deleting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.delete_forever),
            label: const Text('Excluir conta'),
          ),
        ],
      ),
    );
  }
}

class _DeleteConfirmation {
  const _DeleteConfirmation({this.password, this.useGoogle = false});

  final String? password;
  final bool useGoogle;
}

class _DeleteAccountDialog extends StatefulWidget {
  const _DeleteAccountDialog();

  @override
  State<_DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<_DeleteAccountDialog> {
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Excluir conta?'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Serão apagados para sempre: seu progresso e leituras '
              'concluídas, favoritos, sequência (streak), lembretes e o '
              'cadastro da conta. Não há como recuperar.',
            ),
            const SizedBox(height: 16),
            TextField(
              key: const Key('delete-account-password'),
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Senha (conta com e-mail)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              key: const Key('delete-account-google'),
              onPressed: () => Navigator.of(context)
                  .pop(const _DeleteConfirmation(useGoogle: true)),
              icon: const Icon(Icons.login),
              label: const Text('Confirmar com Google'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          key: const Key('delete-account-confirm'),
          style: FilledButton.styleFrom(backgroundColor: Colors.red.shade700),
          onPressed: _passwordController.text.isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    _DeleteConfirmation(password: _passwordController.text),
                  ),
          child: const Text('Excluir definitivamente'),
        ),
      ],
    );
  }
}
