import 'dart:collection';
import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:functional_collections/src/hamt.dart';

class AddBenchmark extends BenchmarkBase {
  AddBenchmark(bool functional)
      : this.functional = functional,
        super((functional ? "functional" : "dart") + " add");

  final bool functional;

  List<int> values;
  int N = 10000;

  @override
  void setup() {
    final random = Random(0);
    values = List<int>.generate(N, (idx) => random.nextInt(1 << 32));
  }

  @override
  void run() {
    if (functional) {
      values.fold(Hamt(), (set, val) => set.add(val, val));
    } else {
      values.fold(HashSet(), (set, val) => set..add(val));
    }
  }
}

class ContainsBenchmark extends BenchmarkBase {
  ContainsBenchmark(bool functional)
      : this.functional = functional,
        super((functional ? "functional" : "dart") + " contains");

  final bool functional;

  List<int> values;
  int N = 10000;

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

class RemoveBenchmark extends BenchmarkBase {
  RemoveBenchmark(bool functional)
      : this.functional = functional,
        super((functional ? "functional" : "dart") + " remove");

  final bool functional;

  List<int> values;
  int N = 10000;

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
    } else {
      values.fold(dartSet, (set, val) => set..remove(val));
    }
  }
}

main() {
  AddBenchmark(false).report();
  AddBenchmark(true).report();

  ContainsBenchmark(false).report();
  ContainsBenchmark(true).report();

  RemoveBenchmark(false).report();
  RemoveBenchmark(true).report();
}
