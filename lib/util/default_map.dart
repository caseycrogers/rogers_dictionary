extension DefaultMap<K,V> on Map<K,V> {
  V getOrElse(K key, V defaultValue) {
    if (this.containsKey(key)) {
      return this[key]!;
    } else {
      this[key] = defaultValue;
      return defaultValue;
    }
  }
}