import 'dart:math' as math;

class ValoraBenchmarkSummary {
  final int count;
  final double p50;
  final double p95;
  final double max;

  const ValoraBenchmarkSummary({
    required this.count,
    required this.p50,
    required this.p95,
    required this.max,
  });

  factory ValoraBenchmarkSummary.fromValues(Iterable<num> values) {
    final sorted = values.map((value) => value.toDouble()).toList()..sort();
    if (sorted.isEmpty) {
      return const ValoraBenchmarkSummary(count: 0, p50: 0, p95: 0, max: 0);
    }
    return ValoraBenchmarkSummary(
      count: sorted.length,
      p50: _percentile(sorted, .50),
      p95: _percentile(sorted, .95),
      max: sorted.last,
    );
  }

  Map<String, dynamic> toMap() => {
        'count': count,
        'p50': p50,
        'p95': p95,
        'max': max,
      };
}

class ValoraBenchmarkRecord {
  final String scenario;
  final String dataset;
  final Map<String, ValoraBenchmarkSummary> metrics;
  final Map<String, dynamic> counters;

  const ValoraBenchmarkRecord({
    required this.scenario,
    required this.dataset,
    required this.metrics,
    this.counters = const {},
  });

  Map<String, dynamic> toMap() => {
        'scenario': scenario,
        'dataset': dataset,
        'metrics': metrics.map((key, value) => MapEntry(key, value.toMap())),
        'counters': counters,
      };
}

double _percentile(List<double> sorted, double ratio) {
  final index = math.max((sorted.length * ratio).ceil() - 1, 0);
  return sorted[index.clamp(0, sorted.length - 1)];
}
