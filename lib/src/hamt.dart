import 'package:functional_collections/src/list.dart';
import 'package:functional_collections/src/option.dart';

const int _PREFIX_SIZE = 5;
const int _ARRAY_SIZE = 1 << _PREFIX_SIZE;
const int _PREFIX_MASK = _ARRAY_SIZE - 1;

int _prefix(int hash, int shift) => (hash >> shift) & _PREFIX_MASK;

int _bit32Count(int i) {
  i = i - ((i >> 1) & 0x55555555);
  i = (i & 0x33333333) + ((i >> 2) & 0x33333333);
  i = (i + (i >> 4)) & 0x0f0f0f0f;
  i = i + (i >> 8);
  i = i + (i >> 16);
  return i & 0x3f;
}

int _bit(int prefix) => 1 << prefix;

bool _exists(int bit, int mask) => bit & mask > 0;

int _index(int mask, int prefix) => _bit32Count((_bit(prefix) - 1) & mask);

abstract class Hamt<K, V> {
  Hamt._();

  factory Hamt() => _Leaf.empty();

  Hamt<K, V> add(K key, V val) => _add(0, key, val);

  Hamt<K, V> remove(K key) => _remove(0, key);

  bool contains(K key) => _contains(0, key);

  FOption<V> get(K key) => _get(0, key);

  Hamt<K, V> _add(int shift, K key, V val);

  Hamt<K, V> _remove(int shift, K key);

  bool _contains(int shift, K key);

  FOption<V> _get(int shift, K key);
}

class _ArrayNode<K, V> extends Hamt<K, V> {
  final List<Hamt<K, V>> array;

  _ArrayNode(this.array) : super._();

  factory _ArrayNode.ofKeyVals(int shift, FList<KeyVal<K, V>> keyVals) {
    final List<Hamt<K, V>> newArray = List.filled(_ARRAY_SIZE, _Leaf.empty());
    keyVals.forEach((keyVal) {
      K key = keyVal.key;
      V val = keyVal.val;
      int prefix = _prefix(keyVal.key.hashCode, shift);
      return newArray
        ..setRange(prefix, prefix + 1,
            [newArray[prefix]._add(shift + _PREFIX_SIZE, key, val)]);
    });
    return _ArrayNode(newArray);
  }

  Hamt<K, V> _add(int shift, K key, V val) {
    final prefix = _prefix(key.hashCode, shift);
    return _ArrayNode(List.of(array)
      ..setRange(prefix, prefix + 1,
          [array[prefix]._add(shift + _PREFIX_SIZE, key, val)]));
  }

  Hamt<K, V> _remove(int shift, K key) {
    final prefix = _prefix(key.hashCode, shift);
    return _ArrayNode(List.of(array)
      ..setRange(prefix, prefix + 1,
          [array[prefix]._remove(shift + _PREFIX_SIZE, key)]));
  }

  bool _contains(int shift, K key) =>
      array[_prefix(key.hashCode, shift)]._contains(shift + _PREFIX_SIZE, key);

  FOption<V> _get(int shift, K key) =>
      array[_prefix(key.hashCode, shift)]._get(shift, key);
}

class _CompressedNode<K, V> extends Hamt<K, V> {
  final int mask;
  final List<Hamt<K, V>> array;

  _CompressedNode(this.mask, this.array) : super._();

  factory _CompressedNode.ofKeyVals(int shift, FList<KeyVal<K, V>> keyVals) {
    List<Hamt<K, V>> array = List(keyVals.size());
    int mask = keyVals.foldLeft(
        0, (mask, keyVal) => mask | _bit(_prefix(keyVal.key.hashCode, shift)));
    int progressMask = 0;
    keyVals.forEach((keyVal) {
      K key = keyVal.key;
      V val = keyVal.val;
      int prefix = _prefix(keyVal.key.hashCode, shift);
      int bit = _bit(prefix);
      if (_exists(bit, progressMask)) {
        int index = _index(mask, prefix);
        array[index] = array[index]._add(shift + _PREFIX_SIZE, key, val);
      } else {
        progressMask |= bit;
        int index = _index(mask, prefix);
        array[index] = _Leaf.of(key, val);
      }
    });
    return _CompressedNode(mask, array);
  }

  Hamt<K, V> _add(int shift, K key, V val) {
    final prefix = _prefix(key.hashCode, shift);
    final bit = _bit(prefix);
    if (_exists(bit, mask)) {
      final index = _index(mask, prefix);
      final updatedNode = array[index]._add(shift + _PREFIX_SIZE, key, val);
      final updatedArray = List.of(array)..[index] = updatedNode;
      return _CompressedNode(mask, updatedArray);
    } else {
      final newMask = mask | bit;
      final index = _index(newMask, prefix);
      final newNode = _Leaf.of(key, val);
      final updatedArray = List.of(array)..insert(index, newNode);
      return _CompressedNode(newMask, updatedArray);
    }
  }

  Hamt<K, V> _remove(int shift, K key) {
    final prefix = _prefix(key.hashCode, shift);
    final bit = _bit(prefix);
    if (_exists(bit, mask)) {
      final index = _index(mask, prefix);
      final updatedNode = array[index]._remove(shift + _PREFIX_SIZE, key);
      final updatedArray = List.of(array)..[index] = updatedNode;
      return _CompressedNode(mask, updatedArray);
    } else {
      return this;
    }
  }

  bool _contains(int shift, K key) {
    final prefix = _prefix(key.hashCode, shift);
    final bit = _bit(prefix);
    if (_exists(bit, mask)) {
      final index = _index(mask, prefix);
      return array[index]._contains(shift + _PREFIX_SIZE, key);
    } else {
      return false;
    }
  }

  FOption<V> _get(int shift, K key) {
    final prefix = _prefix(key.hashCode, shift);
    final bit = _bit(prefix);
    if (_exists(bit, mask)) {
      final index = _index(mask, prefix);
      return array[index]._get(shift + _PREFIX_SIZE, key);
    } else {
      return FNone();
    }
  }
}

class _Leaf<K, V> extends Hamt<K, V> {
  FOption<int> hash;
  FList<KeyVal<K, V>> keyVals;

  _Leaf(this.hash, this.keyVals) : super._();

  factory _Leaf.empty() => _Leaf(FNone(), FList());

  factory _Leaf.of(K key, V val) =>
      _Leaf(FSome(key.hashCode), FList.of(KeyVal(key, val)));

  Hamt<K, V> _add(int shift, K key, V val) {
    if (keyVals.isEmpty()) {
      return _Leaf(FSome(key.hashCode), keyVals.prepend(KeyVal(key, val)));
    } else if (FSome(key.hashCode) == hash) {
      return _Leaf(hash, keyVals.prepend(KeyVal(key, val)));
    } else {
      return _CompressedNode.ofKeyVals(
          shift, keyVals.prepend(KeyVal(key, val)));
    }
  }

  Hamt<K, V> _remove(int shift, K key) =>
      _Leaf(hash, keyVals.filter((keyVal) => keyVal.key != key));

  bool _contains(int shift, K key) =>
      keyVals.exists((keyVal) => keyVal.key == key);

  FOption<V> _get(int shift, K key) =>
      keyVals.find((keyVal) => keyVal.key == key).map((keyVal) => keyVal.val);
}

class KeyVal<K, V> {
  final K key;
  final V val;

  KeyVal(this.key, this.val);
}
