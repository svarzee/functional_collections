import 'package:functional_collections/functional_collections.dart';

void main() {
  FOption<int> opt = 1 > 2 ? FNone() : FSome(1);
  FList.from([1, 2, 3]).append(4).prepend(0);
  FSet.from([1, 2, 3]).add(4);
  FMap.from([FTuple2(1, "a"), FTuple2(2, "b")]).put(3, "c");
}
