import 'package:flutter/material.dart';

import '../../services/api_client.dart';
import '../../services/auth_store.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({
    required this.apiClient,
    required this.authStore,
    required this.onAuthenticated,
    super.key,
  });

  final ApiClient apiClient;
  final AuthStore authStore;
  final VoidCallback onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool isRegisterMode = false;
  bool obscurePassword = true;
  String? errorMessage;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final isValid = formKey.currentState?.validate() ?? false;
    if (!isValid) {
      return;
    }

    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final email = emailController.text.trim();
      final password = passwordController.text;
      final auth = isRegisterMode
          ? await widget.apiClient.register(email: email, password: password)
          : await widget.apiClient.login(email: email, password: password);

      await widget.authStore.save(
        tokenValue: auth.accessToken,
        emailValue: auth.email,
        nameValue: auth.name,
        bioValue: auth.bio,
        isAdminValue: auth.isAdmin,
      );
      widget.onAuthenticated();
    } on ApiException catch (error) {
      setState(() {
        errorMessage = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF4E7D3),
              Color(0xFFE7D2B3),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                elevation: 0,
                color: Colors.white.withValues(alpha: 0.92),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5E9D7),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_stories,
                                color: Color(0xFF7A4B2A),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  isRegisterMode ? 'Criar conta' : 'Entrar',
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isRegisterMode
                              ? 'Comece seu ritmo diario com uma conta simples.'
                              : 'Volte para o seu devocional diario.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          autofillHints: const [AutofillHints.email],
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            prefixIcon: Icon(Icons.alternate_email),
                          ),
                          validator: (value) {
                            final email = value?.trim() ?? '';
                            if (email.isEmpty) {
                              return 'Informe seu email';
                            }
                            if (!email.contains('@') || !email.contains('.')) {
                              return 'Informe um email valido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: passwordController,
                          obscureText: obscurePassword,
                          autofillHints: isRegisterMode
                              ? const [AutofillHints.newPassword]
                              : const [AutofillHints.password],
                          decoration: InputDecoration(
                            labelText: 'Senha',
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  obscurePassword = !obscurePassword;
                                });
                              },
                              icon: Icon(
                                obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                          validator: (value) {
                            final password = value ?? '';
                            if (password.isEmpty) {
                              return 'Informe sua senha';
                            }
                            if (password.length < 8) {
                              return 'A senha precisa ter ao menos 8 caracteres';
                            }
                            return null;
                          },
                        ),
                        if (errorMessage != null) ...[
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFECE8),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        FilledButton.icon(
                          onPressed: loading ? null : _submit,
                          icon: Icon(
                            isRegisterMode ? Icons.person_add_alt_1 : Icons.login,
                          ),
                          label: Text(
                            loading
                                ? 'Carregando...'
                                : isRegisterMode
                                    ? 'Criar conta'
                                    : 'Entrar',
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: loading
                              ? null
                              : () {
                                  setState(() {
                                    isRegisterMode = !isRegisterMode;
                                    errorMessage = null;
                                  });
                                },
                          child: Text(
                            isRegisterMode
                                ? 'Ja tenho conta'
                                : 'Ainda nao tenho conta',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
