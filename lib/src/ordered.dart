import 'iterable.dart';

mixin FOrdered<T> on FIterable<T> {
  R foldLeft<R>(R initialValue, R combine(R accumulator, T item)) =>
      fold(initialValue, combine);

  R foldRight<R>(R initialValue, R combine(T item, R accumulator)) =>
      reverse().foldLeft(
          initialValue, (R accumulator, T item) => combine(item, accumulator));

  FOrdered<T> reverse();
}
