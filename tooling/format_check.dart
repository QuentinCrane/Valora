import 'dart:io';

const _roots = <String>['lib', 'test', 'integration_test'];

String _relativePath(String path) {
  final root = Directory.current.absolute.path.replaceAll('\\', '/');
  final absolute = File(path).absolute.path.replaceAll('\\', '/');
  if (absolute.startsWith('$root/')) {
    return absolute.substring(root.length + 1);
  }
  return absolute;
}

List<String> _dartFiles() {
  final files = <String>[];
  for (final root in _roots) {
    final directory = Directory(root);
    if (!directory.existsSync()) continue;
    for (final entity in directory.listSync(recursive: true)) {
      if (entity is File && entity.path.toLowerCase().endsWith('.dart')) {
        files.add(_relativePath(entity.path));
      }
    }
  }
  files.sort();
  return files;
}

Set<String> _formatBaseline() {
  final file = File('tooling/format_baseline.txt');
  if (!file.existsSync()) return <String>{};
  return file
      .readAsLinesSync()
      .map((line) => line.trim().replaceAll('\\', '/'))
      .where((line) => line.isNotEmpty && !line.startsWith('#'))
      .toSet();
}

void main() {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('format_check: run from the repository root');
    exitCode = 2;
    return;
  }

  final files = _dartFiles();
  final baseline = _formatBaseline();
  final missingBaseline =
      baseline.where((path) => !files.contains(path)).toList()..sort();
  if (missingBaseline.isNotEmpty) {
    stderr.writeln(
        'format_check: baseline entries no longer exist: ${missingBaseline.join(', ')}');
    exitCode = 2;
    return;
  }

  final filesToCheck = files.where((path) => !baseline.contains(path)).toList();
  stdout.writeln('format_check: checked ${filesToCheck.length} Dart files');
  stdout.writeln('format_check: excluded ${baseline.length} baseline files');
  if (filesToCheck.isEmpty) return;

  final result = Process.runSync(
    Platform.resolvedExecutable,
    <String>[
      'format',
      '--output=none',
      '--set-exit-if-changed',
      ...filesToCheck,
    ],
  );
  stdout.write(result.stdout);
  stderr.write(result.stderr);
  exitCode = result.exitCode;
}
