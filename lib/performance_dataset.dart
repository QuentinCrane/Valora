import 'dart:convert';

enum ValoraBenchmarkScale { empty, small, medium, large }

extension ValoraBenchmarkScaleX on ValoraBenchmarkScale {
  int get assetCount {
    switch (this) {
      case ValoraBenchmarkScale.empty:
        return 0;
      case ValoraBenchmarkScale.small:
        return 50;
      case ValoraBenchmarkScale.medium:
        return 500;
      case ValoraBenchmarkScale.large:
        return 2000;
    }
  }

  int get mediaCount {
    switch (this) {
      case ValoraBenchmarkScale.empty:
        return 0;
      case ValoraBenchmarkScale.small:
        return 100;
      case ValoraBenchmarkScale.medium:
      case ValoraBenchmarkScale.large:
        return 500;
    }
  }

  int? get archiveTargetBytes {
    switch (this) {
      case ValoraBenchmarkScale.empty:
        return null;
      case ValoraBenchmarkScale.small:
      case ValoraBenchmarkScale.medium:
        return 10 * 1024 * 1024;
      case ValoraBenchmarkScale.large:
        return 100 * 1024 * 1024;
    }
  }
}

class ValoraPerformanceDataset {
  static const int defaultSeed = 0x56414c52;
  static final DateTime baseDate = DateTime.utc(2026, 1, 1);

  final ValoraBenchmarkScale scale;
  final int seed;

  ValoraPerformanceDataset({
    required this.scale,
    this.seed = defaultSeed,
  });

  int get assetCount => scale.assetCount;
  int get mediaCount => scale.mediaCount;

  late final List<Map<String, dynamic>> _assets = _buildAssets();
  late final List<Map<String, dynamic>> _wishes = _buildWishes();

  Map<String, dynamic> toPersistedMap() => {
        'storageSchemaVersion': 1,
        'exportSchemaVersion': 3,
        'version': 3,
        'appVersion': '0.80.1+81',
        'generatedBy': 'valora-performance-benchmark',
        'settings': {
          'onboardingCompleted': true,
          'glassEffectMode': 'classic',
          'language': 'zhHant',
        },
        'categories': _buildCategories(),
        'tags': _buildTags(),
        'assets': _assets,
        'wishes': _wishes,
        'recoveryRecords': const <Map<String, dynamic>>[],
        'reminders': const <Map<String, dynamic>>[],
        'snapshots': const <Map<String, dynamic>>[],
        'benchmark': {
          'seed': seed,
          'scale': scale.name,
          'assetCount': assetCount,
          'mediaCount': mediaCount,
        },
        'benchmarkMedia': List<Map<String, dynamic>>.generate(
          mediaCount,
          (index) => {
            'id': 'media-$index',
            'relativePath': 'media/placeholder-$index.bin',
            'bytes': 2048,
          },
        ),
      };

  String toJson({int? targetBytes}) {
    final data = toPersistedMap();
    var json = jsonEncode(data);
    if (targetBytes == null || targetBytes <= utf8.encode(json).length) {
      return json;
    }

    final currentBytes = utf8.encode(json).length;
    data['benchmarkPadding'] = 'x' * (targetBytes - currentBytes + 32);
    json = jsonEncode(data);
    while (utf8.encode(json).length < targetBytes) {
      data['benchmarkPadding'] =
          '${data['benchmarkPadding'] as String}xxxxxxxx';
      json = jsonEncode(data);
    }
    return json;
  }

  List<Map<String, dynamic>> _buildCategories() {
    return List<Map<String, dynamic>>.generate(8, (index) {
      final date = _dateTimeText(baseDate.add(Duration(minutes: index)));
      return {
        'id': 'category-$index',
        'name': 'Benchmark category $index',
        'icon': index.isEven ? '📦' : '🧰',
        'color': index.isEven ? '#7CC6F2' : '#B7A6FF',
        'sortOrder': index,
        'createdAt': date,
        'updatedAt': date,
      };
    });
  }

  List<Map<String, dynamic>> _buildTags() {
    return List<Map<String, dynamic>>.generate(16, (index) {
      final date = _dateTimeText(baseDate.add(Duration(minutes: index)));
      return {
        'id': 'tag-$index',
        'name': 'benchmark-$index',
        'color': index.isEven ? '#7CC6F2' : '#FFB7A6',
        'sortOrder': index,
        'createdAt': date,
        'updatedAt': date,
      };
    });
  }

