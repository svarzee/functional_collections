import 'dart:collection';
import 'dart:math';

import 'package:functional_collections/src/hamt.dart';
import 'package:functional_collections/src/option.dart';
import 'package:functional_collections/src/tuple.dart';
import 'package:test/test.dart';

void main() {
  test('Empty hampt should not contain any key', () {
    expect(Hamt().contains("some"), isFalse);
  });

  test('Key that is added to hamt should be contained', () {
    expect(Hamt().add("some", "value").contains("some"), isTrue);
  });

  test('Key added twice is should be contained once', () {
    expect(Hamt<String, String>().add("some", "value1").add("some", "value2").entries().toList(),
        [FTuple2("some", "value2")]);
  });

  test('Key added twice to existing hash should be contained once', () {
    expect(
        Hamt<FixedHash, String>()
            .add(FixedHash("some"), "value1")
            .add(FixedHash("some-other"), "value2")
            .add(FixedHash("some-other"), "value3")
            .entries()
            .toList(),
        [FTuple2(FixedHash("some-other"), "value3"), FTuple2(FixedHash("some"), "value1")]);
  });

  test('Key added with addAll twice is should be contained once', () {
    expect(Hamt<String, String>().addAll([FTuple2("some", "value1"), FTuple2("some", "value2")]).entries().toList(),
        [FTuple2("some", "value2")]);
  });

  test('Key added twice to existing hash with addAll should be contained once', () {
    expect(
        Hamt<FixedHash, String>()
            .addAll([
              FTuple2(FixedHash("some"), "value1"),
              FTuple2(FixedHash("some-other"), "value2"),
              FTuple2(FixedHash("some-other"), "value3")
            ])
            .entries()
            .toList(),
        [FTuple2(FixedHash("some-other"), "value3"), FTuple2(FixedHash("some"), "value1")]);
  });

  test('Keys that are added to hamt with addAll should be contained', () {
    var hamt = Hamt().addAll([FTuple2("key1", "val1"), FTuple2("key2", "val2")]);
    expect(hamt.contains("key1") && hamt.contains("key2"), isTrue);
  });

  test('Keys that are added to hamt with addAll and removed should not be contained', () {
    var hamt = Hamt().addAll([FTuple2("key1", "val1"), FTuple2("key2", "val2")]).remove("key1");
    expect(!hamt.contains("key1") && hamt.contains("key2"), isTrue);
  });

  test('Duplicate keys that are added to hamt with addAll and removed should not be contained', () {
    var hamt =
        Hamt().addAll([FTuple2("key1", "val1"), FTuple2("key1", "val1"), FTuple2("key2", "val2")]).remove("key1");
    expect(!hamt.contains("key1") && hamt.contains("key2"), isTrue);
  });

  test('Value that is added to hamt should be contained', () {
    expect(Hamt<String, String>().add("some", "value").get("some"), FSome("value"));
  });

  test('Key that is added and removed should not be contained', () {
    expect(Hamt().add("some", "value").remove("some").contains("some"), isFalse);
  });

  test('Key that is added twice and removed should not be contained', () {
    expect(Hamt().add("some", "value").add("some", "value").remove("some").contains("some"), isFalse);
  });

  test('For two values added with the same key, the later should be contained.', () {
    expect(
        Hamt<String, String>().add("some", "value").add("some", "another value").get("some"), FSome("another value"));
  });

  test('For two different keys with the same hashcode both should be contained.', () {
    expect(
        Hamt<FixedHash, String>()
            .add(FixedHash("some"), "value")
            .add(FixedHash("some-other"), "another value")
            .get(FixedHash(("some"))),
        FSome("value"));
  });

  test('Shoud have results equal to dart set.', () {
    int N = 3;
    final random = Random(0);
    final values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    Hamt funSet = values.fold(Hamt(), (set, val) => set.add(val, val));
    Set dartSet = values.fold(HashSet(), (set, val) => set..add(val));

    final moreValues = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    final allValues = values..addAll(moreValues);

    expect(allValues.map((funSet.contains)).toList(), allValues.map((dartSet.contains)).toList());
  });

  test('Shoud have results equal to dart set (for a lot of data).', () {
    int N = 10000;
    final random = Random(0);
    final values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    Hamt funSet = values.fold(Hamt(), (set, val) => set.add(val, val));
    Set dartSet = values.fold(HashSet(), (set, val) => set..add(val));

    final moreValues = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    final allValues = values..addAll(moreValues);

    expect(allValues.map((funSet.contains)).toList(), allValues.map((dartSet.contains)).toList());
  });
}

class FixedHash {
  String key;

  FixedHash(this.key);

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is FixedHash && runtimeType == other.runtimeType && key == other.key;

  @override
  int get hashCode => 0;

  @override
  String toString() => key;
}
