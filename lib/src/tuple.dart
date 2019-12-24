import 'package:functional_collections/src/list.dart';
import 'package:functional_collections/src/option.dart';

class Tuple2<T1, T2> {
  final T1 val1;
  final T2 val2;

  Tuple2(this.val1, this.val2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple2 &&
          runtimeType == other.runtimeType &&
          val1 == other.val1 &&
          val2 == other.val2;

  @override
  int get hashCode => val1.hashCode ^ val2.hashCode;

  @override
  String toString() {
    return 'Tuple2{val1: $val1, val2: $val2}';
  }
}
