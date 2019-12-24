import 'package:functional_collections/src/iterable.dart';

mixin FSized<T> on FIterable<T> {
  int get size;

  bool get isEmpty => size == 0;

  bool get isNonEmpty => !isEmpty;
}
