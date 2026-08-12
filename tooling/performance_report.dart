import 'dart:convert';
import 'dart:io';

import 'package:valora_assets/performance_metrics.dart';

void main(List<String> args) {
  final inputPath = _option(args, '--input');
  if (inputPath == null) {
    stderr.writeln(
        'Usage: dart run tooling/performance_report.dart --input=<jsonl> [--output=<md>]');
    exitCode = 2;
    return;
  }
  final input = File(inputPath);
  if (!input.existsSync()) {
    stderr.writeln('Input file not found: $inputPath');
    exitCode = 2;
    return;
  }

  final grouped = <String, List<Map<String, dynamic>>>{};
  for (final line in input.readAsLinesSync()) {
    if (line.trim().isEmpty) continue;
    final decoded = jsonDecode(line);
    if (decoded is! Map) continue;
    final record = Map<String, dynamic>.from(decoded);
    final scenario = record['scenario']?.toString() ?? 'unknown';
    final dataset = record['dataset']?.toString() ?? 'unknown';
    final rawMetrics = record['metrics'];
    if (rawMetrics is! Map) continue;
    for (final entry in rawMetrics.entries) {
      final metric = entry.key.toString();
      final summary = _summaryFrom(entry.value);
      if (summary == null) continue;
      final key = '$dataset\u0000$scenario\u0000$metric';
      grouped.putIfAbsent(key, () => []).add(summary.toMap());
    }
  }

  final buffer = StringBuffer()
    ..writeln('# Valora performance baseline')
    ..writeln()
    ..writeln('Generated at `${DateTime.now().toIso8601String()}`.')
    ..writeln()
    ..writeln(
        '| Dataset | Scenario | Metric | Runs | p50 median | p95 max | max max |')
    ..writeln('| --- | --- | --- | ---: | ---: | ---: | ---: |');
  final keys = grouped.keys.toList()..sort();
  for (final key in keys) {
    final parts = key.split('\u0000');
    final rows = grouped[key]!;
    final p50 = rows.map((row) => row['p50'] as num).toList();
    final p95 = rows.map((row) => row['p95'] as num).toList();
    final max = rows.map((row) => row['max'] as num).toList();
    buffer.writeln(
        '| ${parts[0]} | ${parts[1]} | ${parts[2]} | ${rows.length} | ${_median(p50).toStringAsFixed(2)} | ${p95.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} | ${max.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)} |');
  }
  final outputText = buffer.toString();
  final outputPath = _option(args, '--output');
  if (outputPath == null) {
    stdout.write(outputText);
  } else {
    File(outputPath).writeAsStringSync(outputText);
    stdout.writeln('report=$outputPath');
  }
}

ValoraBenchmarkSummary? _summaryFrom(Object? raw) {
  if (raw is List) {
    return ValoraBenchmarkSummary.fromValues(raw.whereType<num>());
  }
  if (raw is! Map) return null;
  final map = Map<Object?, Object?>.from(raw);
  final count = map['count'];
  final p50 = map['p50'];
  final p95 = map['p95'];
  final max = map['max'];
  if (count is! num || p50 is! num || p95 is! num || max is! num) return null;
  return ValoraBenchmarkSummary(
    count: count.toInt(),
    p50: p50.toDouble(),
    p95: p95.toDouble(),
    max: max.toDouble(),
  );
}

double _median(List<num> values) {
  final sorted = values.map((value) => value.toDouble()).toList()..sort();
  if (sorted.isEmpty) return 0;
  final middle = sorted.length ~/ 2;
  if (sorted.length.isOdd) return sorted[middle];
  return (sorted[middle - 1] + sorted[middle]) / 2;
}

String? _option(List<String> args, String name) {
  final prefix = '$name=';
  for (final arg in args) {
    if (arg.startsWith(prefix)) return arg.substring(prefix.length);
  }
  return null;
}
