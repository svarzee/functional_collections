mixin FIterable<T> {
  void forEach(void action(T item)) {
    final it = iterator();
    while (it.moveNext()) {
      action(it.current);
    }
  }

  Iterator<T> iterator();

  R fold<R>(R initialValue, R combine(R accumulator, T item)) {
    R accumulator = initialValue;
    this.forEach((item) => accumulator = combine(accumulator, item));
    return accumulator;
  }
}
