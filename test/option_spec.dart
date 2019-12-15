import 'package:test/test.dart';
import 'package:functional_collections/src/option.dart';

void main() {
  test('None.get throws NoValuePresentError', () {
    expect(() => FNone().get(), throwsA(FNoValuePresentError()));
  });

  test('Somes with the same value are equal', () {
    expect(FSome(1), equals(FSome(1)));
  });

  test('Somes with different value are different', () {
    expect(FSome(1), isNot(FSome(2)));
  });

  test('Some should map value', () {
    expect(FSome(1).map((v) => v + 2), equals(FSome(3)));
  });

  test('Some should flatMap value', () {
    expect(FSome(1).flatMap((v) => FNone()), equals(FNone()));
  });
}
