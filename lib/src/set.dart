import 'package:functional_collections/src/hamt.dart';
import 'package:functional_collections/src/list.dart';
import 'package:functional_collections/src/tuple.dart';

class FSet<T> extends Iterable<T> {
  final Hamt<T, T> hamt;

  FSet() : hamt = Hamt();

  FSet.from(Iterable<T> keyVals)
      : hamt = Hamt()
            .addAll(keyVals.map((value) => Tuple2(value, value)).toList());

  bool containsKey(T value) => hamt.contains(value);

  @override
  Iterator<T> get iterator => hamt.entries().map((item) => item.val1).iterator;
}
