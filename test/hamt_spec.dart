import 'dart:collection';
import 'dart:math';

import 'package:functional_collections/src/hamt.dart';
import 'package:functional_collections/src/option.dart';
import 'package:test/test.dart';

void main() {
  test('Empty hampt should not contain any key', () {
    expect(Hamt().contains("some"), isFalse);
  });

  test('Key that is added to hamt should be contained', () {
    expect(Hamt().add("some", "value").contains("some"), isTrue);
  });

  test('Value that is added to hamt should be contained', () {
    expect(Hamt<String, String>().add("some", "value").get("some"),
        FSome("value"));
  });

  test('Key that is added and remove should not be contained', () {
    expect(
        Hamt().add("some", "value").remove("some").contains("some"), isFalse);
  });

  test('For two values added with the same key, the later should be contained.',
      () {
    expect(
        Hamt<String, String>()
            .add("some", "value")
            .add("some", "another value")
            .get("some"),
        FSome("another value"));
  });

  test(
      'For two different keys with the same hashcode both should be contained.',
      () {
    expect(
        Hamt<String, String>()
            .add("some", "value")
            .add("some", "another value")
            .get("some"),
        FSome("another value"));
  });

  test('Shoud have results equal to dart set.', () {
    int N = 3;
    final random = Random(0);
    final values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    Hamt funSet = values.fold(Hamt(), (set, val) => set.add(val, val));
    Set dartSet = values.fold(HashSet(), (set, val) => set..add(val));

    final moreValues = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    final allValues = values..addAll(moreValues);

    expect(allValues.map((funSet.contains)).toList(),
        allValues.map((dartSet.contains)).toList());
  });

  test('Shoud have results equal to dart set (for a lot of data).', () {
    int N = 10000;
    final random = Random(0);
    final values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    Hamt funSet = values.fold(Hamt(), (set, val) => set.add(val, val));
    Set dartSet = values.fold(HashSet(), (set, val) => set..add(val));

    final moreValues = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    final allValues = values..addAll(moreValues);

    expect(allValues.map((funSet.contains)).toList(),
        allValues.map((dartSet.contains)).toList());
  });
}

class KeyWithSameHash {
  String key;

  KeyWithSameHash(this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeyWithSameHash &&
          runtimeType == other.runtimeType &&
          key == other.key;

  @override
  int get hashCode => 0;
}
