import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Map<String, String> _arguments(List<String> args) {
  final result = <String, String>{};
  for (var index = 0; index < args.length; index += 1) {
    final argument = args[index];
    if (!argument.startsWith('--') || index + 1 >= args.length) {
      throw FormatException('invalid argument: $argument');
    }
    result[argument.substring(2)] = args[++index];
  }
  return result;
}

String _required(Map<String, String> arguments, String name) {
  final value = arguments[name];
  if (value == null || value.trim().isEmpty) {
    throw FormatException('--$name is required');
  }
  return value;
}

Map<String, Object> _artifact(
    String type, String path, String certificateSha256) {
  final file = File(path);
  if (!file.existsSync()) throw StateError('artifact does not exist: $path');
  final bytes = file.readAsBytesSync();
  return <String, Object>{
    'type': type,
    'path': path.replaceAll('\\', '/'),
    'bytes': bytes.length,
    'sha256': sha256.convert(bytes).toString().toUpperCase(),
    'certificateSha256': certificateSha256,
  };
}

String _certificate(String value, String name) {
  final normalized =
      value.replaceAll(RegExp(r'[^0-9A-Fa-f]'), '').toUpperCase();
  if (!RegExp(r'^[0-9A-F]{64}$').hasMatch(normalized)) {
    throw FormatException('--$name must be a SHA-256 certificate fingerprint');
  }
  return normalized;
}

void main(List<String> args) {
  try {
    final arguments = _arguments(args);
    final apkPath = _required(arguments, 'apk');
    final aabPath = _required(arguments, 'aab');
    final apkCertificate =
        _certificate(_required(arguments, 'apk-cert'), 'apk-cert');
    final aabCertificate =
        _certificate(_required(arguments, 'aab-cert'), 'aab-cert');
    final outputPath = _required(arguments, 'output');
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final gradle = File('android/app/build.gradle').readAsStringSync();
    final version = RegExp(r'^version:\s*([^\s+]+)\+(\d+)', multiLine: true)
        .firstMatch(pubspec);
    final gradleVersionName =
        RegExp(r'versionName\s+"([^"]+)"').firstMatch(gradle);
    final gradleVersionCode = RegExp(r'versionCode\s+(\d+)').firstMatch(gradle);
    final applicationId =
        RegExp(r'applicationId\s+"([^"]+)"').firstMatch(gradle);
    if (version == null ||
        gradleVersionName == null ||
        gradleVersionCode == null) {
      throw const FormatException('version metadata is incomplete');
    }
    if (version.group(1) != gradleVersionName.group(1) ||
        version.group(2) != gradleVersionCode.group(1)) {
      throw StateError('pubspec and Android version metadata do not match');
    }

    final manifest = <String, Object?>{
      'schemaVersion': 1,
      'applicationId': applicationId?.group(1) ?? 'com.valora.assets',
      'versionName': version.group(1),
      'versionCode': int.parse(version.group(2)!),
      'generatedAtUtc': DateTime.now().toUtc().toIso8601String(),
      'source': {
        'builder': Platform.environment['GITHUB_ACTIONS'] == 'true'
            ? 'github-actions'
            : 'local',
        'repository': Platform.environment['GITHUB_REPOSITORY'],
        'commit': Platform.environment['GITHUB_SHA'],
        'ref': Platform.environment['GITHUB_REF'],
        'workflowRun': Platform.environment['GITHUB_RUN_ID'],
      },
      'artifacts': [
        _artifact('apk', apkPath, apkCertificate),
        _artifact('aab', aabPath, aabCertificate),
      ],
    };
    final output = File(outputPath);
    output.parent.createSync(recursive: true);
    final encoded = const JsonEncoder.withIndent('  ').convert(manifest);
    output.writeAsStringSync('$encoded\n');
    stdout.writeln('release_manifest: wrote ${output.path}');
  } on Object catch (error) {
    stderr.writeln('release_manifest: $error');
    exitCode = 1;
  }
}
