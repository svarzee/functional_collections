import 'package:functional_collections/functional_collections.dart';

void main() {
  print(FNone());
  print(FSome(1));
  print(FList.from([1, 2, 3]).append(4).prepend(0));
  print(FSet.from([1, 2, 3]).add(4).add(2));
  print(FMap.from([FTuple2(1, "a"), FTuple2(2, "b")]).put(3, "c"));
  print(FTuple2(1, 2));
}
