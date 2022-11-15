import 'dart:async';

import 'package:notified_preferences/notified_preferences.dart';

class LocalPersistence {
  LocalPersistence._();

  static final LocalPersistence instance = LocalPersistence._();

  Future<void> initialize([FutureOr<SharedPreferences>? preferences]) async {
    _prefs = await (preferences ?? SharedPreferences.getInstance());
  }

  SharedPreferences? _prefs;
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
