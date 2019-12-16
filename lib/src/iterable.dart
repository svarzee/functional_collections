import 'package:functional_collections/src/option.dart';

mixin FIterable<T> {
  void forEach(void action(T item)) {
    final it = iterator();
    while (it.moveNext()) {
      action(it.current);
    }
  }

  FIterable<T> filter(bool predicate(T item));

  FOption<T> find(bool predicate(T item)) {
    final it = iterator();
    while (it.moveNext()) {
      if (predicate(it.current)) {
        return FSome(it.current);
      }
    }
    return FNone();
  }

  bool exists(bool predicate(T item)) => find(predicate).isNonEmpty();

  bool forAll(bool predicate(T item)) => !exists((item) => !predicate(item));

  Iterator<T> iterator();

  R fold<R>(R initialValue, R combine(R accumulator, T item)) {
    R accumulator = initialValue;
    this.forEach((item) => accumulator = combine(accumulator, item));
    return accumulator;
  }
}
