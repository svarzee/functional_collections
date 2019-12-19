import 'dart:collection';
import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:functional_collections/src/hamt.dart';

class ContainsBenchmark extends BenchmarkBase {
  ContainsBenchmark(bool functional, this.N)
      : this.functional = functional,
        super((functional ? "functional" : "dart") + " contains");

  final bool functional;

  List<int> values;
  int N;

  Hamt funSet;
  Set dartSet;

  @override
  void setup() {
    final random = Random(0);
    values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    funSet = values.fold(Hamt(), (set, val) => set.add(val, val));
    dartSet = values.fold(HashSet(), (set, val) => set..add(val));
  }

  @override
  void run() {
    if (functional) {
      values.forEach(funSet.contains);
    } else {
      values.forEach(dartSet.contains);
    }
  }
}

class AddBenchmark extends BenchmarkBase {
  AddBenchmark(bool functional, bool copy, this.N)
      : this.functional = functional,
        this.copy = copy,
        super((functional ? "functional" : "dart") +
            (copy ? " copy" : "") +
            " add");

  final bool functional;
  final bool copy;

  List<int> values;
  int N;

  @override
  void setup() {
    final random = Random(0);
    values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
  }

  @override
  void run() {
    if (functional) {
      values.fold(Hamt(), (set, val) => set.add(val, val));
    } else if (copy) {
      values.fold(HashSet(), (set, val) => HashSet.of(set)..add(val));
    } else {
      values.fold(HashSet(), (set, val) => set..add(val));
    }
  }
}

class RemoveBenchmark extends BenchmarkBase {
  RemoveBenchmark(bool functional, bool copy, this.N)
      : this.functional = functional,
        this.copy = copy,
        super((functional ? "functional" : "dart") +
            (copy ? " copy" : "") +
            " remove");

  final bool functional;
  final bool copy;

  List<int> values;
  int N;

  Hamt funSet;
  Set dartSet;

  @override
  void setup() {
    final random = Random(0);
    values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
    funSet = values.fold(Hamt(), (set, val) => set.add(val, val));
    dartSet = values.fold(HashSet(), (set, val) => set..add(val));
  }

  @override
  void run() {
    if (functional) {
      values.fold(funSet, (set, val) => set.remove(val));
    } else if (copy) {
      values.fold(dartSet, (set, val) => HashSet.of(set)..remove(val));
    } else {
      values.fold(dartSet, (set, val) => set..remove(val));
    }
  }
}

main() {
  ContainsBenchmark(false, 10000).report();
  ContainsBenchmark(true, 10000).report();

  AddBenchmark(false, false, 10000).report();
  AddBenchmark(false, true, 10000).report();
  AddBenchmark(true, false, 10000).report();

  RemoveBenchmark(false, false, 10000).report();
  RemoveBenchmark(false, true, 10000).report();
  RemoveBenchmark(true, false, 10000).report();
}
