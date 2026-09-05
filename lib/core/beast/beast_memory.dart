// lib/core/beast/beast_memory.dart

import 'dart:convert';

import 'beast.dart';

/// مدير الذاكرة الدائمة لـ🐺 Beast.
///
/// لا يملك منطق التوصية.
/// وظيفته الوحيدة:
/// - أخذ snapshot من عقل المستخدم.
/// - استعادة snapshot.
/// - تجهيز payload ثابت وقابل للمهاجرة.
/// - عدم الاحتفاظ ببيانات حساسة غير مطلوبة.
///
/// يعتمد على الـBrain والـPreferences والـThompson الموجودين
/// أصلًا داخل BeastUltimate.
class BeastMemoryManager {
  BeastMemoryManager({
    required BeastUltimate beast,
  }) : _beast = beast;

  final BeastUltimate _beast;

  BeastBrain get brain => _beast.brain;

  BeastUserPreferences get preferences =>
      _beast.preferences;

  BeastThompsonBandit get thompson =>
      _beast.thompson;

  /// إصدار مخطط الذاكرة.
  ///
  /// عند تغيير البنية مستقبلًا نزيد الرقم ونضيف migration.
  static const int schemaVersion = 1;

  // ---------------------------------------------------------------------------
  // SNAPSHOT
  // ---------------------------------------------------------------------------

  Map<String, dynamic> snapshot() {
    return <String, dynamic>{
      'schema_version': schemaVersion,

      'brain': <String, dynamic>{
        'interests': _doubleMap(
          brain.interests,
        ),
        'dislikes': _doubleMap(
          brain.dislikes,
        ),
        'creator_affinity': _doubleMap(
          brain.creatorAffinity,
        ),
        'category_affinity': _doubleMap(
          brain.categoryAffinity,
        ),
        'item_affinity': _doubleMap(
          brain.itemAffinity,
        ),

        'impressions': _intMap(
          brain.impressions,
        ),
        'opens': _intMap(
          brain.opens,
        ),
        'skips': _intMap(
          brain.skips,
        ),
        'hides': _intMap(
          brain.hides,
        ),
        'last_seen_at': _intMap(
          brain.lastSeenAt,
        ),

        'transitions':
            _transitionMap(
          brain.transitions,
        ),

        'ftrl_z': _doubleMap(
          brain.ftrlZ,
        ),
        'ftrl_n': _doubleMap(
          brain.ftrlN,
        ),

        'session_interests': _doubleMap(
          brain.sessionInterests,
        ),
        'session_dislikes': _doubleMap(
          brain.sessionDislikes,
        ),
      },

      'preferences':
          preferences.toJson(),

      'thompson':
          thompson.exportState(),

      'saved_at':
          DateTime.now()
              .toUtc()
              .toIso8601String(),
    };
  }

  /// نسخة JSON جاهزة للتخزين في SQLite أو إرسالها
  /// كـbrain summary للـBig Beast.
  String encode() {
    return jsonEncode(
      snapshot(),
    );
  }

  // ---------------------------------------------------------------------------
  // RESTORE
  // ---------------------------------------------------------------------------

  void restore(
    Map<String, dynamic> data,
  ) {
    final brainData =
        _mapOf(data['brain']);

    if (brainData.isNotEmpty) {
      _restoreBrain(
        brainData,
      );
    }

    final preferencesData =
        _mapOf(data['preferences']);

    if (preferencesData.isNotEmpty) {
      _restorePreferences(
        preferencesData,
      );
    }

    final thompsonData =
        _mapOf(data['thompson']);

    if (thompsonData.isNotEmpty) {
      thompson.importState(
        thompsonData,
      );
    }
  }

  /// استعادة مباشرة من JSON.
  bool restoreEncoded(
    String raw,
  ) {
    try {
      final decoded =
          jsonDecode(raw);

      if (decoded is! Map) {
        return false;
      }

      restore(
        Map<String, dynamic>.from(
          decoded,
        ),
      );

      return true;
    } catch (_) {
      return false;
    }
  }

  // ---------------------------------------------------------------------------
  // CLEAR
  // ---------------------------------------------------------------------------

  void clearMemory() {
    brain.clear();

    preferences.clear();

    // استعادة Thompson إلى حالة فارغة.
    thompson.importState(
      const <String, dynamic>{},
    );
  }

  // ---------------------------------------------------------------------------
  // BRAIN RESTORE
  // ---------------------------------------------------------------------------

  void _restoreBrain(
    Map<String, dynamic> data,
  ) {
    _replaceDoubleMap(
      brain.interests,
      data['interests'],
    );

    _replaceDoubleMap(
      brain.dislikes,
      data['dislikes'],
    );

    _replaceDoubleMap(
      brain.creatorAffinity,
      data['creator_affinity'],
    );

    _replaceDoubleMap(
      brain.categoryAffinity,
      data['category_affinity'],
    );

    _replaceDoubleMap(
      brain.itemAffinity,
      data['item_affinity'],
    );

    _replaceIntMap(
      brain.impressions,
      data['impressions'],
    );

    _replaceIntMap(
      brain.opens,
      data['opens'],
    );

    _replaceIntMap(
      brain.skips,
      data['skips'],
    );

    _replaceIntMap(
      brain.hides,
      data['hides'],
    );

    _replaceIntMap(
      brain.lastSeenAt,
      data['last_seen_at'],
    );

    _replaceTransitionMap(
      brain.transitions,
      data['transitions'],
    );

    _replaceDoubleMap(
      brain.ftrlZ,
      data['ftrl_z'],
    );

    _replaceDoubleMap(
      brain.ftrlN,
      data['ftrl_n'],
    );

    _replaceDoubleMap(
      brain.sessionInterests,
      data['session_interests'],
    );

    _replaceDoubleMap(
      brain.sessionDislikes,
      data['session_dislikes'],
    );
  }

