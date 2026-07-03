import 'package:flutter/material.dart';

class SettingsSupport {
  static TimeOfDay initialReminderTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length != 2) {
      return const TimeOfDay(hour: 8, minute: 0);
    }

    return TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );
  }

  static String formatReminderTime(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  static void syncTextController(
    TextEditingController controller,
    String nextValue,
  ) {
    if (controller.text == nextValue) {
      return;
    }
    controller.text = nextValue;
  }
}
