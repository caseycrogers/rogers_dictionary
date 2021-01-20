extension NotShittyList<T> on List<T> {
  T get(int index, {T orElse}) => index < this.length ? this[index] : orElse;
}
