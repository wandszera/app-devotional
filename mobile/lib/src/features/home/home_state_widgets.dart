import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class HomeErrorView extends StatelessWidget {
  const HomeErrorView({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF3E6B52),
              ),
        ),
      ),
    );
  }
}

class HomeEmptyView extends StatelessWidget {
  const HomeEmptyView({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(0xFF3E6B52),
              ),
        ),
      ),
    );
  }
}

class HomeEmptyCard extends StatelessWidget {
  const HomeEmptyCard({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.sand),
      ),
      child: Text(message),
    );
  }
}
