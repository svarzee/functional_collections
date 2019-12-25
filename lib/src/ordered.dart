import 'iterable.dart';

mixin FOrdered<T> on FIterable<T> {
  R foldLeft<R>(R initialValue, R Function(R accumulator, T item) combine) =>
      fold(initialValue, combine);

  R foldRight<R>(R initialValue, R Function(T item, R accumulator) combine) =>
      reverse().foldLeft(
          initialValue, (R accumulator, T item) => combine(item, accumulator));

  FOrdered<T> reverse();
}
