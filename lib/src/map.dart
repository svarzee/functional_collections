import 'package:functional_collections/src/hamt.dart';
import 'package:functional_collections/src/list.dart';
import 'package:functional_collections/src/tuple.dart';

class FMap<K, V> extends Iterable<Tuple2<K, V>> {
  final Hamt<K, V> hamt;

  FMap() : hamt = Hamt();

  FMap._(this.hamt);

  FMap.from(Iterable<Tuple2<K, V>> keyVals)
      : hamt = Hamt().addAll(keyVals.toList());

  bool containsKey(K key) => hamt.contains(key);

  FMap<K, V> put(K key, V value) => FMap._(hamt.add(key, value));

  FMap<K, V> remove(K key) => FMap._(hamt.remove(key));

  FMap<K, V> add(Tuple2<K, V> keyVal) =>
      FMap._(hamt.add(keyVal.val1, keyVal.val2));

  FMap<K, V> addAll(Iterable<Tuple2<K, V>> keyVals) =>
      FMap._(hamt.addAll(keyVals));

  @override
  Iterator<Tuple2<K, V>> get iterator => hamt.entries().iterator;

  FList<R> map<R>(R mapper(Tuple2<K, V> value)) => entries().map(mapper);

  FMap<RK, RV> mapEntries<RK, RV>(Tuple2<RK, RV> mapper(Tuple2<K, V> value)) =>
      FMap.from(entries().map(mapper));

  FMap<RK, V> mapKeys<RK>(RK mapper(K value)) => FMap.from(
      entries().map((keyVal) => Tuple2(mapper(keyVal.val1), keyVal.val2)));

  FMap<K, RV> mapValues<RV>(RV mapper(V value)) => FMap.from(
      entries().map((keyVal) => Tuple2(keyVal.val1, mapper(keyVal.val2))));

  FList<Tuple2<K, V>> entries() => hamt.entries();

  FList<K> keys() => hamt.entries().map((item) => item.val1);

  FList<V> values() => hamt.entries().map((item) => item.val2);
}