  List<Map<String, dynamic>> _buildAssets() {
    final random = _DeterministicSequence(seed);
    return List<Map<String, dynamic>>.generate(assetCount, (index) {
      final purchaseDate = baseDate.subtract(
          Duration(days: 1 + random.nextInt(720), hours: random.nextInt(24)));
      final priceless = index % 23 == 0;
      final status = priceless
          ? (index % 2 == 0 ? 'serving' : 'retired')
          : index % 17 == 0
              ? 'sold'
              : index % 11 == 0
                  ? 'retired'
                  : 'serving';
      final lifecycleDate = purchaseDate.add(
          Duration(days: 1 + random.nextInt(120), hours: random.nextInt(12)));
      final price = priceless ? 0.0 : 40.0 + random.nextInt(4000);
      final tags = <String>['tag-${random.nextInt(16)}'];
      if (index % 5 == 0) tags.add('tag-${random.nextInt(16)}');
      final addons = index % 7 == 0
          ? [
              {
                'id': 'addon-$index-0',
                'name': 'Benchmark add-on',
                'price': priceless ? 0 : 8 + random.nextInt(180),
                'purchaseDate': _ymd(purchaseDate),
                'purchaseDateYmd': _ymd(purchaseDate),
                'followParentPurchaseDate': true,
                'includeInTotal': true,
                'includeInDailyCost': index.isEven,
              }
            ]
          : const <Map<String, dynamic>>[];
      return {
        'id': 'asset-$index',
        'name': 'Benchmark asset $index',
        'iconValue': index.isEven ? '📦' : '🎧',
        'valueMode': priceless ? 'priceless' : 'priced',
        'isPriceless': priceless,
        'price': price,
        'purchaseDate': _ymd(purchaseDate),
        'purchaseDateYmd': _ymd(purchaseDate),
        'categoryId': 'category-${index % 8}',
        'tagIds': tags,
        'addons': addons,
        'note': 'Benchmark note $index',
        'status': status,
        'includeInTotal': !priceless,
        'includeInDailyCost': !priceless,
        'retiredAt': status == 'retired' ? _ymd(lifecycleDate) : null,
        'soldAt': status == 'sold' ? _ymd(lifecycleDate) : null,
        'soldPrice': status == 'sold' ? price * .72 : null,
        'targetMode': 'none',
        'targetDailyCost': null,
        'targetDate': null,
        'targetCustomDays': null,
        'expiresAt': null,
        'remindBeforeDays': null,
        'createdAt': _dateTimeText(purchaseDate),
        'updatedAt': _dateTimeText(purchaseDate.add(const Duration(hours: 1))),
      };
    });
  }

  List<Map<String, dynamic>> _buildWishes() {
    final random = _DeterministicSequence(seed ^ 0x13579bdf);
    final count = assetCount ~/ 10;
    return List<Map<String, dynamic>>.generate(count, (index) {
      final created = baseDate.subtract(Duration(days: random.nextInt(365)));
      return {
        'id': 'wish-$index',
        'name': 'Benchmark wish $index',
        'iconValue': '✨',
        'expectedPrice': 100 + random.nextInt(2500),
        'note': 'Benchmark wish note $index',
        'categoryId': 'category-${index % 8}',
        'tagIds': ['tag-${index % 16}'],
        'archived': index % 9 == 0,
        'convertedAt': null,
        'convertedAssetId': null,
        'addons': const <Map<String, dynamic>>[],
        'createdAt': _dateTimeText(created),
        'updatedAt': _dateTimeText(created.add(const Duration(hours: 1))),
      };
    });
  }
}

class _DeterministicSequence {
  int _state;

  _DeterministicSequence(int seed) : _state = seed & 0x7fffffff;

  int nextInt(int maximum) {
    _state = (_state * 1664525 + 1013904223) & 0x7fffffff;
    return _state % maximum;
  }
}

String _ymd(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '$year-$month-$day';
}

String _dateTimeText(DateTime value) => value.toUtc().toIso8601String();
