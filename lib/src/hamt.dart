import 'package:functional_collections/src/list.dart';
import 'package:functional_collections/src/option.dart';
import 'package:functional_collections/src/tuple.dart';

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

  factory Hamt() => _EmptyLeaf();

  FList<FTuple2<K, V>> entries() =>
      _entries().map((keyVal) => FTuple2<K, V>(keyVal.key, keyVal.val));

  FList<_KeyVal<K, V>> _entries();

  Hamt<K, V> add(K key, V val) => _add(0, key, val);

  Hamt<K, V> addAll(Iterable<FTuple2<K, V>> keyVals) => _addAll(
      0,
      keyVals
          .map((keyVal) => _KeyVal<K, V>(keyVal.val1, keyVal.val2))
          .toList());

  Hamt<K, V> remove(K key) => _remove(0, key);

  bool contains(K key) => _contains(0, key);

  FOption<V> get(K key) => _get(0, key);

  Hamt<K, V> _add(int shift, K key, V val);

  Hamt<K, V> _addAll(int shift, List<_KeyVal<K, V>> keyVals);

  Hamt<K, V> _remove(int shift, K key);

  bool _contains(int shift, K key);

  FOption<V> _get(int shift, K key);
}

class _CompressedNode<K, V> extends Hamt<K, V> {
  final int mask;
  final List<Hamt<K, V>> array;

  _CompressedNode(this.mask, this.array) : super._();

  factory _CompressedNode.ofKeyVals(int shift, FList<_KeyVal<K, V>> keyVals) {
    final array = List(keyVals.length);
    final mask = keyVals.foldLeft(
        0, (mask, keyVal) => mask | _bit(_prefix(keyVal.key.hashCode, shift)));
    var progressMask = 0;
    keyVals.forEach((keyVal) {
      final key = keyVal.key;
      final val = keyVal.val;
      final prefix = _prefix(keyVal.key.hashCode, shift);
      final bit = _bit(prefix);
      if (_exists(bit, progressMask)) {
        final index = _index(mask, prefix);
        array[index] = array[index]._add(shift + _PREFIX_SIZE, key, val);
      } else {
        progressMask |= bit;
        final index = _index(mask, prefix);
        array[index] = _SingleLeaf.of(key, val);
      }
    });
    return _CompressedNode(mask, array);
  }

  factory _CompressedNode.ofTwo(
      int shift, _KeyVal<K, V> keyVal1, _KeyVal<K, V> keyVal2) {
    final hash1 = keyVal1.key.hashCode;
    final hash2 = keyVal2.key.hashCode;
    final prefix1 = _prefix(hash1, shift);
    final prefix2 = _prefix(hash2, shift);
    final bit1 = _bit(prefix1);
    final bit2 = _bit(prefix2);
    final mask = bit1 | bit2;
    if (prefix1 == prefix2) {
      return _CompressedNode(mask,
          [_CompressedNode.ofTwo(shift + _PREFIX_SIZE, keyVal1, keyVal2)]);
    } else {
      final first = prefix1 > prefix2 ? keyVal2 : keyVal1;
      final second = prefix1 > prefix2 ? keyVal1 : keyVal2;
      return _CompressedNode(mask, [
        _SingleLeaf.of(first.key, first.val),
        _SingleLeaf.of(second.key, second.val)
      ]);
    }
  }

  @override
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
      final newNode = _SingleLeaf.of(key, val);
      final updatedArray = List.of(array)..insert(index, newNode);
      return _CompressedNode(newMask, updatedArray);
    }
  }

  @override
  Hamt<K, V> _addAll(int shift, List<_KeyVal<K, V>> keyVals) {
    if (keyVals.isEmpty) {
      return this;
    } else {
      var mask = this.mask;
      final array = List.of(this.array);
      keyVals.forEach((keyVal) {
        final hash = keyVal.key.hashCode;
        final prefix = _prefix(hash, shift);
        var bit = _bit(prefix);
        if (!_exists(bit, mask)) {
          mask |= bit;
          array.insert(
              _index(mask, prefix), _SingleLeaf(hash, keyVal.key, keyVal.val));
        } else {
          var index = _index(mask, prefix);
          array[index] =
              array[index]._add(shift + _PREFIX_SIZE, keyVal.key, keyVal.val);
        }
      });
      return _CompressedNode(mask, array);
    }
  }

  @override
  Hamt<K, V> _remove(int shift, K key) {
    final prefix = _prefix(key.hashCode, shift);
    final bit = _bit(prefix);
    if (_exists(bit, mask)) {
      final index = _index(mask, prefix);
      final updatedNode = array[index]._remove(shift + _PREFIX_SIZE, key);
      if (updatedNode is _EmptyLeaf<K, V>) {
        final updatedArray = List.of(array)..removeAt(index);
        return _CompressedNode(mask ^ bit, updatedArray);
      } else {
        final updatedArray = List.of(array)..[index] = updatedNode;
        return _CompressedNode(mask, updatedArray);
      }
    } else {
      return this;
    }
  }

  @override
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

  @override
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

  @override
  FList<_KeyVal<K, V>> _entries() => array.fold(
      FList(),
      (acc, item) =>
          item._entries().fold(acc, (acc, item) => acc.prepend(item)));
}

class _EmptyLeaf<K, V> extends Hamt<K, V> {
  _EmptyLeaf() : super._();

  @override
  Hamt<K, V> _add(int shift, K key, V val) =>
      _SingleLeaf<K, V>(key.hashCode, key, val);

