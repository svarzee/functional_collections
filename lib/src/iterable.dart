import 'package:functional_collections/functional_collections.dart';
import 'package:functional_collections/src/option.dart';

mixin FIterable<T> on Iterable<T> {
  FOption<T> find(bool predicate(T)) =>
      FOption.ofNullable(firstWhere(predicate, orElse: null));

  @override
  bool get isEmpty => length == 0;

  FList<T> toFList() => FList.from(this);

  FSet<T> toFSet() => FSet.from(this);

  FList<R> mapToFList<R>(R mapper(T value)) => FList.from(map(mapper));

  FSet<R> mapToFSet<R>(R mapper(T value)) => FSet.from(map(mapper));

  FMap<K, V> mapToFMap<K, V>(K keyMapper(T value), V valueMapper(T value)) =>
      FMap.from(map((value) => FTuple2(keyMapper(value), valueMapper(value))));

  FOption<T> firstOption();
}
