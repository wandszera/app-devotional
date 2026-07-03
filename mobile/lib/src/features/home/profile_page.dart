import 'package:flutter/material.dart';
import '../../services/api_client.dart';
import '../../services/auth_store.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    required this.apiClient,
    required this.authStore,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _submitting = false;

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
              onPressed: _submitting ? null : _save,
              child: _submitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Salvar Alterações'),
            ),
          ),
        ],
      ),
    );
  }
}
