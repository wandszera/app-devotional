import 'package:flutter/material.dart';

class HomeFormSection extends StatelessWidget {
  const HomeFormSection({
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.backgroundColor = Colors.white,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: child,
    );
  }
}

class HomeFormFieldSpacing extends StatelessWidget {
  const HomeFormFieldSpacing({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox(height: 12);
}

class HomeReadOnlyPickerField extends StatelessWidget {
  const HomeReadOnlyPickerField({
    required this.controller,
    required this.labelText,
    required this.onTap,
    this.hintText,
    this.suffixIcon,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final String? hintText;
  final Widget? suffixIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      readOnly: true,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}

class HomeMultilineField extends StatelessWidget {
  const HomeMultilineField({
    required this.controller,
    required this.labelText,
    this.maxLines = 5,
    super.key,
  });

  final TextEditingController controller;
  final String labelText;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(labelText: labelText),
    );
  }
}

class HomeFormErrorText extends StatelessWidget {
  const HomeFormErrorText({
    required this.message,
    super.key,
  });

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: const TextStyle(color: Colors.red),
    );
  }
}
