import 'package:flutter/material.dart';

class HomeSectionTitle extends StatelessWidget {
  const HomeSectionTitle({
    required this.title,
    super.key,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium,
    );
  }
}

class HomeGap12 extends StatelessWidget {
  const HomeGap12({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 12);
}

class HomeGap16 extends StatelessWidget {
  const HomeGap16({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 16);
}

class HomeGap20 extends StatelessWidget {
  const HomeGap20({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 20);
}

class HomeGap24 extends StatelessWidget {
  const HomeGap24({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 24);
}
