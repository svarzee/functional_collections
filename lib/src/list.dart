import 'iterable.dart';
import 'option.dart';
import 'ordered_iterable.dart';
import 'sized.dart';

abstract class FList<T> with FIterable<T>, FOrdered<T>, FSized<T> {
  FList._();

  factory FList() => _Nil<T>();

  factory FList.from(Iterable<T> iterable) =>
      iterable.fold(FList<T>(), (acc, item) => acc.prepend(item)).reverse();

  factory FList.of(T item) => _Cons(item, _Nil(), 1);

  FList<T> append(T item);

  FList<T> prepend(T item) => _Cons(item, this, this.size() + 1);

  FList<T> tail();

  List<T> dartList() {
    final dartList = List<T>();
    this.forEach(dartList.add);
    return dartList;
  }

  FOption<T> headOption();

  @override
  FList<T> reverse() =>
      size() <= 1 ? this : foldLeft(FList(), (acc, item) => acc.prepend(item));

  @override
  Iterator<T> iterator() => _FListIterator<T>(this);

  @override
  FList<R> map<R>(R mapper(T value));
}

class _Nil<T> extends FList<T> {
  _Nil() : super._();

  @override
  FList<T> append(T item) => FList.of(item);

  @override
  int size() => 0;

  @override
  FNone<T> headOption() => FNone<T>();

  @override
  FList<T> tail() => _Nil<T>();

  @override
  FIterable<T> filter(bool Function(T item) predicate) => _Nil<T>();

  @override
  FList<R> map<R>(R mapper(T value)) => _Nil<R>();
}

class _Cons<T> extends FList<T> {
  T _head;
  FList<T> _tail;
  int _size;

  _Cons(this._head, this._tail, this._size) : super._();

  @override
  FList<T> append(T item) =>
      this.foldRight(FList.of(item), (item, acc) => acc.prepend(item));

  @override
  int size() {
    return _size;
  }

  @override
  FSome<T> headOption() {
    return FSome(_head);
  }

  @override
  FList<T> tail() {
    return _tail;
  }

  @override
  FList<T> filter(bool Function(T item) predicate) => this.foldRight(
      FList<T>(), (item, acc) => predicate(item) ? acc.prepend(item) : acc);

  @override
  FList<R> map<R>(R mapper(T value)) =>
      this.foldRight(FList<R>(), (item, acc) => acc.prepend(mapper(item)));
}

class _FListIterator<T> extends Iterator<T> {
  FList<T> _current = _Nil<T>();
  FList<T> _list;

  _FListIterator(this._list);

  @override
  T get current => _current.headOption().getOrElse(null);

  @override
  bool moveNext() {
    _current = _list;
    _list = _list.tail();
    return _current.isNonEmpty();
  }
}
