abstract class FSized<T> {
  int size();

  bool isEmpty() => size() == 0;

  bool isNonEmpty() => !isEmpty();
}
