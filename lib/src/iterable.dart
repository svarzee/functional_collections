import 'package:functional_collections/src/option.dart';

mixin FIterable<T> on Iterable<T> {
  FOption<T> find(bool predicate(T item)) =>
      FOption.ofNullable(firstWhere(predicate, orElse: null));
}
