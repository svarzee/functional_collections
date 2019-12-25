import 'package:functional_collections/src/hamt.dart';
import 'package:functional_collections/src/tuple.dart';

class FSet<T> extends Iterable<T> {
  final Hamt<T, T> hamt;

  FSet() : hamt = Hamt();

  FSet._(Hamt<T, T> hamt) : hamt = hamt;

  FSet.from(Iterable<T> keyVals)
      : hamt = Hamt<T, T>()
            .addAll(keyVals.map((value) => FTuple2(value, value)).toList());

  @override
  bool contains(Object value) => hamt.contains(value);

  FSet<T> add(T value) => FSet._(hamt.add(value, value));

  FSet<T> addAll(Iterable<T> values) =>
      FSet._(hamt.addAll(values.map((value) => FTuple2(value, value)).toList()));

  FSet<R> map<R>(R mapper(T value)) => FSet.from(super.map(mapper));

  FSet<T> where(bool test(T value)) => FSet.from(super.where(test));

  @override
  Iterator<T> get iterator => hamt.entries().map((item) => item.val1).iterator;
}
