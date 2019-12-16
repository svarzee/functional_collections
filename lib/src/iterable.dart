mixin FIterable<T> {
  void forEach(void action(T item)) {
    final it = iterator();
    while (it.moveNext()) {
      action(it.current);
    }
  }

  bool exists(bool predicate(T item)) {
    final it = iterator();
    while (it.moveNext()) {
      if (predicate(it.current)) {
        return true;
      }
    }
    return false;
  }

  bool forAll(bool predicate(T item)) {
    return !exists((item) => !predicate(item));
  }

  Iterator<T> iterator();

  R fold<R>(R initialValue, R combine(R accumulator, T item)) {
    R accumulator = initialValue;
    this.forEach((item) => accumulator = combine(accumulator, item));
    return accumulator;
  }
}
