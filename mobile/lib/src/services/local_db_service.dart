import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/devotional_models.dart';
import '../models/gospel_models.dart';

class LocalDbService {
  static final LocalDbService _instance = LocalDbService._internal();
  factory LocalDbService() => _instance;
  LocalDbService._internal();

  Database? _db;
  final Set<String> _memoryFavoritePrayerIds = {};
  final Map<String, GospelPersonalState> _memoryGospelPersonalStates = {};

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
      version: 4,
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
        await _createPersonalReflectionsTable(db);
        await _createPrayerPreferencesTable(db);
        await _createGospelPreferencesTable(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createPersonalReflectionsTable(db);
        }
        if (oldVersion < 3) {
          await _createPrayerPreferencesTable(db);
        }
        if (oldVersion < 4) {
          await _createGospelPreferencesTable(db);
        }
      },
    );
  }

  Future<void> _createPersonalReflectionsTable(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS personal_reflections(
        entry_key TEXT PRIMARY KEY,
        homily TEXT NOT NULL DEFAULT '',
        note TEXT NOT NULL DEFAULT ''
      )
    ''');
  }

  Future<void> _createPrayerPreferencesTable(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS prayer_preferences(
        prayer_id TEXT PRIMARY KEY,
        is_favorite INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _createGospelPreferencesTable(DatabaseExecutor db) {
    return db.execute('''
      CREATE TABLE IF NOT EXISTS gospel_preferences(
        gospel_date TEXT PRIMARY KEY,
        is_favorite INTEGER NOT NULL DEFAULT 0,
        note_text TEXT
      )
    ''');
  }

  String _personalReflectionKey(String ownerKey, String devotionalDate) {
    return '$ownerKey:$devotionalDate';
  }

  Future<PersonalReflection> getPersonalReflection(
    String ownerKey,
    String devotionalDate,
  ) async {
    if (_db == null) return const PersonalReflection();
    final rows = await _db!.query(
      'personal_reflections',
      where: 'entry_key = ?',
      whereArgs: [_personalReflectionKey(ownerKey, devotionalDate)],
    );
    if (rows.isEmpty) return const PersonalReflection();
    final row = rows.first;
    return PersonalReflection(
      homily: row['homily'] as String? ?? '',
      note: row['note'] as String? ?? '',
    );
  }

  Future<void> savePersonalReflection(
    String ownerKey,
    String devotionalDate, {
    required String homily,
    required String note,
  }) async {
    if (_db == null) return;
    await _db!.insert(
      'personal_reflections',
      {
        'entry_key': _personalReflectionKey(ownerKey, devotionalDate),
        'homily': homily,
        'note': note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cacheDevotional(
    String ownerKey,
    DevotionalCardModel devotional,
  ) async {
    if (_db == null) return;
    await _db!.insert(
      'devotionals',
      {
        'date': '$ownerKey:${devotional.date}',
        'json_data': jsonEncode(devotional.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<DevotionalCardModel?> getCachedDevotional(
    String ownerKey,
    String date,
  ) async {
    if (_db == null) return null;
    final List<Map<String, dynamic>> maps = await _db!.query(
      'devotionals',
      where: 'date = ?',
      whereArgs: ['$ownerKey:$date'],
    );

    if (maps.isNotEmpty) {
      final jsonMap =
          jsonDecode(maps.first['json_data'] as String) as Map<String, dynamic>;
      return DevotionalCardModel.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> cacheStreak(String ownerKey, StreakModel streak) async {
    if (_db == null) return;
    await _db!.insert(
      'app_state',
      {
        'key': '$ownerKey:streak',
        'json_data': jsonEncode(streak.toJson()),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<StreakModel?> getCachedStreak(String ownerKey) async {
    if (_db == null) return null;
    final maps = await _db!.query(
      'app_state',
      where: 'key = ?',
      whereArgs: ['$ownerKey:streak'],
    );
    if (maps.isNotEmpty) {
      final jsonMap =
          jsonDecode(maps.first['json_data'] as String) as Map<String, dynamic>;
      return StreakModel.fromJson(jsonMap);
    }
    return null;
  }

  Future<void> cacheProgress(
    String ownerKey,
    List<ProgressEntry> progress,
  ) async {
    if (_db == null) return;
    final jsonList = progress.map((e) => e.toJson()).toList();
    await _db!.insert(
      'app_state',
      {
        'key': '$ownerKey:progress',
        'json_data': jsonEncode(jsonList),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<ProgressEntry>?> getCachedProgress(String ownerKey) async {
    if (_db == null) return null;
    final maps = await _db!.query(
      'app_state',
      where: 'key = ?',
      whereArgs: ['$ownerKey:progress'],
    );
    if (maps.isNotEmpty) {
      final jsonList =
          jsonDecode(maps.first['json_data'] as String) as List<dynamic>;
      return jsonList
          .map((e) => ProgressEntry.fromJson(e as Map<String, dynamic>))
          .toList();
    }
    return null;
  }

  Future<Set<String>> getFavoritePrayerIds() async {
    if (_db == null) return Set<String>.from(_memoryFavoritePrayerIds);
    final rows = await _db!.query(
      'prayer_preferences',
      columns: ['prayer_id'],
      where: 'is_favorite = 1',
    );
    return rows.map((row) => row['prayer_id']! as String).toSet();
  }

  Future<void> setPrayerFavorite(String prayerId, bool isFavorite) async {
    if (_db == null) {
      if (isFavorite) {
        _memoryFavoritePrayerIds.add(prayerId);
      } else {
        _memoryFavoritePrayerIds.remove(prayerId);
      }
      return;
    }
    if (isFavorite) {
      await _db!.insert(
        'prayer_preferences',
        {'prayer_id': prayerId, 'is_favorite': 1},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } else {
      await _db!.delete(
        'prayer_preferences',
        where: 'prayer_id = ?',
        whereArgs: [prayerId],
      );
    }
  }

  Future<Map<String, GospelPersonalState>> getGospelPersonalStates() async {
    if (_db == null) {
      return Map<String, GospelPersonalState>.from(_memoryGospelPersonalStates);
    }
    final rows = await _db!.query('gospel_preferences');
    return {
      for (final row in rows)
        row['gospel_date']! as String: GospelPersonalState(
          isFavorite: (row['is_favorite'] as int? ?? 0) == 1,
          note: row['note_text'] as String?,
        ),
    };
  }

  Future<void> setGospelFavorite(String date, bool isFavorite) async {
    final current = (await getGospelPersonalStates())[date] ??
        const GospelPersonalState(isFavorite: false, note: null);
    await _saveGospelPersonalState(
      date,
      GospelPersonalState(isFavorite: isFavorite, note: current.note),
    );
  }

  Future<void> saveGospelNote(String date, String note) async {
    final current = (await getGospelPersonalStates())[date] ??
        const GospelPersonalState(isFavorite: false, note: null);
    await _saveGospelPersonalState(
      date,
      GospelPersonalState(
        isFavorite: current.isFavorite,
        note: note.trim().isEmpty ? null : note.trim(),
      ),
    );
  }

  Future<void> _saveGospelPersonalState(
    String date,
    GospelPersonalState state,
  ) async {
    if (_db == null) {
      if (!state.isFavorite && !state.hasNote) {
        _memoryGospelPersonalStates.remove(date);
      } else {
        _memoryGospelPersonalStates[date] = state;
      }
      return;
    }
    if (!state.isFavorite && !state.hasNote) {
      await _db!.delete(
        'gospel_preferences',
        where: 'gospel_date = ?',
        whereArgs: [date],
      );
      return;
    }
    await _db!.insert(
      'gospel_preferences',
      {
        'gospel_date': date,
        'is_favorite': state.isFavorite ? 1 : 0,
        'note_text': state.note,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}

class PersonalReflection {
  const PersonalReflection({
    this.homily = '',
    this.note = '',
  });

  final String homily;
  final String note;
}
