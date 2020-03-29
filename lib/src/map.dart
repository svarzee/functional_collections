import 'package:functional_collections/src/hamt.dart';
import 'package:functional_collections/src/list.dart';
import 'package:functional_collections/src/tuple.dart';

class FMap<K, V> extends Iterable<FTuple2<K, V>> {
  final Hamt<K, V> hamt;

  FMap() : hamt = Hamt<K, V>();

  FMap._(this.hamt);

  FMap.from(Iterable<FTuple2<K, V>> keyVals) : hamt = Hamt<K, V>().addAll(keyVals.toList());

  @override
  int get length => hamt.size();

  bool containsKey(K key) => hamt.contains(key);

  FMap<K, V> put(K key, V value) => FMap._(hamt.add(key, value));

  FMap<K, V> remove(K key) => FMap._(hamt.remove(key));

  FMap<K, V> add(FTuple2<K, V> keyVal) => FMap._(hamt.add(keyVal.val1, keyVal.val2));

  FMap<K, V> addAll(Iterable<FTuple2<K, V>> keyVals) => FMap._(hamt.addAll(keyVals));

  @override
  Iterator<FTuple2<K, V>> get iterator => hamt.entries().iterator;

  @override
  FList<R> map<R>(R Function(FTuple2<K, V> value) mapper) => entries().map(mapper);

  FMap<RK, RV> mapEntries<RK, RV>(FTuple2<RK, RV> Function(FTuple2<K, V> value) mapper) =>
      FMap.from(entries().map(mapper));

  FMap<RK, V> mapKeys<RK>(RK Function(K value) mapper) =>
      FMap.from(entries().map((keyVal) => FTuple2(mapper(keyVal.val1), keyVal.val2)));

  FMap<K, RV> mapValues<RV>(RV Function(V value) mapper) =>
      FMap.from(entries().map((keyVal) => FTuple2(keyVal.val1, mapper(keyVal.val2))));

  FList<FTuple2<K, V>> entries() => hamt.entries();

  FList<K> keys() => hamt.entries().map((item) => item.val1);

  FList<V> values() => hamt.entries().map((item) => item.val2);

  @override
  String toString() => '{' + map((entry) => '${entry.val1}:${entry.val2}').join(', ') + '}';
}
