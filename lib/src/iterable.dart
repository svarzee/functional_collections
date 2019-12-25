import 'package:functional_collections/functional_collections.dart';
import 'package:functional_collections/src/option.dart';

mixin FIterable<T> on Iterable<T> {
  FOption<T> find(bool predicate(T item)) =>
      FOption.ofNullable(firstWhere(predicate, orElse: null));

  @override
  bool get isEmpty => length == 0;

  FList<T> toFList() => FList.from(this);

  FSet<T> toFSet() => FSet.from(this);

  FOption<T> firstOption();
}
