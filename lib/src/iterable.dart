import 'package:functional_collections/src/option.dart';

mixin FIterable<T> on Iterable<T> {
  FOption<T> find(bool predicate(T item)) =>
      FOption.ofNullable(firstWhere(predicate, orElse: null));

  Iterable<T> filter(bool predicate(T item)) => where(predicate);

  @override
  bool get isEmpty => length == 0;
}
