import 'package:test/test.dart';
import 'package:functional_collections/src/list.dart';

void main() {
  test('FList.isEmpty for empty', () {
    expect(FList().isEmpty(), isTrue);
  });

  test('FList.isEmpty for non-empty', () {
    expect(FList().prepend(1).isEmpty(), isFalse);
  });

  test('FList.prepend constructs expected list', () {
    expect(FList().prepend(1).prepend(2).dartList(), equals([2, 1]));
  });
}
