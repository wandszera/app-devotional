import 'dart:convert';

import 'package:flutter/services.dart';

class BundledGospelEntry {
  const BundledGospelEntry({
    required this.date,
    required this.liturgicalTitle,
    required this.gospelReference,
    required this.reflection,
    required this.sourceUrl,
  });

  final String date;
  final String liturgicalTitle;
  final String gospelReference;
  final String reflection;
  final String sourceUrl;
}

/// Publisher-managed editorial content shipped with the app.  It contains
/// citations and an original reflection only; it intentionally never bundles
/// the official biblical text or any private user writing.
class BundledGospelCatalogue {
  BundledGospelCatalogue._();

  static final BundledGospelCatalogue instance = BundledGospelCatalogue._();
  Future<Map<String, BundledGospelEntry>>? _entriesFuture;

  Future<Map<String, BundledGospelEntry>> loadAll() async {
    return _entriesFuture ??= _load();
  }

  Future<BundledGospelEntry?> findByDate(String date) async {
    final entries = await loadAll();
    return entries[date];
  }

  Future<Map<String, BundledGospelEntry>> _load() async {
    final raw =
        await rootBundle.loadString('assets/liturgy/gospel_catalogue.json');
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    final source = decoded['source'] as Map<String, dynamic>? ?? const {};
    final sourceUrl = source['url'] as String? ?? '';
    final entries = decoded['entries'] as List<dynamic>? ?? const [];
    return {
      for (final item in entries)
        (item as Map<String, dynamic>)['date'] as String: BundledGospelEntry(
          date: item['date'] as String,
          liturgicalTitle: item['liturgical_title'] as String? ?? '',
          gospelReference: item['gospel_reference'] as String? ?? '',
          reflection: item['reflection'] as String? ?? '',
          sourceUrl: sourceUrl,
        ),
    };
  }
}
