import 'package:flutter/material.dart';

import '../../theme/app_palette.dart';
import '../../widgets/cross_ornament.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({
    required this.onFinished,
    super.key,
  });

  final VoidCallback onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final pageController = PageController();
  int pageIndex = 0;

  static const items = [
    (
      title: 'Volte um pouco a cada dia',
      body:
          'O objetivo não é correr. É voltar todos os dias para construir um ritmo espiritual constante.',
      icon: Icons.wb_twilight_outlined,
    ),
    (
      title: 'Seu streak mostra consistência',
      body:
          'Cada conclusão fortalece seu hábito. Marcos como 3, 7 e 30 dias ajudam a manter o foco.',
      icon: Icons.local_fire_department_outlined,
    ),
    (
      title: 'Ative o lembrete diário',
      body:
          'Escolha um horário simples e realista. O melhor horário é aquele que você consegue manter.',
      icon: Icons.notifications_active_outlined,
    ),
  ];

  Future<void> _finish() async {
    widget.onFinished();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLastPage = pageIndex == items.length - 1;
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _finish,
                    child: const Text('Pular'),
                  ),
                ),
                Expanded(
                  child: PageView.builder(
                    controller: pageController,
                    onPageChanged: (value) {
                      setState(() {
                        pageIndex = value;
                      });
                    },
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.secondary.withValues(alpha: 0.6),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colorScheme.onPrimaryContainer.withValues(alpha: 0.10),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Icon(
                              item.icon,
                              size: 48,
                              color: colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const OrnamentDivider(),
                          const SizedBox(height: 24),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontSize: 32,
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    items.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: pageIndex == index ? 24 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: pageIndex == index
                            ? colorScheme.secondary
                            : colorScheme.outline,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: isLastPage
                        ? _finish
                        : () {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOut,
                            );
                          },
                    child: Text(isLastPage ? 'Comecar' : 'Continuar'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
