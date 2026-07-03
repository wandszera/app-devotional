import 'package:flutter/material.dart';

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
          'O objetivo nao e correr. E voltar todos os dias para construir um ritmo espiritual constante.',
      icon: Icons.wb_twilight_outlined,
    ),
    (
      title: 'Seu streak mostra consistencia',
      body:
          'Cada conclusao fortalece seu habito. Marcos como 3, 7 e 30 dias ajudam a manter o foco.',
      icon: Icons.local_fire_department_outlined,
    ),
    (
      title: 'Ative o lembrete diario',
      body:
          'Escolha um horario simples e realista. O melhor horario e aquele que voce consegue manter.',
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
    final isLastPage = pageIndex == items.length - 1;
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFF5E8D4),
              Color(0xFFE8D6B6),
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
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Icon(
                              item.icon,
                              size: 46,
                              color: const Color(0xFF7A4B2A),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            item.title,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF4B3320),
                                ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            item.body,
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  height: 1.6,
                                  color: const Color(0xFF5F4B39),
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
                            ? const Color(0xFF7A4B2A)
                            : const Color(0xFFCDB89A),
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
