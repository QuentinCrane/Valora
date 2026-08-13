import 'dart:convert';
import 'dart:io';

class _LockedPackage {
  final String name;
  String? dependency;
  String? source;
  String? version;

  _LockedPackage(this.name);
}

List<String> _directDependencies(String content) {
  final names = <String>[];
  var inDependencyBlock = false;
  for (final line in content.split(RegExp(r'\r?\n'))) {
    if (line == 'dependencies:' || line == 'dev_dependencies:') {
      inDependencyBlock = true;
      continue;
    }
    if (inDependencyBlock && line.isNotEmpty && !line.startsWith(' ')) {
      inDependencyBlock = false;
    }
    if (!inDependencyBlock) continue;
    final match = RegExp(r'^  ([A-Za-z0-9_-]+):').firstMatch(line);
    if (match != null) names.add(match.group(1)!);
  }
  return names;
}

List<_LockedPackage> _lockedPackages(String content) {
  final packages = <_LockedPackage>[];
  var inPackages = false;
  _LockedPackage? current;
  for (final line in content.split(RegExp(r'\r?\n'))) {
    if (line == 'packages:') {
      inPackages = true;
      continue;
    }
    if (!inPackages) continue;
    final packageMatch = RegExp(r'^  ([^:]+):$').firstMatch(line);
    if (packageMatch != null) {
      current = _LockedPackage(packageMatch.group(1)!);
      packages.add(current);
      continue;
    }
    if (current == null) continue;
    final dependencyMatch =
        RegExp(r'^\s+dependency:\s*["\x27]?([^"\x27]+)["\x27]?$')
            .firstMatch(line);
    if (dependencyMatch != null) {
      current.dependency = dependencyMatch.group(1);
      continue;
    }
    final sourceMatch =
        RegExp(r'^\s+source:\s*["\x27]?([^"\x27]+)["\x27]?$').firstMatch(line);
    if (sourceMatch != null) {
      current.source = sourceMatch.group(1);
      continue;
    }
    final versionMatch =
        RegExp(r'^\s+version:\s*["\x27]?([^"\x27]+)["\x27]?$').firstMatch(line);
    if (versionMatch != null) current.version = versionMatch.group(1);
  }
  return packages;
}

String _pubspecVersion(String content) {
  final match = RegExp(r'^version:\s*([^\s+]+)\+(\d+)', multiLine: true)
      .firstMatch(content);
  if (match == null) throw const FormatException('pubspec version is missing');
  return '${match.group(1)}+${match.group(2)}';
}

void main() {
  final pubspec = File('pubspec.yaml');
  final lockfile = File('pubspec.lock');
  final notices = File('THIRD_PARTY_NOTICES.md');
  if (!pubspec.existsSync() ||
      !lockfile.existsSync() ||
      !notices.existsSync()) {
    stderr.writeln(
        'supply_chain: pubspec.yaml, pubspec.lock, and THIRD_PARTY_NOTICES.md are required');
    exitCode = 1;
    return;
  }

  final directNames = _directDependencies(pubspec.readAsStringSync());
  final locked = _lockedPackages(lockfile.readAsStringSync());
  final byName = <String, _LockedPackage>{
    for (final package in locked) package.name: package,
  };
  final noticesText = notices.readAsStringSync();
  final missingNotices = <String>[];
  for (final name in directNames) {
    final package = byName[name];
    if (package == null) {
      missingNotices.add('$name (missing from pubspec.lock)');
    } else if (package.source == 'hosted' && !noticesText.contains('`$name`')) {
      missingNotices.add(name);
    }
  }
  if (missingNotices.isNotEmpty) {
    stderr.writeln(
        'supply_chain: direct hosted packages missing notices: ${missingNotices.join(', ')}');
    exitCode = 1;
    return;
  }

  final hostedPackages = locked
      .where((package) => package.source == 'hosted' && package.version != null)
      .map((package) => <String, Object?>{
            'type': 'library',
            'name': package.name,
            'version': package.version,
            'group': 'pub.dev',
            'purl': 'pkg:pub/${package.name}@${package.version}',
            'properties': [
              {
                'name': 'valora:dependency-scope',
                'value': package.dependency ?? 'unknown',
              },
            ],
          })
      .toList();
  final bom = <String, Object?>{
    'bomFormat': 'CycloneDX',
    'specVersion': '1.5',
    'version': 1,
    'metadata': {
      'timestamp': DateTime.now().toUtc().toIso8601String(),
      'component': {
        'type': 'application',
        'name': 'valora_assets',
        'version': _pubspecVersion(pubspec.readAsStringSync()),
      },
    },
    'components': hostedPackages,
  };

  final output = File('build/release/valora-pub-sbom.json');
  output.parent.createSync(recursive: true);
  final encoded = const JsonEncoder.withIndent('  ').convert(bom);
  output.writeAsStringSync('$encoded\n');
  stdout.writeln(
      'supply_chain: verified ${directNames.length} direct dependency declarations');
  stdout.writeln(
      'supply_chain: wrote ${hostedPackages.length} hosted packages to ${output.path}');
}
