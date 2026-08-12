import 'dart:convert';
import 'dart:io';

import 'package:valora_assets/performance_dataset.dart';

void main(List<String> args) {
  final outputPath = _option(args, '--output') ?? 'build/performance/datasets';
  final scaleOption = _option(args, '--scale') ?? 'all';
  final archiveBytes = int.tryParse(_option(args, '--archive-bytes') ?? '');
  final output = Directory(outputPath)..createSync(recursive: true);
  final scales = scaleOption == 'all'
      ? ValoraBenchmarkScale.values
      : ValoraBenchmarkScale.values
          .where((scale) => scale.name == scaleOption)
          .toList();
  if (scales.isEmpty) {
    stderr.writeln('Unknown benchmark scale: $scaleOption');
    exitCode = 2;
    return;
  }

  final manifest = <String, dynamic>{
    'seed': ValoraPerformanceDataset.defaultSeed,
    'archiveBytes': archiveBytes,
    'datasets': <Map<String, dynamic>>[],
  };
  for (final scale in scales) {
    final dataset = ValoraPerformanceDataset(scale: scale);
    final targetBytes = archiveBytes ?? scale.archiveTargetBytes;
    final file =
        File('${output.path}${Platform.pathSeparator}${scale.name}.json');
    final json = dataset.toJson(targetBytes: targetBytes);
    file.writeAsStringSync(json);
    (manifest['datasets'] as List<Map<String, dynamic>>).add({
      'scale': scale.name,
      'file': file.path,
      'bytes': FileStat.statSync(file.path).size,
      'assetCount': dataset.assetCount,
      'mediaCount': dataset.mediaCount,
      'targetBytes': targetBytes,
    });
  }
  final manifestFile = File(
      '${output.path}${Platform.pathSeparator}manifest.json')
    ..writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(manifest));
  stdout.writeln('manifest=${manifestFile.path}');
}

String? _option(List<String> args, String name) {
  final prefix = '$name=';
  for (final arg in args) {
    if (arg.startsWith(prefix)) return arg.substring(prefix.length);
  }
  return null;
}