  // ---------------------------------------------------------------------------
  // PREFERENCES RESTORE
  // ---------------------------------------------------------------------------

  void _restorePreferences(
    Map<String, dynamic> data,
  ) {
    preferences.clear();

    _replaceDoubleMap(
      preferences.topicBoost,
      data['topic_boost'],
    );

    _replaceDoubleMap(
      preferences.topicBlock,
      data['topic_block'],
    );

    _replaceDoubleMap(
      preferences.creatorBoost,
      data['creator_boost'],
    );

    _replaceDoubleMap(
      preferences.creatorBlock,
      data['creator_block'],
    );

    _replaceDoubleMap(
      preferences.itemAdjustments,
      data['item_adjustments'],
    );

    final hidden =
        data['hidden_items'];

    if (hidden is List) {
      preferences.hiddenItems.addAll(
        hidden
            .map(
              (value) =>
                  value.toString().trim(),
            )
            .where(
              (value) => value.isNotEmpty,
            ),
      );
    }

    preferences.explorationLevel =
        _clamp01(
      _number(
        data['exploration_level'],
        fallback:
            preferences.explorationLevel,
      ),
    );

    preferences.noveltyPreference =
        _clamp01(
      _number(
        data['novelty_preference'],
        fallback:
            preferences.noveltyPreference,
      ),
    );

    preferences.diversityPreference =
        _clamp01(
      _number(
        data['diversity_preference'],
        fallback:
            preferences.diversityPreference,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // MAP HELPERS
  // ---------------------------------------------------------------------------

  Map<String, double> _doubleMap(
    Map<String, double> source,
  ) {
    final output =
        <String, double>{};

    for (final entry
        in source.entries) {
      if (!entry.value.isFinite) {
        continue;
      }

      output[entry.key] =
          entry.value;
    }

    return output;
  }

  Map<String, int> _intMap(
    Map<String, int> source,
  ) {
    return <String, int>{
      for (final entry
          in source.entries)
        entry.key: entry.value,
    };
  }

  Map<String, Map<String, int>>
      _transitionMap(
    Map<String, Map<String, int>>
        source,
  ) {
    final output =
        <String, Map<String, int>>{};

    for (final entry
        in source.entries) {
      output[entry.key] =
          <String, int>{
        for (final next
            in entry.value.entries)
          next.key: next.value,
      };
    }

    return output;
  }

  Map<String, dynamic>
      _mapOf(
    Object? value,
  ) {
    if (value is Map) {
      return Map<String, dynamic>.from(
        value,
      );
    }

    return <String, dynamic>{};
  }

  void _replaceDoubleMap(
    Map<String, double> target,
    Object? source,
  ) {
    target.clear();

    if (source is! Map) {
      return;
    }

    source.forEach(
      (key, value) {
        final number =
            value is num
                ? value.toDouble()
                : double.tryParse(
                    value.toString(),
                  );

        if (number == null ||
            !number.isFinite) {
          return;
        }

        target[
          key.toString()
        ] = number;
      },
    );
  }

  void _replaceIntMap(
    Map<String, int> target,
    Object? source,
  ) {
    target.clear();

    if (source is! Map) {
      return;
    }

    source.forEach(
      (key, value) {
        int? number;

        if (value is int) {
          number = value;
        } else if (value is num) {
          number = value.toInt();
        } else {
          number =
              int.tryParse(
            value.toString(),
          );
        }

        if (number == null) {
          return;
        }

        target[
          key.toString()
        ] = number;
      },
    );
  }

  void _replaceTransitionMap(
    Map<String, Map<String, int>>
        target,
    Object? source,
  ) {
    target.clear();

    if (source is! Map) {
      return;
    }

    source.forEach(
      (key, value) {
        if (value is! Map) {
          return;
        }

        final inner =
            <String, int>{};

        value.forEach(
          (nextKey, rawValue) {
            int? count;

            if (rawValue is int) {
              count = rawValue;
            } else if (rawValue is num) {
              count =
                  rawValue.toInt();
            } else {
              count =
                  int.tryParse(
                rawValue.toString(),
              );
            }

            if (count != null &&
                count > 0) {
              inner[
                nextKey.toString()
              ] = count;
            }
          },
        );

        if (inner.isNotEmpty) {
          target[
            key.toString()
          ] = inner;
        }
      },
    );
  }

  double _number(
    Object? value, {
    required double fallback,
  }) {
    if (value is num) {
      final result =
          value.toDouble();

      if (result.isFinite) {
        return result;
      }
    }

    final parsed =
        double.tryParse(
      value?.toString() ?? '',
    );

    return parsed != null &&
            parsed.isFinite
        ? parsed
        : fallback;
  }

  double _clamp01(
    double value,
  ) {
    return value.clamp(
      0.0,
      1.0,
    );
  }
}
