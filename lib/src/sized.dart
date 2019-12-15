abstract class FSized {
  int size();

  bool isEmpty() => size() == 0;

  bool isNonEmpty() => !isEmpty();
}
