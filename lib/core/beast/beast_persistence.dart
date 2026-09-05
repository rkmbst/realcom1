// lib/core/beast/beast_persistence.dart

import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'beast_user_scope.dart';

/// طبقة persistence مستقلة لذاكرة Beast.
///
/// مسؤوليتها:
/// - تخزين snapshot للحالة.
/// - استعادة snapshot.
/// - عزل البيانات حسب المستخدم.
/// - حفظ version للـschema.
/// - السماح بالترقية لاحقًا بدون كسر الذاكرة.
///
/// لا تحتوي هذه الطبقة على منطق التوصية نفسه.
class BeastPersistence {
  BeastPersistence({
    required Database database,
  }) : _db = database;

  final Database _db;

  static const String _table =
      'beast_user_state';

  static const int schemaVersion = 1;

  bool _tableReady = false;

  // ---------------------------------------------------------------------------
  // INIT
  // ---------------------------------------------------------------------------

  Future<void> ensureReady() async {
    if (_tableReady) {
      return;
    }

    await _db.execute('''
      CREATE TABLE IF NOT EXISTS $_table (
        user_id TEXT PRIMARY KEY,
        schema_version INTEGER NOT NULL,
        brain_json TEXT NOT NULL,
        preferences_json TEXT NOT NULL,
        context_json TEXT,
        updated_at INTEGER NOT NULL
      )
    ''');

    await _db.execute('''
      CREATE INDEX IF NOT EXISTS
      idx_beast_user_state_updated
      ON $_table(updated_at)
    ''');

    _tableReady = true;
  }

  // ---------------------------------------------------------------------------
  // SAVE
  // ---------------------------------------------------------------------------

  Future<void> save({
    required BeastUserScope scope,
    required Map<String, dynamic> brain,
    required Map<String, dynamic> preferences,
    Map<String, dynamic>? context,
  }) async {
    if (!scope.isValid) {
      return;
    }

    await ensureReady();

    final now =
        DateTime.now().millisecondsSinceEpoch;

    await _db.insert(
      _table,
      {
        'user_id': scope.normalizedUserId,
        'schema_version': schemaVersion,
        'brain_json': jsonEncode(brain),
        'preferences_json':
            jsonEncode(preferences),
        'context_json':
            context == null
                ? null
                : jsonEncode(context),
        'updated_at': now,
      },
      conflictAlgorithm:
          ConflictAlgorithm.replace,
    );
  }

  // ---------------------------------------------------------------------------
  // LOAD
  // ---------------------------------------------------------------------------

  Future<Map<String, dynamic>?>
      load(
    BeastUserScope scope,
  ) async {
    if (!scope.isValid) {
      return null;
    }

    await ensureReady();

    final rows = await _db.query(
      _table,
      where: 'user_id = ?',
      whereArgs: [
        scope.normalizedUserId,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final row = rows.first;

    final brain =
        _decodeMap(
      row['brain_json'] as String?,
    );

    final preferences =
        _decodeMap(
      row['preferences_json']
          as String?,
    );

    final context =
        _decodeNullableMap(
      row['context_json'] as String?,
    );

    return <String, dynamic>{
      'user_id':
          row['user_id'],
      'schema_version':
          row['schema_version'],
      'brain': brain,
      'preferences': preferences,
      'context': context,
      'updated_at':
          row['updated_at'],
    };
  }

  // ---------------------------------------------------------------------------
  // EXISTS
  // ---------------------------------------------------------------------------

  Future<bool> exists(
    BeastUserScope scope,
  ) async {
    if (!scope.isValid) {
      return false;
    }

    await ensureReady();

    final rows = await _db.query(
      _table,
      columns: const [
        'user_id',
      ],
      where: 'user_id = ?',
      whereArgs: [
        scope.normalizedUserId,
      ],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  // ---------------------------------------------------------------------------
  // DELETE USER MEMORY
  // ---------------------------------------------------------------------------

  Future<void> delete(
    BeastUserScope scope,
  ) async {
    if (!scope.isValid) {
      return;
    }

    await ensureReady();

    await _db.delete(
      _table,
      where: 'user_id = ?',
      whereArgs: [
        scope.normalizedUserId,
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // DELETE ALL
  // ---------------------------------------------------------------------------

  Future<void> deleteAll() async {
    await ensureReady();
    await _db.delete(_table);
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Map<String, dynamic> _decodeMap(
    String? raw,
  ) {
    if (raw == null ||
        raw.trim().isEmpty) {
      return <String, dynamic>{};
    }

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    } catch (_) {
      // Invalid state is treated as
      // an empty state instead of crashing
      // the application.
    }

    return <String, dynamic>{};
  }

  Map<String, dynamic>? _decodeNullableMap(
    String? raw,
  ) {
    if (raw == null ||
        raw.trim().isEmpty) {
      return null;
    }

    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is Map) {
        return Map<String, dynamic>.from(
          decoded,
        );
      }
    } catch (_) {}

    return null;
  }
}
