import 'package:functional_collections/src/sized.dart';

import 'iterable.dart';
import 'ordered_iterable.dart';

abstract class FOption<T> with FIterable<T>, FOrdered<T>, FSized<T> {
  T get();

  T getOrElse(T value);

  @override
  FOption<R> map<R>(R mapper(T value));

  FOption<R> flatMap<R>(FOption<R> mapper(T value));

  FOption<T> headOption() => this;

  @override
  Iterator<T> iterator() => _FOptionIterator(this);

  @override
  FOption<T> reverse() => this;
}

class FSome<T> extends FOption<T> {
  final T _value;

  FSome(this._value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FSome &&
          runtimeType == other.runtimeType &&
          _value == other._value;

  @override
  int get hashCode => _value.hashCode;

  @override
  T get() => _value;

  @override
  FOption<R> map<R>(R Function(T value) mapper) => FSome(mapper(_value));

  @override
  FOption<R> flatMap<R>(FOption<R> mapper(T value)) => mapper(_value);

  @override
  int size() => 1;

  @override
  T getOrElse(T value) => _value;

  @override
  FOption<T> filter(bool Function(T item) predicate) =>
      predicate(_value) ? this : FNone<T>();
}

class FNone<T> extends FOption<T> {
  FNone();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FNone && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;

  @override
  T get() => throw FNoValuePresentError();

  @override
  FOption<R> map<R>(R mapper(T value)) => FNone<R>();

  @override
  FOption<R> flatMap<R>(FOption<R> Function(T value) mapper) => FNone<R>();

  @override
  int size() => 0;

  @override
  T getOrElse(T value) => value;

  @override
  FOption<T> filter(bool predicate(T item)) => FNone<T>();
}

class _FOptionIterator<T> extends Iterator<T> {
  FOption<T> _current = FNone();
  FOption<T> _option;

  _FOptionIterator(this._option);

  @override
  T get current => _current.headOption().getOrElse(null);

  @override
  bool moveNext() {
    _current = _option;
    _option = FNone();
    return _current.isNonEmpty();
  }
}

class FNoValuePresentError extends Error {
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FNoValuePresentError && runtimeType == other.runtimeType;

  @override
  int get hashCode => 0;
}
