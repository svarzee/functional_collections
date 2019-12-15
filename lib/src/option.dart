import 'package:functional_collections/src/sized.dart';

import 'iterable.dart';
import 'ordered_iterable.dart';

abstract class FOption<T> with FIterable, FOrdered, FSized {
  T get();

  T getOrElse(T value);

  FOption<R> map<R>(R mapper(T value));

  FOption<R> flatMap<R>(FOption<R> mapper(T value));

  FOption<T> headOption() => this;

  @override
  Iterator iterator() => _FOptionIterator(this);

  @override
  FOrdered reverse() => this;
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
  T get() {
    return _value;
  }

  @override
  FSome<R> map<R>(R Function(T value) mapper) {
    return FSome(mapper(_value));
  }

  @override
  FOption<R> flatMap<R>(FOption<R> Function(T value) mapper) {
    return mapper(_value);
  }

  @override
  int size() {
    return 1;
  }

  @override
  T getOrElse(T value) {
    return _value;
  }
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
  T get() {
    throw FNoValuePresentError();
  }

  @override
  FOption<R> map<R>(R Function(T value) mapper) {
    return FNone();
  }

  @override
  FOption<R> flatMap<R>(FOption<R> Function(T value) mapper) {
    return FNone();
  }

  @override
  int size() {
    return 0;
  }

  @override
  T getOrElse(T value) {
    return value;
  }
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
