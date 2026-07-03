import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/devotional_models.dart';
import '../models/retention_models.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _db;

  Future<void> init() async {
    if (_db != null) return;

    if (kIsWeb) {
      // Offline DB não suportado via sqflite na web
      return;
    }

    if (Platform.isWindows || Platform.isLinux) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }

    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_devocional_offline.db');

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE devotionals(
            date TEXT PRIMARY KEY,
            json_data TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE app_state(
            key TEXT PRIMARY KEY,
            json_data TEXT
          )
        ''');
      },
    );
  }

  Future<void> cacheDevotional(DevotionalCardModel devotional) async {
    if (_db == null) return;
    await _db!.insert(
      'devotionals',
      {
        'date': devotional.date,
        'json_data': jsonEncode(devotional.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DevotionalCardModel?> getCachedDevotional(String date) async {
    if (_db == null) return null;
    final List<Map<String, dynamic>> maps = await _db!.query(
      'devotionals',
      where: 'date = ?',
      whereArgs: [date],
    );

    if (maps.isNotEmpty) {
      final jsonMap = jsonDecode(maps.first['json_data'] as String) as Map<String, dynamic>;
      return DevotionalCardModel.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> cacheStreak(StreakModel streak) async {
    if (_db == null) return;
    await _db!.insert(
      'app_state',
      {
        'key': 'streak',
        'json_data': jsonEncode(streak.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StreakModel?> getCachedStreak() async {
    if (_db == null) return null;
    final maps = await _db!.query(
      'app_state',
      where: 'key = ?',
      whereArgs: ['streak'],
    );
    if (maps.isNotEmpty) {
      final jsonMap = jsonDecode(maps.first['json_data'] as String) as Map<String, dynamic>;
      return StreakModel.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> cacheProgress(List<ProgressEntry> progress) async {
    if (_db == null) return;
    final jsonList = progress.map((e) => e.toJson()).toList();
    await _db!.insert(
      'app_state',
      {
        'key': 'progress',
        'json_data': jsonEncode(jsonList),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProgressEntry>?> getCachedProgress() async {
    if (_db == null) return null;
    final maps = await _db!.query(
      'app_state',
      where: 'key = ?',
      whereArgs: ['progress'],
    );
    if (maps.isNotEmpty) {
      final jsonList = jsonDecode(maps.first['json_data'] as String) as List<dynamic>;
      return jsonList.map((e) => ProgressEntry.fromJson(e as Map<String, dynamic>)).toList();
    }
    return null;
  }
}
