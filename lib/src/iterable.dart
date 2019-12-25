import 'package:functional_collections/functional_collections.dart';
import 'package:functional_collections/src/option.dart';

mixin FIterable<T> on Iterable<T> {
  FOption<T> find(bool Function(T) predicate) =>
      FOption.ofNullable(firstWhere(predicate, orElse: null));

  @override
  bool get isEmpty => length == 0;

  FList<T> toFList() => FList.from(this);

  FSet<T> toFSet() => FSet.from(this);

  FList<R> mapToFList<R>(R Function(T value) mapper) => FList.from(map(mapper));

  FSet<R> mapToFSet<R>(R Function(T value) mapper) => FSet.from(map(mapper));

  FMap<K, V> mapToFMap<K, V>(
          K Function(T value) keyMapper, V Function(T value) valueMapper) =>
      FMap.from(map((value) => FTuple2(keyMapper(value), valueMapper(value))));

  FOption<T> firstOption();
}
