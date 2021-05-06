extension NotShittyList<T> on List<T> {
  T get(int index, {required T orElse}) =>
      index < this.length ? this[index] : orElse;

  List<T>? get emptyToNull => isEmpty ? null : this;
}
