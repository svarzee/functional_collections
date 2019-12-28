import 'iterable.dart';
import 'option.dart';
import 'ordered.dart';

abstract class FList<T> extends Iterable<T> with FIterable<T>, FOrdered<T> {
  FList._();

  factory FList() => _Nil<T>();

  factory FList.from(Iterable<T> iterable) =>
      iterable.fold(FList<T>(), (acc, item) => acc.prepend(item)).reverse();

  factory FList.of(T item) => _Cons(item, _Nil(), 1);

  FList<T> append(T item) =>
      foldRight(FList.of(item), (item, acc) => acc.prepend(item));

  FList<T> appendAll(FOrdered<T> items) =>
      items.foldLeft(reverse(), (acc, item) => acc.prepend(item)).reverse();

  FList<T> prepend(T item) => _Cons(item, this, length + 1);

  FList<T> prependAll(FOrdered<T> items) =>
      items.reverse().foldLeft(this, (acc, item) => acc.prepend(item));

  FList<T> tail();

  FList<R> flatMap<R>(FOrdered<R> Function(T value) mapper) => foldLeft(
      FList<R>(),
      (FList<R> acc, item) => mapper(item)
          .foldLeft(acc, (FList<R> acc, item) => acc.prepend(item))).reverse();

  @override
  FList<T> reverse() =>
      length <= 1 ? this : foldLeft(FList(), (acc, item) => acc.prepend(item));

  @override
  Iterator<T> get iterator => _FListIterator<T>(this);

  @override
  FList<T> where(bool Function(T item) predicate) => foldRight(
      FList<T>(), (item, acc) => predicate(item) ? acc.prepend(item) : acc);

  @override
  FList<R> map<R>(R Function(T value) mapper) =>
      foldRight(FList<R>(), (item, acc) => acc.prepend(mapper(item)));

  FList<T> replace(T value, T replacement) =>
      map((item) => item == value ? replacement : item);

  @override
  String toString() => '[' + join(', ') + ']';
}

class _Nil<T> extends FList<T> {
  _Nil() : super._();

  @override
  int get length => 0;

  @override
  FNone<T> firstOption() => FNone<T>();

  @override
  FList<T> tail() => _Nil<T>();
}

class _Cons<T> extends FList<T> {
  final T _head;
  final FList<T> _tail;
  final int _size;

  _Cons(this._head, this._tail, this._size) : super._();

  @override
  int get length => _size;

  @override
  FSome<T> firstOption() {
    return FSome(_head);
  }

  @override
  FList<T> tail() {
    return _tail;
  }
}

class _FListIterator<T> extends Iterator<T> {
  FList<T> _current = _Nil<T>();
  FList<T> _list;

  _FListIterator(this._list);

  @override
  T get current => _current.firstOption().getOrElse(null);

  @override
  bool moveNext() {
    _current = _list;
    _list = _list.tail();
    return _current.isNotEmpty;
  }
}
