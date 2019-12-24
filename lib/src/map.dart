import 'package:functional_collections/src/hamt.dart';
import 'package:functional_collections/src/list.dart';
import 'package:functional_collections/src/tuple.dart';

class FMap<K, V> extends Iterable<Tuple2<K, V>> {
  final Hamt<K, V> hamt;

  FMap() : hamt = Hamt();

  FMap.from(Iterable<Tuple2<K, V>> keyVals)
      : hamt = Hamt().addAll(keyVals.toList());

  bool containsKey(K key) => hamt.contains(key);

  @override
  Iterator<Tuple2<K, V>> get iterator => hamt.entries().iterator;

  FList<Tuple2<K, V>> entries() => hamt.entries();

  FList<K> keys() => hamt.entries().map((item) => item.val1);

  FList<V> values() => hamt.entries().map((item) => item.val2);
}