  @override
  Hamt<K, V> _remove(int shift, K key) => this;

  @override
  bool _contains(int shift, K key) => false;

  @override
  FOption<V> _get(int shift, K key) => FNone();

  @override
  Hamt<K, V> _addAll(int shift, List<_KeyVal<K, V>> keyVals) {
    if (keyVals.isEmpty) {
      return this;
    } else if (keyVals.length == 1) {
      var key = keyVals.first.key;
      var val = keyVals.first.val;
      return _SingleLeaf<K, V>(key.hashCode, key, val);
    } else if (keyVals
        .every((keyVal) => keyVal.key.hashCode == keyVals.first.key.hashCode)) {
      final dedupKeyVals = Set<_KeyVal<K, V>>()..addAll(keyVals.reversed);
      final hash = keyVals.first.key.hashCode;
      return dedupKeyVals.length > 1
          ? _Leaf(hash, FList.from(dedupKeyVals))
          : _SingleLeaf<K, V>(
              hash, dedupKeyVals.first.key, dedupKeyVals.first.val);
    } else {
      return _CompressedNode<K, V>(0, [])._addAll(shift, keyVals);
    }
  }

  @override
  FList<_KeyVal<K, V>> _entries() => FList();
}

class _SingleLeaf<K, V> extends Hamt<K, V> {
  int hash;
  K key;
  V val;

  _SingleLeaf(this.hash, this.key, this.val) : super._();

  factory _SingleLeaf.of(K key, V val) => _SingleLeaf(key.hashCode, key, val);

  @override
  Hamt<K, V> _add(int shift, K key, V val) {
    if (key.hashCode == hash) {
      return this.key == key
          ? _SingleLeaf<K, V>(hash, key, val)
          : _Leaf(hash,
              FList.of(_KeyVal(this.key, this.val)).prepend(_KeyVal(key, val)));
    } else {
      return _CompressedNode.ofTwo(
          shift, _KeyVal(this.key, this.val), _KeyVal(key, val));
    }
  }

  @override
  Hamt<K, V> _remove(int shift, K key) =>
      key.hashCode == hash && key == this.key ? _EmptyLeaf() : this;

  @override
  bool _contains(int shift, K key) => key.hashCode == hash && key == this.key;

  @override
  FOption<V> _get(int shift, K key) =>
      key.hashCode == hash && key == this.key ? FSome(val) : FNone();

  @override
  Hamt<K, V> _addAll(int shift, List<_KeyVal<K, V>> keyVals) {
    if (keyVals.isEmpty) {
      return this;
    } else if (keyVals.every((keyVal) => keyVal.key.hashCode == hash)) {
      final dedupKeyVals = (Set<_KeyVal<K, V>>.from([(_KeyVal<K, V>(key, val))])
        ..addAll(keyVals.reversed));
      return dedupKeyVals.length > 1
          ? _Leaf(hash, FList.from(dedupKeyVals))
          : this;
    } else {
      return _CompressedNode(0, [])
          ._addAll(shift, keyVals..add(_KeyVal(key, val)));
    }
  }

  @override
  FList<_KeyVal<K, V>> _entries() => FList.of(_KeyVal<K, V>(key, val));
}

class _Leaf<K, V> extends Hamt<K, V> {
  int hash;
  FList<_KeyVal<K, V>> keyVals;

  _Leaf(this.hash, this.keyVals) : super._();

  @override
  Hamt<K, V> _add(int shift, K key, V val) {
    if (key.hashCode == hash) {
      return keyVals.any((keyVal) => keyVal.key == key)
          ? _Leaf(hash, keyVals.replace(_KeyVal(key, val), _KeyVal(key, val)))
          : _Leaf(hash, keyVals.prepend(_KeyVal(key, val)));
    } else {
      return _CompressedNode.ofKeyVals(
          shift, keyVals.prepend(_KeyVal(key, val)));
    }
  }

  @override
  Hamt<K, V> _remove(int shift, K key) {
    final updatedKeyVals = keyVals.where((keyVal) => keyVal.key != key);
    return updatedKeyVals.length == 1
        ? _SingleLeaf.of(keyVals.first.key, keyVals.first.val)
        : _Leaf(hash, updatedKeyVals);
  }

  @override
  bool _contains(int shift, K key) =>
      keyVals.any((keyVal) => keyVal.key == key);

  @override
  FOption<V> _get(int shift, K key) =>
      keyVals.find((keyVal) => keyVal.key == key).map((keyVal) => keyVal.val);

  @override
  Hamt<K, V> _addAll(int shift, List<_KeyVal<K, V>> keyVals) {
    if (keyVals.isEmpty) {
      return this;
    } else if (keyVals.every((keyVal) => keyVal.key.hashCode == hash)) {
      final dedupKeyVals =
          (Set<_KeyVal<K, V>>.from(this.keyVals)..addAll(keyVals.reversed));
      return _Leaf(hash, FList.from(dedupKeyVals));
    } else {
      return _CompressedNode(0, [])
          ._addAll(shift, keyVals..addAll(this.keyVals));
    }
  }

  @override
  FList<_KeyVal<K, V>> _entries() => keyVals;
}

class _KeyVal<K, V> {
  K key;
  V val;

  _KeyVal(this.key, this.val);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _KeyVal && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => key.hashCode;

  @override
  String toString() {
    return '($key, $val)';
  }
}
