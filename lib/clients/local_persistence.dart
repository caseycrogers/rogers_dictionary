import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:notified_preferences/notified_preferences.dart';

class LocalPersistence {
  LocalPersistence._();

  static final LocalPersistence instance = LocalPersistence._();

  Future<void> initialize([FutureOr<SharedPreferences>? preferences]) async {
    _prefs ??= await (preferences ?? SharedPreferences.getInstance());
  }

  SharedPreferences? _prefs;

  @visibleForTesting
  Future<void> reset() async {
    await _prefs!.clear();
  }
}

class PersistedValueNotifier<T> extends PreferenceNotifier<T> {
  PersistedValueNotifier({
    required String key,
    required T initialValue,
  })  : assert(
          LocalPersistence.instance._prefs != null,
          'You must call `LocalPersistence.instance.initialize...` before '
          'creating any persisted value notifiers.',
        ),
        super(
          preferences: LocalPersistence.instance._prefs!,
          key: key,
          initialValue: initialValue,
        );
}
