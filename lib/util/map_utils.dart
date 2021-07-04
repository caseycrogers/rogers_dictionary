import 'package:flutter/cupertino.dart';

extension MapUtils<K, V> on Map<K, V> {
  V getOrElse(K key, V defaultValue) {
    if (containsKey(key)) {
      return this[key]!;
    } else {
      this[key] = defaultValue;
      return defaultValue;
    }
  }

  Iterable<T> mapDown<T>(T Function(K key, V value) f) {
    return entries.map((e) => f(e.key, e.value));
  }
}

class CallBackMap<K, V> extends ChangeNotifier implements Map<K, V> {
  CallBackMap(Map<K, V> base) : _base = base;

  final Map<K, V> _base;

  @override
  V? operator [](Object? key) {
    return _base[key];
  }

  @override
  void operator []=(K key, V value) {
    _base[key] = value;
    notifyListeners();
  }

  @override
  void addAll(Map<K, V> other) {
    _base.addAll(other);
    notifyListeners();
  }

  @override
  void addEntries(Iterable<MapEntry<K, V>> entries) {
    _base.addEntries(entries);
    notifyListeners();
  }

  @override
  void clear() {
    _base.clear();
    notifyListeners();
  }

  @override
  Map<K2, V2> cast<K2, V2>() => _base.cast<K2, V2>();

  @override
  bool containsKey(Object? key) => _base.containsKey(key);

  @override
  bool containsValue(Object? value) => _base.containsValue(value);

  @override
  Iterable<MapEntry<K, V>> get entries => _base.entries;

  @override
  void forEach(void Function(K, V) f) {
    _base.forEach(f);
  }

  @override
  bool get isEmpty => _base.isEmpty;

  @override
  bool get isNotEmpty => _base.isNotEmpty;

  @override
  Iterable<K> get keys => _base.keys;

  @override
  int get length => _base.length;

  @override
  Map<K2, V2> map<K2, V2>(MapEntry<K2, V2> Function(K, V) transform) =>
      _base.map(transform);

  @override
  V putIfAbsent(K key, V Function() ifAbsent) {
    final V value = _base.putIfAbsent(key, ifAbsent);
    notifyListeners();
    return value;
  }

  @override
  V? remove(Object? key) {
    final V? value = _base.remove(key);
    notifyListeners();
    return value;
  }

  @override
  void removeWhere(bool Function(K, V) test) {
    final int before = _base.length;
    _base.removeWhere(test);
    if (_base.length != before) {
      notifyListeners();
    }
  }

  @override
  Iterable<V> get values => _base.values;

  @override
  String toString() => _base.toString();

  @override
  V update(K key, V Function(V) update, {V Function()? ifAbsent}) {
    final int before = _base.length;
    final V value = _base.update(key, update, ifAbsent: ifAbsent);
    if (_base.length != before) {
      notifyListeners();
    }
    return value;
  }

  @override
  void updateAll(V Function(K, V) update) => _base.updateAll(update);
}
