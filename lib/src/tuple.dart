class FTuple2<T1, T2> {
  final T1 val1;
  final T2 val2;

  FTuple2(this.val1, this.val2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FTuple2 &&
          runtimeType == other.runtimeType &&
          val1 == other.val1 &&
          val2 == other.val2;

  @override
  int get hashCode => val1.hashCode ^ val2.hashCode;

  FTuple2<RT1, T2> map1<RT1>(RT1 Function(T1 value) mapper) =>
      FTuple2(mapper(val1), val2);

  FTuple2<T1, RT2> map2<RT2>(RT2 Function(T2 value) mapper) =>
      FTuple2(val1, mapper(val2));

  @override
  String toString() => '($val1, $val2)';
}
