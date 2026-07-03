import 'package:flutter/material.dart';

import 'home_form_widgets.dart';

class SettingsAccountCard extends StatelessWidget {
  const SettingsAccountCard({
    required this.email,
    required this.name,
    required this.bio,
    required this.onLogout,
    required this.onEditProfile,
    super.key,
  });

  final String? email;
  final String? name;
  final String? bio;
  final VoidCallback onLogout;
  final VoidCallback onEditProfile;

  @override
  Widget build(BuildContext context) {
    final displayName = (name != null && name!.trim().isNotEmpty) ? name! : 'Usuário';
    final displayBio = (bio != null && bio!.trim().isNotEmpty) ? bio! : (email ?? 'Conta');
    final initial = displayName.substring(0, 1).toUpperCase();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFEBE0D6)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF6E4B2E),
                  child: Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF4D341F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        displayBio,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onLogout,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                  ),
                  child: const Text('Sair'),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: onEditProfile,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF6E4B2E),
                  ),
                  child: const Text('Editar Perfil'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsApiBaseCard extends StatelessWidget {
  const SettingsApiBaseCard({
    required this.baseUrl,
    super.key,
  });

  final String baseUrl;

  @override
  Widget build(BuildContext context) {
    return HomeFormSection(
      child: Text(
        'Base da API: $baseUrl',
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}
