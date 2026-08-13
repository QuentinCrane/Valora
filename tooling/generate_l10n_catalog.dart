import 'dart:convert';
import 'dart:io';

String _dartString(String value) => jsonEncode(value).replaceAll(r'$', r'\$');

Map<String, String> _readArb(String path, String expectedLocale) {
  final data =
      jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;
  if (data['@@locale'] != expectedLocale) {
    throw StateError('$path has unexpected @@locale ${data['@@locale']}');
  }
  return <String, String>{
    for (final entry in data.entries)
      if (!entry.key.startsWith('@') && entry.key != '@@locale')
        entry.key: entry.value as String,
  };
}

Map<String, String> _mapFromManifest(
  Map<String, dynamic> manifest,
  String section,
  Map<String, String> arb,
) {
  final result = <String, String>{};
  final ids = manifest[section] as Map<String, dynamic>;
  for (final entry in ids.entries) {
    final id = entry.value as String;
    final value = arb[id];
    if (value == null) {
      throw StateError('Missing ARB resource $id for ${entry.key}');
    }
    result[entry.key] = value;
  }
  return result;
}

String _mapLiteral(Map<String, String> values) {
  final buffer = StringBuffer('<String, String>{\n');
  for (final entry in values.entries) {
    buffer.writeln('  ${_dartString(entry.key)}: ${_dartString(entry.value)},');
  }
  buffer.write('}');
  return buffer.toString();
}

void main() {
  final root = Directory.current;
  final l10n = Directory('${root.path}/lib/l10n');
  final manifest = jsonDecode(
    File('${l10n.path}/message_keys.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final arb = <String, Map<String, String>>{
    'zh_Hans': _readArb('${l10n.path}/app_zh_Hans.arb', 'zh_Hans'),
    'zh_Hant': _readArb('${l10n.path}/app_zh_Hant.arb', 'zh_Hant'),
    'en': _readArb('${l10n.path}/app_en.arb', 'en'),
  };
  final expectedIds = <String>{
    ...((manifest['messages'] as Map<String, dynamic>).values.cast<String>()),
    ...((manifest['literals'] as Map<String, dynamic>).values.cast<String>()),
  };
  for (final entry in arb.entries) {
    if (!expectedIds.containsAll(entry.value.keys) ||
        !entry.value.keys.toSet().containsAll(expectedIds)) {
      throw StateError('ARB key sets are not aligned for ${entry.key}');
    }
  }
  final messages = <String, Map<String, String>>{
    for (final locale in arb.keys)
      locale: _mapFromManifest(manifest, 'messages', arb[locale]!),
  };
  final literals = <String, Map<String, String>>{
    for (final locale in arb.keys)
      locale: _mapFromManifest(manifest, 'literals', arb[locale]!),
  };
  final output = '''// GENERATED CODE - DO NOT MODIFY BY HAND.
// Source: lib/l10n/*.arb

const _zhHansMessages = ${_mapLiteral(messages['zh_Hans']!)};
const _zhHantMessages = ${_mapLiteral(messages['zh_Hant']!)};
const _enMessages = ${_mapLiteral(messages['en']!)};

const _zhHansLiterals = ${_mapLiteral(literals['zh_Hans']!)};
const _zhHantLiterals = ${_mapLiteral(literals['zh_Hant']!)};
const _enLiterals = ${_mapLiteral(literals['en']!)};

String? valoraMessageFor(String localeKey, String key) {
  final messages = switch (localeKey) {
    'en' => _enMessages,
    'zh_Hant' => _zhHantMessages,
    _ => _zhHansMessages,
  };
  return messages[key];
}

String? valoraLiteralFor(String localeKey, String text) {
  final messages = switch (localeKey) {
    'en' => _enLiterals,
    'zh_Hant' => _zhHantLiterals,
    _ => _zhHansLiterals,
  };
  return messages[text];
}
''';
  final outputFile = File('${l10n.path}/generated/valora_message_catalog.dart');
  outputFile.writeAsStringSync(output);
  stdout.writeln(
    'Generated ${messages['en']!.length} messages and ${literals['en']!.length} literals for 3 locales.',
  );
}
