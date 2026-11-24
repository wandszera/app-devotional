import 'package:flutter/material.dart';

import '../../models/auth_models.dart';
import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/google_auth_service.dart';
import '../../theme/app_palette.dart';
import '../../widgets/cross_ornament.dart';

class LoginPage extends StatefulWidget {
  LoginPage({
    required this.apiClient,
    required this.authStore,
    required this.onAuthenticated,
    GoogleAuthService? googleAuthService,
    super.key,
  }) : googleAuthService = googleAuthService ?? FirebaseGoogleAuthService();

  final ApiClient apiClient;
  final AuthStore authStore;
  final VoidCallback onAuthenticated;
  final GoogleAuthService googleAuthService;

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

      await _saveAuthenticatedUser(auth);
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

  Future<void> _signInWithGoogle() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      final idToken = await widget.googleAuthService.signIn();
      final auth = await widget.apiClient.loginWithGoogle(idToken);
      await _saveAuthenticatedUser(auth);
      widget.onAuthenticated();
    } on ApiException catch (error) {
      setState(() {
        errorMessage = error.message;
      });
    } catch (_) {
      setState(() {
        errorMessage = 'Não foi possível entrar com Google. Tente novamente.';
      });
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _saveAuthenticatedUser(AuthResponse auth) {
    return widget.authStore.save(
      tokenValue: auth.accessToken,
      refreshTokenValue: auth.refreshToken,
      userIdValue: auth.userId,
      emailValue: auth.email,
      nameValue: auth.name,
      bioValue: auth.bio,
      isAdminValue: auth.isAdmin,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              context.palette.bg,
              colorScheme.secondaryContainer,
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
                color: colorScheme.surface,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [colorScheme.onPrimaryContainer, colorScheme.primary],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              const CrossMark(size: 26),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Text(
                                  isRegisterMode ? 'Criar conta' : 'Entrar',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          isRegisterMode
                              ? 'Comece seu ritmo diário com uma conta simples.'
                              : 'Volte para o seu devocional diário.',
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
                              return 'Informe um email válido';
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
                              color: colorScheme.tertiaryContainer,
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
                            isRegisterMode
                                ? Icons.person_add_alt_1
                                : Icons.login,
                          ),
                          label: Text(
                            loading
                                ? 'Carregando...'
                                : isRegisterMode
                                    ? 'Criar conta'
                                    : 'Entrar',
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                'ou',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: loading ? null : _signInWithGoogle,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text('Continuar com Google'),
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
                                ? 'Já tenho conta'
                                : 'Ainda não tenho conta',
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
