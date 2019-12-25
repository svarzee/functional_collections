import 'package:functional_collections/src/list.dart';
import 'package:test/test.dart';

void main() {
  test('FList.isEmpty for empty', () {
    expect(FList().isEmpty, isTrue);
  });

  test('FList.isEmpty for non-empty', () {
    expect(FList().prepend(1).isEmpty, isFalse);
  });

  test('FList.prepend constructs expected list', () {
    expect(FList().prepend(2).prepend(1).dartList(), equals([1, 2]));
  });

  test('FList.prependAll constructs expected list', () {
    expect(FList.from([3, 4]).prependAll(FList.from([1, 2])).dartList(),
        equals([1, 2, 3, 4]));
  });

  test('FList.append constructs expected list', () {
    expect(FList().append(1).append(2).dartList(), equals([1, 2]));
  });

  test('FList.appendAll constructs expected list', () {
    expect(FList.from([1, 2]).appendAll(FList.from([3, 4])).dartList(),
        equals([1, 2, 3, 4]));
  });

  test('FList.from constructs expected list from iterable', () {
    expect(FList.from([1, 2]).dartList(), equals([1, 2]));
  });

  test('FList.map should map list', () {
    expect(FList.from([1, 2]).map((item) => item.toString()).dartList(),
        equals(["1", "2"]));
  });

  test('FList.flatMap should map list', () {
    expect(
        FList.from([
          FList.from([1, 2]),
          FList.from([3, 4])
        ]).flatMap((item) => item).dartList(),
        equals([1, 2, 3, 4]));
  });

  test('FList.reverse should reverse list', () {
    expect(FList.from([1, 2]).reverse().dartList(), equals([2, 1]));
  });

  test('FList.foldLeft fold list from left to right', () {
    expect(FList.from(['a', 'b']).foldLeft('', (acc, item) => acc + item),
        equals('ab'));
  });

  test('FList.foldRight fold list from right to left', () {
    expect(FList.from(['a', 'b']).foldRight('', (item, acc) => acc + item),
        equals('ba'));
  });
}
