part of '../main.dart';

const String kUncategorizedAnalyticsKey = '__valora_uncategorized__';

class AssetInsight {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const AssetInsight(
      {required this.icon,
      required this.title,
      required this.description,
      required this.color});
}

class AssetLeakItem {
  final Asset asset;
  final String reason;
  final String suggestion;
  final double score;

  const AssetLeakItem(
      {required this.asset,
      required this.reason,
      required this.suggestion,
      required this.score});
}

class AssetTrendPoint {
  final String label;
  final double value;

  const AssetTrendPoint({required this.label, required this.value});
}

class LifecycleEventItem {
  final DateTime date;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String sortKey;

  const LifecycleEventItem(
      {required this.date,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.color,
      this.sortKey = ''});
}

class DestructiveImpact {
  final int targetCount;
  final int affectedAssets;
  final int affectedWishes;
  final int affectedCategories;
  final int affectedTags;
  final int affectedRecoveryRecords;
  final int affectedSnapshots;

  const DestructiveImpact({
    this.targetCount = 0,
    this.affectedAssets = 0,
    this.affectedWishes = 0,
    this.affectedCategories = 0,
    this.affectedTags = 0,
    this.affectedRecoveryRecords = 0,
    this.affectedSnapshots = 0,
  });

  bool get isEmpty =>
      targetCount == 0 &&
      affectedAssets == 0 &&
      affectedWishes == 0 &&
      affectedCategories == 0 &&
      affectedTags == 0 &&
      affectedRecoveryRecords == 0 &&
      affectedSnapshots == 0;
}

class SnapshotPreview {
  final bool isValid;
  final int assets;
  final int wishes;
  final int categories;
  final int tags;
  final int recoveryRecords;

  const SnapshotPreview({
    required this.isValid,
    this.assets = 0,
    this.wishes = 0,
    this.categories = 0,
    this.tags = 0,
    this.recoveryRecords = 0,
  });
}

class AnalyticsSnapshot {
  final double totalAssetValue;
  final double averageDailyCost;
  final double totalPurchaseCost;
  final double wishBudget;
  final double lifecycleNetConsumption;
  final double lifecycleRecoveredValue;
  final Map<String, double> categoryDistribution;
  final Map<String, int> tagDistribution;
  final List<Asset> topDailyAssets;
  final List<AssetTrendPoint> valueTrend;
  final List<AssetTrendPoint> dailyCostTrend;
  final List<AssetInsight> insights;

  const AnalyticsSnapshot({
    required this.totalAssetValue,
    required this.averageDailyCost,
    required this.totalPurchaseCost,
    required this.wishBudget,
    required this.lifecycleNetConsumption,
    required this.lifecycleRecoveredValue,
    required this.categoryDistribution,
    required this.tagDistribution,
    required this.topDailyAssets,
    required this.valueTrend,
    required this.dailyCostTrend,
    required this.insights,
  });
}

enum StorageLoadStatus {
  empty,
  success,
  recoverableFailure,
  fatalFailure,
}

class StorageLoadResult {
  final StorageLoadStatus status;
  final String? payload;
  final String? lastValidatedPayload;
  final String? errorCode;
  final String? errorMessage;

  const StorageLoadResult({
    required this.status,
    this.payload,
    this.lastValidatedPayload,
    this.errorCode,
    this.errorMessage,
  });

  const StorageLoadResult.empty({String? lastValidatedPayload})
      : this(
          status: StorageLoadStatus.empty,
          lastValidatedPayload: lastValidatedPayload,
        );

  const StorageLoadResult.success({
    required String payload,
    String? lastValidatedPayload,
  }) : this(
          status: StorageLoadStatus.success,
          payload: payload,
          lastValidatedPayload: lastValidatedPayload,
        );

  const StorageLoadResult.recoverableFailure({
    required String errorCode,
    String? errorMessage,
    String? lastValidatedPayload,
  }) : this(
          status: StorageLoadStatus.recoverableFailure,
          errorCode: errorCode,
          errorMessage: errorMessage,
          lastValidatedPayload: lastValidatedPayload,
        );

  const StorageLoadResult.fatalFailure({
    required String errorCode,
    String? errorMessage,
    String? lastValidatedPayload,
  }) : this(
          status: StorageLoadStatus.fatalFailure,
          errorCode: errorCode,
          errorMessage: errorMessage,
          lastValidatedPayload: lastValidatedPayload,
        );

  bool get isFailure =>
      status == StorageLoadStatus.recoverableFailure ||
      status == StorageLoadStatus.fatalFailure;

  bool get hasValidatedSnapshot =>
      lastValidatedPayload != null && lastValidatedPayload!.trim().isNotEmpty;
}

enum PersistenceSaveKind { crud, settings, system }

enum PersistenceStatus { idle, saving, saved, failed }

class PersistenceSaveState {
  final PersistenceStatus status;
  final int revision;
  final int persistedRevision;
  final int? activeRevision;
  final int? failedRevision;
  final String? error;

  const PersistenceSaveState({
    required this.status,
    required this.revision,
    required this.persistedRevision,
    this.activeRevision,
    this.failedRevision,
    this.error,
  });

  const PersistenceSaveState.idle()
      : this(
          status: PersistenceStatus.idle,
          revision: 0,
          persistedRevision: 0,
        );

  bool get isSaving => status == PersistenceStatus.saving;
  bool get isFailed => status == PersistenceStatus.failed;
  bool get isSettled => status == PersistenceStatus.saved;
}

class PersistenceSaveTicket {
  final int revision;
  final Future<void> completion;

  const PersistenceSaveTicket({
    required this.revision,
    required this.completion,
  });
}

typedef PersistenceWriter = Future<void> Function(
  int revision,
  String snapshot,
);

class _PendingPersistenceSave {
  final int revision;
  final String snapshot;
  final PersistenceSaveKind kind;
  final List<Completer<void>> waiters;

  const _PendingPersistenceSave({
    required this.revision,
    required this.snapshot,
    required this.kind,
    required this.waiters,
  });
}

class SaveCoordinator {
  final PersistenceWriter _writer;
  final ValueChanged<PersistenceSaveState>? onStateChanged;
  final List<_PendingPersistenceSave> _queue = [];

  PersistenceSaveState _state = const PersistenceSaveState.idle();
  _PendingPersistenceSave? _lastFailed;
  int _revision = 0;
  int _persistedRevision = 0;
  int? _activeRevision;
  bool _draining = false;

  SaveCoordinator({required PersistenceWriter writer, this.onStateChanged})
      : _writer = writer;

  PersistenceSaveState get state => _state;
  int get revision => _revision;
  int get persistedRevision => _persistedRevision;

  PersistenceSaveTicket enqueue(
    String snapshot, {
    PersistenceSaveKind kind = PersistenceSaveKind.crud,
  }) {
    final revision = ++_revision;
    final waiter = Completer<void>();
    final pending = _PendingPersistenceSave(
      revision: revision,
      snapshot: snapshot,
      kind: kind,
      waiters: [waiter],
    );
    if (kind == PersistenceSaveKind.settings &&
        _queue.isNotEmpty &&
        _queue.last.kind == PersistenceSaveKind.settings) {
      final previous = _queue.removeLast();
      _queue.add(
        _PendingPersistenceSave(
          revision: revision,
          snapshot: snapshot,
          kind: kind,
          waiters: [...previous.waiters, waiter],
        ),
      );
    } else {
      _queue.add(pending);
    }
    _emit(
      PersistenceStatus.saving,
      activeRevision: _activeRevision ?? revision,
    );
    if (!_draining) unawaited(_drain());
    return PersistenceSaveTicket(
      revision: revision,
      completion: waiter.future,
    );
  }

  PersistenceSaveTicket? retryLastFailed() {
    final failed = _lastFailed;
    if (failed == null) return null;
    _lastFailed = null;
    return enqueue(failed.snapshot, kind: failed.kind);
  }

  Future<void> _drain() async {
    if (_draining) return;
    _draining = true;
    try {
      while (_queue.isNotEmpty) {
        final pending = _queue.removeAt(0);
        _activeRevision = pending.revision;
        _emit(
          PersistenceStatus.saving,
          activeRevision: pending.revision,
        );
        try {
          await _writer(pending.revision, pending.snapshot);
          _persistedRevision = pending.revision;
          if ((_lastFailed?.revision ?? 0) <= pending.revision) {
            _lastFailed = null;
          }
          for (final waiter in pending.waiters) {
            if (!waiter.isCompleted) waiter.complete();
          }
          _emit(
            _queue.isEmpty ? PersistenceStatus.saved : PersistenceStatus.saving,
            activeRevision: _queue.isEmpty ? null : pending.revision,
          );
        } catch (error, stackTrace) {
          _lastFailed = pending;
          for (final waiter in pending.waiters) {
            if (!waiter.isCompleted) {
              waiter.completeError(error, stackTrace);
            }
          }
          _emit(
            PersistenceStatus.failed,
            failedRevision: pending.revision,
            error: error.toString(),
          );
        } finally {
          _activeRevision = null;
        }
      }
    } finally {
      _draining = false;
    }
  }

  void _emit(
    PersistenceStatus status, {
    int? activeRevision,
    int? failedRevision,
    String? error,
  }) {
    _state = PersistenceSaveState(
      status: status,
      revision: _revision,
      persistedRevision: _persistedRevision,
      activeRevision: activeRevision,
      failedRevision: failedRevision,
      error: error,
    );
    onStateChanged?.call(_state);
  }
}

class StoredCloudCredentials {
  final String username;
  final String password;

  const StoredCloudCredentials(
      {required this.username, required this.password});

  bool get hasValues =>
      username.trim().isNotEmpty || password.trim().isNotEmpty;
}

class SecureCredentialLoadResult {
  final bool ok;
  final StoredCloudCredentials? credentials;
  final String? errorCode;

  const SecureCredentialLoadResult._({
    required this.ok,
    this.credentials,
    this.errorCode,
  });

  const SecureCredentialLoadResult.empty() : this._(ok: true);

  const SecureCredentialLoadResult.success(StoredCloudCredentials credentials)
      : this._(ok: true, credentials: credentials);

  const SecureCredentialLoadResult.failure(String errorCode)
      : this._(ok: false, errorCode: errorCode);
}

const int kCurrentStorageSchemaVersion = 1;
const int kCurrentExportSchemaVersion = 3;
const String kValoraAppVersion = '0.80.1+81';

class PersistedDataException implements Exception {
  final String code;
  final String message;

  const PersistedDataException(this.code, this.message);

  @override
  String toString() => '$code: $message';
}

Map<String, dynamic> migratePersistedMap(Map<String, dynamic> input) {
  final data = _deepCopyPersistedMap(input);
  final storageVersion = _readSchemaVersion(
    data['storageSchemaVersion'],
    fallback: 1,
    field: 'storageSchemaVersion',
  );
  final legacyVersion = data['version'] == null
      ? null
      : _readSchemaVersion(
          data['version'],
          fallback: 1,
          field: 'version',
        );
  final exportVersion = _readSchemaVersion(
    data['exportSchemaVersion'] ?? legacyVersion,
    fallback: 1,
    field: 'exportSchemaVersion',
  );

  if (storageVersion > kCurrentStorageSchemaVersion ||
      (legacyVersion ?? exportVersion) > kCurrentExportSchemaVersion ||
      exportVersion > kCurrentExportSchemaVersion) {
    throw const PersistedDataException(
      'data_future_schema',
      'Persisted data was written by a newer Valora schema',
    );
  }
  if (storageVersion < 1 || exportVersion < 1) {
    throw const PersistedDataException(
      'data_invalid_schema',
      'Persisted data schema versions must be positive integers',
    );
  }

  _ensurePersistedCollections(data);
  _ensurePersistedSettings(data);
  _canonicalizePersistedDates(data);

  data['storageSchemaVersion'] = kCurrentStorageSchemaVersion;
  data['exportSchemaVersion'] = kCurrentExportSchemaVersion;
  // Keep the old field as a compatibility alias for older importers.
  data['version'] = kCurrentExportSchemaVersion;
  data['appVersion'] = kValoraAppVersion;
  data['generatedBy'] = data['generatedBy']?.toString() ?? 'valora-flutter';

  _validatePersistedData(data);
  return data;
}

int _readSchemaVersion(
  Object? raw, {
  required int fallback,
  required String field,
}) {
  if (raw == null) return fallback;
  final value = raw is num
      ? (raw == raw.toInt() ? raw.toInt() : null)
      : int.tryParse(raw.toString().trim());
  if (value == null || value < 1) {
    throw PersistedDataException(
      'data_invalid_schema',
      '$field must be a positive integer',
    );
  }
  return value;
}

Map<String, dynamic> _deepCopyPersistedMap(Map<dynamic, dynamic> source) {
  final result = <String, dynamic>{};
  for (final entry in source.entries) {
    if (entry.key is! String) {
      throw const PersistedDataException(
        'data_invalid_object',
        'Persisted object keys must be strings',
      );
    }
    result[entry.key as String] = _deepCopyPersistedValue(entry.value);
  }
  return result;
}

dynamic _deepCopyPersistedValue(dynamic value) {
  if (value is Map) return _deepCopyPersistedMap(value);
  if (value is List) {
    return value.map(_deepCopyPersistedValue).toList();
  }
  return value;
}

void _ensurePersistedCollections(Map<String, dynamic> data) {
  const collectionKeys = [
    'categories',
    'tags',
    'assets',
    'wishes',
    'recoveryRecords',
    'reminders',
    'snapshots',
  ];
  for (final key in collectionKeys) {
    final value = data[key];
    if (value == null) {
      data[key] = <dynamic>[];
    } else if (value is! List) {
      throw PersistedDataException(
        'data_invalid_collection',
        '$key must be an array',
      );
    }
  }
}

void _ensurePersistedSettings(Map<String, dynamic> data) {
  final settings = data['settings'];
  if (settings == null) {
    const settingKeys = [
      'currencyUnit',
      'currency',
      'decimalPlaces',
      'useThousandsSeparator',
      'durationMode',
      'theme',
      'darkMode',
      'language',
      'includeRetiredInTotal',
      'reminderEnabled',
      'hapticsEnabled',
      'nativeHapticsEnabled',
      'compactSnackbars',
      'defaultHomeViewMode',
      'stickerEngineMode',
      'glassEffectMode',
      'liquidGlassSoftness',
      'keepStickerCandidates',
      'homeMetaFontScale',
      'onboardingCompleted',
      'cloudSync',
    ];
    data['settings'] = <String, dynamic>{
      for (final key in settingKeys)
        if (data.containsKey(key)) key: _deepCopyPersistedValue(data[key]),
    };
  } else if (settings is! Map) {
    throw const PersistedDataException(
      'data_invalid_settings',
      'settings must be an object',
    );
  }
}

void _canonicalizePersistedDates(Map<String, dynamic> data) {
  _normalizeRecordDates(data, 'categories', dateTimeFields: const [
    'createdAt',
    'updatedAt',
  ]);
  _normalizeRecordDates(data, 'tags', dateTimeFields: const [
    'createdAt',
    'updatedAt',
  ]);
  _normalizeRecordDates(
    data,
    'assets',
    dateTimeFields: const ['createdAt', 'updatedAt'],
    dateOnlyFields: const [
      'purchaseDate',
      'purchaseDateYmd',
      'retiredAt',
      'soldAt',
      'targetDate',
      'expiresAt',
    ],
  );
  _normalizeRecordDates(
    data,
    'wishes',
    dateTimeFields: const ['createdAt', 'updatedAt'],
    dateOnlyFields: const ['convertedAt'],
  );
  _normalizeRecordDates(
    data,
    'recoveryRecords',
    dateTimeFields: const ['createdAt', 'updatedAt'],
    dateOnlyFields: const ['date'],
  );
  _normalizeRecordDates(
    data,
    'reminders',
    dateTimeFields: const ['triggerAt', 'lastScheduledAt'],
    dateOnlyFields: const ['triggerDate'],
  );
  _normalizeSnapshotDates(data);

  final settings = Map<String, dynamic>.from(data['settings'] as Map);
  data['settings'] = settings;
  final cloud = settings['cloudSync'];
  if (cloud is Map) {
    final cloudMap = Map<String, dynamic>.from(cloud);
    _normalizeDateTimeField(cloudMap, 'lastUploadAt', 'cloudSync');
    _normalizeDateTimeField(cloudMap, 'lastDownloadAt', 'cloudSync');
    _normalizeDateTimeField(cloudMap, 'remoteLastModifiedAt', 'cloudSync');
    settings['cloudSync'] = cloudMap;
  }
}

void _normalizeRecordDates(
  Map<String, dynamic> data,
  String collection, {
  List<String> dateTimeFields = const [],
  List<String> dateOnlyFields = const [],
}) {
  final records = data[collection] as List;
  for (var index = 0; index < records.length; index++) {
    final value = records[index];
    if (value is! Map) {
      throw PersistedDataException(
        'data_invalid_record',
        '$collection[$index] must be an object',
      );
    }
    final record = Map<String, dynamic>.from(value);
    for (final field in dateTimeFields) {
      _normalizeDateTimeField(record, field, '$collection[$index]');
    }
    for (final field in dateOnlyFields) {
      _normalizeDateOnlyField(record, field, '$collection[$index]');
    }
    final addons = record['addons'];
    if (addons is List) {
      for (var addonIndex = 0; addonIndex < addons.length; addonIndex++) {
        final addon = addons[addonIndex];
        if (addon is! Map) {
          throw PersistedDataException(
            'data_invalid_record',
            '$collection[$index].addons[$addonIndex] must be an object',
          );
        }
        final addonMap = Map<String, dynamic>.from(addon);
        _normalizeDateOnlyField(addonMap, 'purchaseDate',
            '$collection[$index].addons[$addonIndex]');
        addons[addonIndex] = addonMap;
      }
    }
    records[index] = record;
  }
}

void _normalizeSnapshotDates(Map<String, dynamic> data) {
  final records = data['snapshots'] as List;
  for (var index = 0; index < records.length; index++) {
    final value = records[index];
    if (value is! Map) {
      throw PersistedDataException(
        'data_invalid_record',
        'snapshots[$index] must be an object',
      );
    }
    final record = Map<String, dynamic>.from(value);
    final raw = record['createdAtIso'] ??
        record['createdAt'] ??
        record['createdAtEpochMillis'];
    if (raw != null) {
      final parsed = parseOptionalPersistedDateTime(raw);
      if (parsed == null) {
        throw PersistedDataException(
          'data_invalid_timestamp',
          'snapshots[$index].createdAt is invalid',
        );
      }
      final canonical = dateTimeStorageText(parsed);
      record['createdAt'] = canonical;
      record['createdAtIso'] = canonical;
    }
    records[index] = record;
  }
}

void _normalizeDateTimeField(
    Map<String, dynamic> record, String field, String owner) {
  if (!record.containsKey(field) || record[field] == null) return;
  final parsed = parseOptionalPersistedDateTime(record[field]);
  if (parsed == null) {
    throw PersistedDataException(
      'data_invalid_timestamp',
      '$owner.$field is not a valid ISO-8601 timestamp',
    );
  }
  record[field] = dateTimeStorageText(parsed);
}

void _normalizeDateOnlyField(
    Map<String, dynamic> record, String field, String owner) {
  if (!record.containsKey(field) || record[field] == null) return;
  final parsed = parseOptionalPersistedDate(record[field]);
  if (parsed == null) {
    if (record[field].toString().trim().isEmpty) {
      record[field] = null;
      return;
    }
    throw PersistedDataException(
      'data_invalid_date',
      '$owner.$field is not a valid date-only value',
    );
  }
  record[field] = dateStorageText(parsed);
}

void _validatePersistedData(Map<String, dynamic> data) {
  final categories = _persistedRecords(data, 'categories');
  final tags = _persistedRecords(data, 'tags');
  final assets = _persistedRecords(data, 'assets');
  final wishes = _persistedRecords(data, 'wishes');
  final recoveryRecords = _persistedRecords(data, 'recoveryRecords');
  final reminders = _persistedRecords(data, 'reminders');
  final snapshots = _persistedRecords(data, 'snapshots');
  final categoryIds = _validatePrimaryKeys(categories, 'categories');
  final tagIds = _validatePrimaryKeys(tags, 'tags');
  final assetIds = _validatePrimaryKeys(assets, 'assets');
  _validatePrimaryKeys(wishes, 'wishes');
  _validatePrimaryKeys(recoveryRecords, 'recoveryRecords');
  _validatePrimaryKeys(reminders, 'reminders');
  _validatePrimaryKeys(snapshots, 'snapshots');

  for (var index = 0; index < categories.length; index++) {
    _validateDateFields(categories[index], 'categories[$index]',
        dateTimeFields: const ['createdAt', 'updatedAt']);
  }
  for (var index = 0; index < tags.length; index++) {
    _validateDateFields(tags[index], 'tags[$index]',
        dateTimeFields: const ['createdAt', 'updatedAt']);
  }
  for (var index = 0; index < assets.length; index++) {
    final asset = assets[index];
    _validateEnum(asset, 'valueMode', AssetValueMode.values, 'assets[$index]');
    _validateEnum(asset, 'status', AssetStatus.values, 'assets[$index]');
    _validateEnum(asset, 'targetMode', TargetMode.values, 'assets[$index]');
    _validateDateFields(
      asset,
      'assets[$index]',
      dateTimeFields: const ['createdAt', 'updatedAt'],
      dateOnlyFields: const [
        'purchaseDate',
        'purchaseDateYmd',
        'retiredAt',
        'soldAt',
        'targetDate',
        'expiresAt',
      ],
    );
    _validateOptionalReference(
        asset, 'categoryId', categoryIds, 'assets[$index]');
    _validateReferences(asset, 'tagIds', tagIds, 'assets[$index]');
    _validateAddons(asset, 'assets[$index]');
  }
  for (var index = 0; index < wishes.length; index++) {
    final wish = wishes[index];
    _validateDateFields(
      wish,
      'wishes[$index]',
      dateTimeFields: const ['createdAt', 'updatedAt'],
      dateOnlyFields: const ['convertedAt'],
    );
    _validateOptionalReference(
        wish, 'categoryId', categoryIds, 'wishes[$index]');
    _validateReferences(wish, 'tagIds', tagIds, 'wishes[$index]');
    _validateOptionalReference(
        wish, 'convertedAssetId', assetIds, 'wishes[$index]');
    _validateAddons(wish, 'wishes[$index]');
  }
  for (var index = 0; index < recoveryRecords.length; index++) {
    final record = recoveryRecords[index];
    _validateDateFields(record, 'recoveryRecords[$index]',
        dateTimeFields: const ['createdAt', 'updatedAt'],
        dateOnlyFields: const ['date']);
    _validateReferences(
        record, 'assetIds', assetIds, 'recoveryRecords[$index]');
  }
  for (var index = 0; index < reminders.length; index++) {
    _validateDateFields(reminders[index], 'reminders[$index]',
        dateTimeFields: const ['triggerAt', 'lastScheduledAt'],
        dateOnlyFields: const ['triggerDate']);
  }
  for (var index = 0; index < snapshots.length; index++) {
    _validateDateFields(snapshots[index], 'snapshots[$index]',
        dateTimeFields: const ['createdAt', 'createdAtIso']);
    final payload = snapshots[index]['payload'];
    if (payload != null && payload is! String) {
      throw PersistedDataException(
        'data_invalid_snapshot',
        'snapshots[$index].payload must be a string',
      );
    }
  }

  final settings = Map<String, dynamic>.from(data['settings'] as Map);
  _validateEnum(settings, 'durationMode', DurationMode.values, 'settings');
  _validateEnum(settings, 'theme', ThemeSetting.values, 'settings');
  _validateEnum(settings, 'language', AppLanguageSetting.values, 'settings');
  _validateEnum(
      settings, 'defaultHomeViewMode', HomeViewMode.values, 'settings');
  _validateEnum(
      settings, 'stickerEngineMode', StickerEngineMode.values, 'settings');
  _validateEnum(
      settings, 'glassEffectMode', GlassEffectMode.values, 'settings');
  final cloud = settings['cloudSync'];
  if (cloud != null) {
    if (cloud is! Map) {
      throw const PersistedDataException(
        'data_invalid_settings',
        'settings.cloudSync must be an object',
      );
    }
    final cloudMap = Map<String, dynamic>.from(cloud);
    _validateEnum(
        cloudMap, 'provider', CloudSyncProvider.values, 'settings.cloudSync');
    _validateDateFields(cloudMap, 'settings.cloudSync', dateTimeFields: const [
      'lastUploadAt',
      'lastDownloadAt',
      'remoteLastModifiedAt'
    ]);
  }
}

List<Map<String, dynamic>> _persistedRecords(
    Map<String, dynamic> data, String collection) {
  final records = data[collection];
  if (records is! List) {
    throw PersistedDataException(
        'data_invalid_collection', '$collection must be an array');
  }
  return records.map((value) {
    if (value is! Map) {
      throw PersistedDataException(
          'data_invalid_record', '$collection contains a non-object value');
    }
    return Map<String, dynamic>.from(value);
  }).toList();
}

Set<String> _validatePrimaryKeys(
    List<Map<String, dynamic>> records, String collection) {
  final ids = <String>{};
  for (var index = 0; index < records.length; index++) {
    final id = records[index]['id'];
    if (id is! String || id.trim().isEmpty) {
      throw PersistedDataException(
          'data_invalid_primary_key', '$collection[$index].id is required');
    }
    if (!ids.add(id)) {
      throw PersistedDataException('data_duplicate_primary_key',
          '$collection contains duplicate id $id');
    }
  }
  return ids;
}

void _validateEnum<T extends Enum>(
    Map<String, dynamic> record, String field, List<T> values, String owner) {
  final raw = record[field];
  if (raw == null) return;
  final value = raw.toString();
  if (!values.any((item) => item.name == value)) {
    throw PersistedDataException(
        'data_invalid_enum', '$owner.$field has unknown value $value');
  }
}

void _validateOptionalReference(
    Map<String, dynamic> record, String field, Set<String> ids, String owner) {
  final raw = record[field];
  if (raw == null) return;
  if (raw is! String || raw.trim().isEmpty || !ids.contains(raw)) {
    throw PersistedDataException(
        'data_invalid_reference', '$owner.$field points to a missing record');
  }
}

void _validateReferences(
    Map<String, dynamic> record, String field, Set<String> ids, String owner) {
  final raw = record[field];
  if (raw == null) return;
  if (raw is! List) {
    throw PersistedDataException(
        'data_invalid_reference', '$owner.$field must be an array');
  }
  for (final value in raw) {
    if (value is! String || value.trim().isEmpty || !ids.contains(value)) {
      throw PersistedDataException(
          'data_invalid_reference', '$owner.$field points to a missing record');
    }
  }
}

void _validateAddons(Map<String, dynamic> record, String owner) {
  final raw = record['addons'];
  if (raw == null) return;
  if (raw is! List) {
    throw PersistedDataException(
        'data_invalid_record', '$owner.addons must be an array');
  }
  final ids = <String>{};
  for (var index = 0; index < raw.length; index++) {
    final addon = raw[index];
    if (addon is! Map) {
      throw PersistedDataException(
          'data_invalid_record', '$owner.addons[$index] must be an object');
    }
    final addonMap = Map<String, dynamic>.from(addon);
    final id = addonMap['id'];
    if (id is! String || id.trim().isEmpty || !ids.add(id)) {
      throw PersistedDataException(
          'data_invalid_primary_key', '$owner.addons[$index].id is invalid');
    }
    _validateDateFields(addonMap, '$owner.addons[$index]',
        dateOnlyFields: const ['purchaseDate']);
  }
}

void _validateDateFields(
  Map<String, dynamic> record,
  String owner, {
  List<String> dateTimeFields = const [],
  List<String> dateOnlyFields = const [],
}) {
  for (final field in dateTimeFields) {
    final raw = record[field];
    if (raw == null) continue;
    if (raw is! String ||
        !raw.endsWith('Z') ||
        DateTime.tryParse(raw) == null) {
      throw PersistedDataException(
          'data_invalid_timestamp', '$owner.$field is not canonical ISO-8601');
    }
  }
  for (final field in dateOnlyFields) {
    final raw = record[field];
    if (raw == null) continue;
    if (raw is! String ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(raw) ||
        parseFlexibleDate(raw) == null) {
      throw PersistedDataException(
          'data_invalid_date', '$owner.$field is not a date-only value');
    }
  }
}

class LocalSqliteStorage {
  static const MethodChannel _channel = MethodChannel('valora/local_store');
  const LocalSqliteStorage();

  Future<StorageLoadResult> load() async {
    try {
      final response = await _channel.invokeMethod<Object?>('loadJson');
      if (response is String) {
        final payload = response;
        return payload.trim().isEmpty
            ? const StorageLoadResult.empty()
            : StorageLoadResult.success(payload: payload);
      }
      if (response is! Map) {
        return const StorageLoadResult.fatalFailure(
          errorCode: 'storage_invalid_response',
        );
      }
      final map = Map<Object?, Object?>.from(response);
      final status = map['status']?.toString();
      final payload = map['json']?.toString() ?? '';
      final lastValidatedPayload = map['lastValidatedJson']?.toString();
      switch (status) {
        case 'empty':
          return StorageLoadResult.empty(
            lastValidatedPayload: lastValidatedPayload,
          );
        case 'success':
          if (payload.trim().isEmpty) {
            return StorageLoadResult.fatalFailure(
              errorCode: 'storage_invalid_response',
              lastValidatedPayload: lastValidatedPayload,
            );
          }
          return StorageLoadResult.success(
            payload: payload,
            lastValidatedPayload: lastValidatedPayload,
          );
        default:
          return StorageLoadResult.fatalFailure(
            errorCode: 'storage_invalid_status',
            lastValidatedPayload: lastValidatedPayload,
          );
      }
    } on PlatformException catch (error) {
      return StorageLoadResult.fatalFailure(
        errorCode: error.code.isEmpty ? 'storage_read_failed' : error.code,
        errorMessage: error.message,
      );
    } on MissingPluginException catch (error) {
      return StorageLoadResult.fatalFailure(
        errorCode: 'storage_channel_unavailable',
        errorMessage: error.message,
      );
    } catch (error) {
      return StorageLoadResult.fatalFailure(
        errorCode: 'storage_read_failed',
        errorMessage: error.toString(),
      );
    }
  }

  Future<void> save(String json) async {
    try {
      final ok = await _channel.invokeMethod<bool>('saveJson', {'json': json});
      if (ok != true) {
        throw StateError(tr('store.localWriteFailed'));
      }
    } on PlatformException catch (error) {
      throw StateError('${tr('store.localWriteFailed')} (${error.code})');
    } on MissingPluginException {
      throw StateError(tr('store.localWriteFailed'));
    }
  }

  Future<void> markValidated(String json) async {
    try {
      final ok =
          await _channel.invokeMethod<bool>('markValidated', {'json': json});
      if (ok != true) {
        throw StateError(tr('store.localSnapshotFailed'));
      }
    } on PlatformException catch (error) {
      throw StateError('${tr('store.localSnapshotFailed')} (${error.code})');
    } on MissingPluginException {
      throw StateError(tr('store.localSnapshotFailed'));
    }
  }

  Future<SecureCredentialLoadResult> loadCredentials() async {
    try {
      final response = await _channel.invokeMethod<Object?>('loadCredentials');
      if (response is! Map) {
        return const SecureCredentialLoadResult.failure(
            'credentials_invalid_response');
      }
      final map = Map<Object?, Object?>.from(response);
      switch (map['status']?.toString()) {
        case 'empty':
          return const SecureCredentialLoadResult.empty();
        case 'success':
          return SecureCredentialLoadResult.success(StoredCloudCredentials(
            username: map['username']?.toString() ?? '',
            password: map['password']?.toString() ?? '',
          ));
        default:
          return const SecureCredentialLoadResult.failure(
              'credentials_invalid_status');
      }
    } on PlatformException catch (error) {
      return SecureCredentialLoadResult.failure(
          error.code.isEmpty ? 'credentials_read_failed' : error.code);
    } on MissingPluginException {
      return const SecureCredentialLoadResult.failure(
          'credentials_channel_unavailable');
    } catch (_) {
      return const SecureCredentialLoadResult.failure(
          'credentials_read_failed');
    }
  }

  Future<void> saveCredentials({
    required String username,
    required String password,
  }) async {
    try {
      final ok = await _channel.invokeMethod<bool>('saveCredentials', {
        'username': username,
        'password': password,
      });
      if (ok != true) throw StateError(tr('store.credentialsSaveFailed'));
    } on PlatformException catch (error) {
      throw StateError('${tr('store.credentialsSaveFailed')} (${error.code})');
    } on MissingPluginException {
      throw StateError(tr('store.credentialsSaveFailed'));
    }
  }

  Future<void> clearCredentials() async {
    try {
      final ok = await _channel.invokeMethod<bool>('clearCredentials');
      if (ok != true) throw StateError(tr('store.credentialsClearFailed'));
    } on PlatformException catch (error) {
      throw StateError('${tr('store.credentialsClearFailed')} (${error.code})');
    } on MissingPluginException {
      throw StateError(tr('store.credentialsClearFailed'));
    }
  }
}

class CloudSyncResult {
  final bool ok;
  final String message;
  final String? payload;
  final bool conflict;
  final bool skipped;
  final int? statusCode;
  final String? etag;
  final String? contentHash;
  final DateTime? remoteLastModifiedAt;
  final CloudRemoteSummary? remoteSummary;

  const CloudSyncResult({
    required this.ok,
    required this.message,
    this.payload,
    this.conflict = false,
    this.skipped = false,
    this.statusCode,
    this.etag,
    this.contentHash,
    this.remoteLastModifiedAt,
    this.remoteSummary,
  });
}

class CloudRemoteSummary {
  final int categories;
  final int tags;
  final int assets;
  final int wishes;
  final int recoveryRecords;
  final int bytes;
  final String contentHash;

  const CloudRemoteSummary({
    required this.categories,
    required this.tags,
    required this.assets,
    required this.wishes,
    required this.recoveryRecords,
    required this.bytes,
    required this.contentHash,
  });

  factory CloudRemoteSummary.fromJson(
      Map<String, dynamic> json, String contentHash, int bytes) {
    int count(String key) => json[key] is List ? (json[key] as List).length : 0;
    return CloudRemoteSummary(
      categories: count('categories'),
      tags: count('tags'),
      assets: count('assets'),
      wishes: count('wishes'),
      recoveryRecords: count('recoveryRecords'),
      bytes: bytes,
      contentHash: contentHash,
    );
  }
}

class CloudSyncConflict {
  final CloudSyncResult remoteResult;
  final CloudRemoteSummary localSummary;
  final DateTime detectedAt;

  const CloudSyncConflict({
    required this.remoteResult,
    required this.localSummary,
    required this.detectedAt,
  });
}

class _CloudHttpResponse {
  final int statusCode;
  final List<int> body;
  final String? etag;
  final DateTime? lastModifiedAt;

  const _CloudHttpResponse({
    required this.statusCode,
    required this.body,
    this.etag,
    this.lastModifiedAt,
  });
}

class _CloudSyncException implements Exception {
  final String message;
  const _CloudSyncException(this.message);

  @override
  String toString() => message;
}

class CloudSyncService {
  static const int maxPayloadBytes = 10 * 1024 * 1024;
  final bool allowInsecureLoopback;

  const CloudSyncService({this.allowInsecureLoopback = false});
  const CloudSyncService.test() : allowInsecureLoopback = true;

  Uri _buildUri(CloudSyncSettings settings, [String? overridePath]) {
    final rawBase = settings.serverUrl.trim();
    final parsedBase = Uri.parse(rawBase.endsWith('/') ? rawBase : '$rawBase/');
    _validateUri(parsedBase);
    final safePath = (overridePath ?? settings.remotePath)
        .trim()
        .replaceAll(RegExp(r'^/+'), '');
    if (safePath.isEmpty || safePath.contains('..')) {
      throw const _CloudSyncException('Remote path is invalid');
    }
    final resolved = parsedBase.resolve(safePath);
    _validateUri(resolved);
    return resolved;
  }

  void _validateUri(Uri uri) {
    final loopback =
        uri.host == '127.0.0.1' || uri.host == 'localhost' || uri.host == '::1';
    final allowedInsecure =
        allowInsecureLoopback && uri.scheme == 'http' && loopback;
    if ((uri.scheme != 'https' && !allowedInsecure) ||
        uri.host.trim().isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const _CloudSyncException(
          'WebDAV requires an HTTPS server URL without embedded credentials');
    }
  }

  String _basicAuth(CloudSyncSettings settings) {
    final token =
        base64Encode(utf8.encode('${settings.username}:${settings.password}'));
    return 'Basic $token';
  }

  Future<_CloudHttpResponse> _send(
      CloudSyncSettings settings, String method, Uri uri,
      {String? body,
      String contentType = 'application/json; charset=utf-8',
      Map<String, String> headers = const {}}) async {
    final bytes = body == null ? const <int>[] : utf8.encode(body);
    if (bytes.length > maxPayloadBytes) {
      throw const _CloudSyncException('Cloud payload exceeds the 10 MB limit');
    }
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 16)
      ..idleTimeout = const Duration(seconds: 28);
    try {
      final req = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 18));
      req.followRedirects = false;
      req.headers
          .set(HttpHeaders.userAgentHeader, 'Valora-Assets/1.0 Flutter WebDAV');
      if (settings.username.trim().isNotEmpty || settings.password.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, _basicAuth(settings));
      }
      headers.forEach(req.headers.set);
      if (body != null) {
        req.headers.set(HttpHeaders.contentTypeHeader, contentType);
        req.contentLength = bytes.length;
        req.add(bytes);
      }
      final resp = await req.close().timeout(const Duration(seconds: 28));
      if (resp.contentLength > maxPayloadBytes) {
        throw const _CloudSyncException(
            'Cloud response exceeds the 10 MB limit');
      }
      final responseBytes = <int>[];
      await for (final chunk in resp.timeout(const Duration(seconds: 28))) {
        responseBytes.addAll(chunk);
        if (responseBytes.length > maxPayloadBytes) {
          throw const _CloudSyncException(
              'Cloud response exceeds the 10 MB limit');
        }
      }
      return _CloudHttpResponse(
        statusCode: resp.statusCode,
        body: responseBytes,
        etag: resp.headers.value(HttpHeaders.etagHeader),
        lastModifiedAt:
            _parseHttpDate(resp.headers.value(HttpHeaders.lastModifiedHeader)),
      );
    } finally {
      client.close(force: true);
    }
  }

  DateTime? _parseHttpDate(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    return DateTime.tryParse(value)?.toUtc();
  }

  String _responseText(_CloudHttpResponse response) =>
      utf8.decode(response.body, allowMalformed: true).take(160);

  String _hashBytes(List<int> bytes) => sha256.convert(bytes).toString();

  String? _cleanEtag(String? value) {
    final clean = value?.trim();
    return clean == null || clean.isEmpty ? null : clean;
  }

  bool _sameEtag(String? left, String? right) =>
      left != null && right != null && left.trim() == right.trim();

  CloudRemoteSummary _summaryFromJson(
      Map<String, dynamic> json, String contentHash, int bytes) {
    return CloudRemoteSummary.fromJson(json, contentHash, bytes);
  }

  Future<void> _ensureWebDavFolders(CloudSyncSettings settings) async {
    final parts = settings.remotePath
        .split('/')
        .where((e) => e.trim().isNotEmpty)
        .toList();
    if (parts.length <= 1) return;
    var folder = '';
    for (var i = 0; i < parts.length - 1; i++) {
      folder = folder.isEmpty ? parts[i] : '$folder/${parts[i]}';
      final uri = _buildUri(settings, '$folder/');
      try {
        await _send(settings, 'MKCOL', uri);
      } catch (_) {
        // Many WebDAV servers return 405 if the collection already exists. Directory creation is best-effort.
      }
    }
  }

  Future<CloudSyncResult> test(CloudSyncSettings settings) async {
    if (!settings.enabled)
      return CloudSyncResult(ok: false, message: tr('store.cloudEnableFirst'));
    try {
      final root = Uri.parse(settings.serverUrl.trim().endsWith('/')
          ? settings.serverUrl.trim()
          : '${settings.serverUrl.trim()}/');
      _validateUri(root);
      final xml =
          '<?xml version="1.0" encoding="utf-8" ?><propfind xmlns="DAV:"><prop><displayname/></prop></propfind>';
      final resp = await _send(settings, 'PROPFIND', root,
          body: xml, contentType: 'application/xml; charset=utf-8');
      final ok = resp.statusCode == 207 ||
          resp.statusCode == 200 ||
          resp.statusCode == 301 ||
          resp.statusCode == 302;
      return CloudSyncResult(
          ok: ok,
          message: ok
              ? '${tr('store.cloudTestOk')}（HTTP ${resp.statusCode}）'
              : '${tr('store.cloudTestFail')}：HTTP ${resp.statusCode} ${_responseText(resp)}',
          statusCode: resp.statusCode);
    } catch (e) {
      return CloudSyncResult(
          ok: false, message: '${tr('store.connectFailed')}：$e');
    }
  }

  Future<CloudSyncResult> upload(
      CloudSyncSettings settings, String json) async {
    if (!settings.enabled)
      return CloudSyncResult(ok: false, message: tr('store.cloudConfigFirst'));
    try {
      final bytes = utf8.encode(json);
      final contentHash = _hashBytes(bytes);
      await _ensureWebDavFolders(settings);
      final uri = _buildUri(settings);
      _CloudHttpResponse? head;
      try {
        head = await _send(settings, 'HEAD', uri);
      } on _CloudSyncException {
        rethrow;
      }
      final headExists = head.statusCode >= 200 && head.statusCode < 400;
      final knownEtag = _cleanEtag(settings.remoteEtag);
      final headEtag = _cleanEtag(head.etag);
      if (headExists &&
          settings.remoteContentHash == contentHash &&
          (knownEtag == null || _sameEtag(knownEtag, headEtag))) {
        return CloudSyncResult(
          ok: true,
          skipped: true,
          message: tr('store.cloudNoChanges'),
          statusCode: head.statusCode,
          etag: headEtag ?? knownEtag,
          contentHash: contentHash,
          remoteLastModifiedAt: head.lastModifiedAt,
          remoteSummary: _summaryFromJson(
              Map<String, dynamic>.from(jsonDecode(json)),
              contentHash,
              bytes.length),
        );
      }

      final requestHeaders = <String, String>{};
      if (headExists) {
        if (knownEtag == null) {
          return CloudSyncResult(
            ok: false,
            conflict: true,
            message: tr('store.cloudConflict'),
            statusCode: head.statusCode,
            etag: headEtag,
            contentHash: contentHash,
            remoteLastModifiedAt: head.lastModifiedAt,
          );
        }
        if (headEtag != null && !_sameEtag(knownEtag, headEtag)) {
          return CloudSyncResult(
            ok: false,
            conflict: true,
            message: tr('store.cloudConflict'),
            statusCode: 412,
            etag: headEtag,
            contentHash: contentHash,
            remoteLastModifiedAt: head.lastModifiedAt,
          );
        }
        requestHeaders[HttpHeaders.ifMatchHeader] = knownEtag;
      } else {
        requestHeaders[HttpHeaders.ifNoneMatchHeader] = '*';
      }
      final resp = await _send(settings, 'PUT', uri,
          body: json, headers: requestHeaders);
      if (resp.statusCode == 409 || resp.statusCode == 412) {
        return CloudSyncResult(
          ok: false,
          conflict: true,
          message: tr('store.cloudConflict'),
          statusCode: resp.statusCode,
          etag: _cleanEtag(resp.etag) ?? headEtag,
          contentHash: contentHash,
          remoteLastModifiedAt: resp.lastModifiedAt ?? head.lastModifiedAt,
        );
      }
      final ok = resp.statusCode >= 200 && resp.statusCode < 300;
      return CloudSyncResult(
          ok: ok,
          message: ok
              ? '${tr('store.cloudUploaded')}：${settings.remotePath}'
              : '${tr('store.uploadFailed')}：HTTP ${resp.statusCode} ${_responseText(resp)}',
          statusCode: resp.statusCode,
          etag: _cleanEtag(resp.etag) ?? headEtag ?? knownEtag,
          contentHash: contentHash,
          remoteLastModifiedAt: resp.lastModifiedAt ?? head.lastModifiedAt,
          remoteSummary: ok
              ? _summaryFromJson(Map<String, dynamic>.from(jsonDecode(json)),
                  contentHash, bytes.length)
              : null);
    } catch (e) {
      return CloudSyncResult(
          ok: false, message: '${tr('store.uploadFailed')}：$e');
    }
  }

  Future<CloudSyncResult> download(CloudSyncSettings settings) async {
    if (!settings.enabled)
      return CloudSyncResult(ok: false, message: tr('store.cloudConfigFirst'));
    try {
      final resp = await _send(settings, 'GET', _buildUri(settings));
      final text = utf8.decode(resp.body, allowMalformed: true);
      final decoded = jsonDecode(text);
      final ok =
          resp.statusCode >= 200 && resp.statusCode < 300 && decoded is Map;
      final contentHash = _hashBytes(resp.body);
      return CloudSyncResult(
          ok: ok,
          message: ok
              ? tr('store.cloudDownloaded')
              : '${tr('store.downloadFailed')}：HTTP ${resp.statusCode} ${_responseText(resp)}',
          payload: ok ? text : null,
          statusCode: resp.statusCode,
          etag: _cleanEtag(resp.etag),
          contentHash: ok ? contentHash : null,
          remoteLastModifiedAt: resp.lastModifiedAt,
          remoteSummary: ok
              ? _summaryFromJson(Map<String, dynamic>.from(decoded),
                  contentHash, resp.body.length)
              : null);
    } catch (e) {
      return CloudSyncResult(
          ok: false, message: '${tr('store.downloadFailed')}：$e');
    }
  }
}

extension _StringTake on String {
  String take(int max) => length <= max ? this : substring(0, max);
}

const Map<String, String> _categoryL10nKeys = {
  'cat_digital': 'store.catDigital',
  'cat_audio_video': 'store.catAudioVideo',
  'cat_photo_creative': 'store.catPhotoCreative',
  'cat_game_hobby': 'store.catGameHobby',
  'cat_work_study': 'store.catWorkStudy',
  'cat_wear_style': 'store.catWearStyle',
  'cat_home_life': 'store.catHomeLife',
  'cat_transport': 'store.catTransport',
  'cat_sport_health': 'store.catSportHealth',
  'cat_tools_repair': 'store.catToolsRepair',
  'cat_collection': 'store.catCollection',
  'cat_service': 'store.catService',
};

Set<WidgetRefreshTarget> widgetRefreshTargetsForSettings(
  AppSettings previous,
  AppSettings next,
) {
  final targets = <WidgetRefreshTarget>{};
  if (previous.currencyUnit != next.currencyUnit) {
    targets.addAll(const {
      WidgetRefreshTarget.total,
      WidgetRefreshTarget.daily,
      WidgetRefreshTarget.mini,
    });
  }
  if (previous.includeRetiredInTotal != next.includeRetiredInTotal) {
    targets.addAll(const {
      WidgetRefreshTarget.total,
      WidgetRefreshTarget.mini,
    });
  }
  return targets;
}

class AppStore extends ChangeNotifier {
  final LocalSqliteStorage _storage = const LocalSqliteStorage();
  final CloudSyncService _cloud = const CloudSyncService();
  late final SaveCoordinator _saveCoordinator;

  StorageLoadResult _storageLoadResult = const StorageLoadResult.empty();
  String? _lastValidatedSnapshot;
  PersistenceSaveState _persistenceState = const PersistenceSaveState.idle();
  CloudSyncConflict? _cloudConflict;
  String? _undoPayload;
  String? _undoLabel;
  bool _undoInFlight = false;
  bool _destructiveMutationInFlight = false;
  bool _restoreInFlight = false;
  bool _reminderSyncInFlight = false;
  final Map<int, Set<WidgetRefreshTarget>> _widgetTargetsByRevision = {};

  AppStore() {
    _saveCoordinator = SaveCoordinator(
      writer: _writeSnapshot,
      onStateChanged: (state) {
        _persistenceState = state;
        notifyListeners();
      },
    );
  }

  AppSettings settings = const AppSettings();
  final List<Category> categories = [];
  final List<Tag> tags = [];
  final List<Asset> assets = [];
  final List<Wish> wishes = [];
  final List<ValueRecoveryRecord> recoveryRecords = [];
  final List<ReminderRecord> reminders = [];
  final List<SnapshotRecord> snapshots = [];

  String query = '';
  String statusFilter = 'all';
  String categoryFilter = 'all';
  bool taggedOnly = false;
  bool targetedOnly = false;
  SortMode sortMode = SortMode.dailyCost;
  HomeViewMode viewMode = HomeViewMode.grid;
  bool wishShowArchived = false;
  int _homeRevision = 0;

  String? _analyticsSnapshotKey;
  AnalyticsSnapshot? _analyticsSnapshot;

  StorageLoadResult get storageLoadResult => _storageLoadResult;
  String? get lastValidatedSnapshot => _lastValidatedSnapshot;
  bool get isStorageReadOnly => _storageLoadResult.isFailure;
  PersistenceSaveState get persistenceState => _persistenceState;
  int get persistenceRevision => _saveCoordinator.revision;
  int get persistedRevision => _saveCoordinator.persistedRevision;
  CloudSyncConflict? get cloudConflict => _cloudConflict;
  bool get canUndo => _undoPayload != null && !_undoInFlight;
  String? get undoLabel => _undoLabel;
  int get homeRevision => _homeRevision;

  void _notifyHomeChanged() {
    _homeRevision++;
    notifyListeners();
  }

  Future<bool> _hydrateCloudCredentials() async {
    final localCloud = settings.cloudSync;
    final result = await _storage.loadCredentials();
    if (!result.ok) return false;
    final stored = result.credentials;
    if (stored != null && stored.hasValues) {
      settings = settings.copyWith(
        cloudSync: localCloud.copyWith(
          username: stored.username,
          password: stored.password,
        ),
      );
      // A secure entry may already exist after an interrupted migration while
      // the local JSON still contains the legacy plaintext fields.
      return localCloud.hasCredentials;
    }
    if (!localCloud.hasCredentials) return false;

    // v1/v2 payloads may still contain credentials. Move them once to the
    // secure store, then let the caller rewrite the local JSON without them.
    await _storage.saveCredentials(
      username: localCloud.username,
      password: localCloud.password,
    );
    return true;
  }

  CloudRemoteSummary _summaryForJson(String raw) {
    final bytes = utf8.encode(raw);
    return CloudRemoteSummary.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
      sha256.convert(bytes).toString(),
      bytes.length,
    );
  }

  CloudSyncSettings _settingsWithRemoteResult(
      CloudSyncSettings base, CloudSyncResult result) {
    final cleared = base.copyWith(clearRemoteMetadata: true);
    return cleared.copyWith(
      remoteEtag: result.etag,
      remoteContentHash: result.contentHash,
      remoteAssetCount: result.remoteSummary?.assets,
      remoteWishCount: result.remoteSummary?.wishes,
      remoteLastModifiedAt: result.remoteLastModifiedAt,
    );
  }

  void clearCloudConflict() {
    if (_cloudConflict == null) return;
    _cloudConflict = null;
    notifyListeners();
  }

  String _analyticsKey() {
    final buffer = StringBuffer()
      ..write('day:')
      ..write(dateEpochDay(DateTime.now()))
      ..write('|')
      ..write(settings.includeRetiredInTotal)
      ..write('|')
      ..write(settings.durationMode.name)
      ..write('|')
      ..write(settings.currencyUnit)
      ..write('|')
      ..write(settings.decimalPlaces)
      ..write('|a:')
      ..write(assets.length)
      ..write('|w:')
      ..write(wishes.length)
      ..write('|r:')
      ..write(recoveryRecords.length);
    for (final asset in assets) {
      buffer
        ..write('|')
        ..write(asset.id)
        ..write(':')
        ..write(asset.updatedAt.millisecondsSinceEpoch)
        ..write(':')
        ..write(asset.status.name)
        ..write(':')
        ..write(asset.addons.length)
        ..write(':')
        ..write(asset.tagIds.length);
    }
    for (final wish in wishes) {
      buffer
        ..write('|')
        ..write(wish.id)
        ..write(':')
        ..write(wish.updatedAt.millisecondsSinceEpoch)
        ..write(':')
        ..write(wish.archived);
    }
    for (final item in recoveryRecords) {
      buffer
        ..write('|')
        ..write(item.id)
        ..write(':')
        ..write(item.updatedAt.millisecondsSinceEpoch);
    }
    return buffer.toString();
  }

  void _invalidateAnalytics() {
    _analyticsSnapshotKey = null;
    _analyticsSnapshot = null;
  }

  AnalyticsSnapshot get analyticsSnapshot {
    final key = _analyticsKey();
    final cached = _analyticsSnapshot;
    if (cached != null && _analyticsSnapshotKey == key) return cached;
    final topDaily = assets
        .where((a) => !a.isPriceless && a.includeInDailyCost)
        .toList()
      ..sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
    final snapshot = AnalyticsSnapshot(
      totalAssetValue: getTotalAssetValue(),
      averageDailyCost: getAverageDailyCost(),
      totalPurchaseCost: getTotalPurchaseCost(),
      wishBudget: wishes
          .where((w) => !w.archived)
          .fold(0.0, (s, w) => s + w.expectedPrice),
      lifecycleNetConsumption: getLifecycleNetConsumption(),
      lifecycleRecoveredValue: getLifecycleRecoveredValue(),
      categoryDistribution:
          Map<String, double>.unmodifiable(categoryDistribution()),
      tagDistribution: Map<String, int>.unmodifiable(tagDistribution()),
      topDailyAssets: List<Asset>.unmodifiable(topDaily),
      valueTrend: List<AssetTrendPoint>.unmodifiable(assetValueTrend()),
      dailyCostTrend: List<AssetTrendPoint>.unmodifiable(dailyCostTrend()),
      insights: List<AssetInsight>.unmodifiable(assetInsights()),
    );
    _analyticsSnapshotKey = key;
    _analyticsSnapshot = snapshot;
    return snapshot;
  }

  ThemeMode get resolvedThemeMode {
    switch (settings.theme) {
      case ThemeSetting.dark:
        return ThemeMode.dark;
      case ThemeSetting.system:
        return ThemeMode.system;
      case ThemeSetting.light:
        return ThemeMode.light;
    }
  }

  Future<StorageLoadResult> load() async {
    final result = await _storage.load();
    _storageLoadResult = result;
    _lastValidatedSnapshot = result.lastValidatedPayload;
    if (result.isFailure) {
      _invalidateAnalytics();
      notifyListeners();
      return result;
    }

    var reminderSyncHandled = false;
    try {
      final raw = result.payload ?? '';
      if (result.status == StorageLoadStatus.empty) {
        if (result.hasValidatedSnapshot) {
          _storageLoadResult = StorageLoadResult.recoverableFailure(
            errorCode: 'storage_payload_missing',
            lastValidatedPayload: result.lastValidatedPayload,
          );
          _invalidateAnalytics();
          notifyListeners();
          return _storageLoadResult;
        }
        initializeEmptyData();
        await save();
        reminderSyncHandled = true;
      } else {
        importMap(Map<String, dynamic>.from(jsonDecode(raw)));
        final migratedLegacyCredentials = await _hydrateCloudCredentials();
        if (migratedLegacyCredentials) {
          await save();
          reminderSyncHandled = true;
        } else if (result.lastValidatedPayload != raw) {
          await _storage.markValidated(raw);
        }
        _lastValidatedSnapshot = raw;
        _storageLoadResult = StorageLoadResult.success(
          payload: raw,
          lastValidatedPayload: raw,
        );
      }
    } on PersistedDataException catch (error) {
      _storageLoadResult = StorageLoadResult.recoverableFailure(
        errorCode: error.code,
        errorMessage: error.message,
        lastValidatedPayload: _lastValidatedSnapshot,
      );
      _invalidateAnalytics();
      notifyListeners();
      return _storageLoadResult;
    } catch (error) {
      _storageLoadResult = StorageLoadResult.recoverableFailure(
        errorCode: 'storage_payload_invalid',
        errorMessage: error.toString(),
        lastValidatedPayload: _lastValidatedSnapshot,
      );
      _invalidateAnalytics();
      notifyListeners();
      return _storageLoadResult;
    }
    viewMode = settings.defaultHomeViewMode;
    configureRuntimeSettings(settings);
    if (!reminderSyncHandled) await _synchronizeReminderSchedule();
    if (settings.cloudSync.syncOnLaunch && settings.cloudSync.enabled) {
      Future<void>(() async {
        await downloadCloudBackup(silent: true);
      });
    }
    _invalidateAnalytics();
    notifyListeners();
    return _storageLoadResult;
  }

  void importMap(Map<String, dynamic> data) {
    final normalized = migratePersistedMap(data);
    final importedSettings = AppSettings.fromMap(
        Map<String, dynamic>.from(normalized['settings'] ?? normalized));
    final importedCloud = importedSettings.cloudSync;
    final localCloud = settings.cloudSync;
    final nextSettings = importedSettings.copyWith(
      cloudSync: importedCloud.copyWith(
        username: importedCloud.username.trim().isNotEmpty
            ? importedCloud.username
            : localCloud.username,
        password: importedCloud.password.isNotEmpty
            ? importedCloud.password
            : localCloud.password,
      ),
    );
    final nextCategories = ((normalized['categories'] as List?) ?? [])
        .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextTags = ((normalized['tags'] as List?) ?? [])
        .map((e) => Tag.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextAssets = ((normalized['assets'] as List?) ?? [])
        .map((e) => Asset.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextWishes = ((normalized['wishes'] as List?) ?? [])
        .map((e) => Wish.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextRecoveryRecords = ((normalized['recoveryRecords'] as List?) ?? [])
        .map((e) => ValueRecoveryRecord.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextReminders = ((normalized['reminders'] as List?) ?? [])
        .map((e) => ReminderRecord.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextSnapshots = ((normalized['snapshots'] as List?) ?? [])
        .map((e) => SnapshotRecord.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    nextCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    nextTags.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (nextAssets.isEmpty && nextWishes.isEmpty) nextSnapshots.clear();

    settings = nextSettings;
    categories
      ..clear()
      ..addAll(nextCategories);
    tags
      ..clear()
      ..addAll(nextTags);
    assets
      ..clear()
      ..addAll(nextAssets);
    wishes
      ..clear()
      ..addAll(nextWishes);
    recoveryRecords
      ..clear()
      ..addAll(nextRecoveryRecords);
    reminders
      ..clear()
      ..addAll(nextReminders);
    snapshots
      ..clear()
      ..addAll(nextSnapshots);
    _invalidateAnalytics();
  }

  void _refreshReminderRecords() {
    final previous = <String, ReminderRecord>{
      for (final reminder in reminders) reminder.id: reminder,
    };
    final next = <ReminderRecord>[];
    final now = DateTime.now();

    void addReminder({
      required Asset asset,
      required String type,
      required DateTime triggerDate,
      required DateTime triggerAt,
      required String body,
    }) {
      final id = 'asset:${asset.id}:$type';
      final old = previous[id];
      next.add(ReminderRecord(
        id: id,
        sourceId: asset.id,
        type: type,
        triggerDate: dateOnly(triggerDate),
        triggerAt: triggerAt,
        title: tr('notification.title'),
        body: body,
        enabled: settings.reminderEnabled && triggerAt.isAfter(now),
        lastScheduleResult: old?.lastScheduleResult ?? 'pending',
        lastScheduledAt: old?.lastScheduledAt,
      ));
    }

    for (final asset in assets) {
      if (asset.status == AssetStatus.sold) continue;
      final expiry = asset.expiresAt;
      final remindDays = asset.remindBeforeDays;
      if (expiry != null && remindDays != null && remindDays >= 0) {
        final triggerAt = dateOnly(expiry)
            .subtract(Duration(days: remindDays))
            .add(const Duration(hours: 9));
        addReminder(
          asset: asset,
          type: 'expiry',
          triggerDate: dateOnly(expiry).subtract(Duration(days: remindDays)),
          triggerAt: triggerAt,
          body: tlf('notification.assetExpiry', {
            'name': asset.name,
            'date': dateText(expiry),
          }),
        );
      }
      if (asset.targetMode == TargetMode.date && asset.targetDate != null) {
        final targetDate = asset.targetDate!;
        addReminder(
          asset: asset,
          type: 'target_date',
          triggerDate: dateOnly(targetDate),
          triggerAt: dateOnly(targetDate).add(const Duration(hours: 9)),
          body: tlf('notification.assetTarget', {
            'name': asset.name,
            'date': dateText(targetDate),
          }),
        );
      }
    }

    next.sort((a, b) {
      final byDate = a.triggerAt.compareTo(b.triggerAt);
      return byDate != 0 ? byDate : a.id.compareTo(b.id);
    });
    reminders
      ..clear()
      ..addAll(next);
  }

  Future<void> _synchronizeReminderSchedule({bool persistResult = true}) async {
    if (_reminderSyncInFlight) return;
    _reminderSyncInFlight = true;
    try {
      _refreshReminderRecords();
      final result = await NativeBridge.syncRemindersResult();
      if (result.error?.code == NativeBridgeErrorCode.notImplemented) return;

      final before = jsonEncode(reminders.map((e) => e.toMap()).toList());
      final now = DateTime.now();
      final scheduleResult = result.isSuccess
          ? (result.value?['result']?.toString() ?? 'scheduled')
          : (result.error?.code.wireName ?? 'unknown');
      final updated = reminders
          .map((reminder) => reminder.copyWith(
                lastScheduleResult: scheduleResult,
                lastScheduledAt: now,
              ))
          .toList();
      reminders
        ..clear()
        ..addAll(updated);
      final after = jsonEncode(reminders.map((e) => e.toMap()).toList());
      if (persistResult && before != after && !isStorageReadOnly) {
        await _enqueueSnapshot(
          jsonEncode(exportMap()),
          kind: PersistenceSaveKind.settings,
          syncReminders: false,
        );
      }
    } finally {
      _reminderSyncInFlight = false;
    }
  }

  Map<String, dynamic> exportMap({bool includeSnapshots = true}) {
    _refreshReminderRecords();
    return {
      'storageSchemaVersion': kCurrentStorageSchemaVersion,
      'exportSchemaVersion': kCurrentExportSchemaVersion,
      'appVersion': kValoraAppVersion,
      'version': kCurrentExportSchemaVersion,
      'generatedBy': 'valora-flutter',
      'settings': settings.toMap(),
      'categories': categories.map((e) => e.toMap()).toList(),
      'tags': tags.map((e) => e.toMap()).toList(),
      'assets': assets.map((e) => e.toMap()).toList(),
      'wishes': wishes.map((e) => e.toMap()).toList(),
      'recoveryRecords': recoveryRecords.map((e) => e.toMap()).toList(),
      'reminders': reminders.map((e) => e.toMap()).toList(),
      if (includeSnapshots)
        'snapshots': snapshots.map((e) => e.toMap()).toList(),
    };
  }

  String exportJson({bool includeSnapshots = true}) =>
      const JsonEncoder.withIndent('  ')
          .convert(exportMap(includeSnapshots: includeSnapshots));

  Future<void> _writeSnapshot(int _, String snapshot) =>
      _persistValidatedSnapshot(snapshot);

  Future<void> _persistValidatedSnapshot(String snapshot) async {
    await _storage.save(snapshot);
    final echoed = await _storage.load();
    if (echoed.status != StorageLoadStatus.success ||
        echoed.payload != snapshot) {
      throw StateError(tr('store.sqliteVerifyFailed'));
    }
    await _storage.markValidated(snapshot);
    _lastValidatedSnapshot = snapshot;
  }

  Future<void> _refreshHomeWidgets(Set<WidgetRefreshTarget> targets) {
    return NativeBridge.updateHomeWidget(
      assetCount: assets.length,
      wishCount: wishes.where((w) => !w.archived).length,
      totalAssetValue: getTotalAssetValue(),
      averageDailyCost: getAverageDailyCost(),
      currency: settings.currencyUnit,
      servingCount: statusCount(AssetStatus.serving),
      retiredCount: statusCount(AssetStatus.retired),
      soldCount: statusCount(AssetStatus.sold),
      dueSoonCount: dueSoonAssets().length,
      leakCount: walletLeaks(limit: 99).length,
      snapshotCount: snapshots.length,
      targets: targets,
    );
  }

  Future<bool> _enqueueSnapshot(
    String snapshot, {
    PersistenceSaveKind kind = PersistenceSaveKind.crud,
    bool syncReminders = true,
    Set<WidgetRefreshTarget>? widgetTargets,
  }) async {
    if (isStorageReadOnly) {
      throw StateError(tr('store.recovery.readOnly'));
    }
    final ticket = _saveCoordinator.enqueue(snapshot, kind: kind);
    _widgetTargetsByRevision[ticket.revision] =
        Set<WidgetRefreshTarget>.of(widgetTargets ?? const {});
    await ticket.completion;
    final isLatestPersisted =
        ticket.revision == _saveCoordinator.persistedRevision;
    if (isLatestPersisted) {
      _storageLoadResult = StorageLoadResult.success(
        payload: snapshot,
        lastValidatedPayload: snapshot,
      );
      final targets = <WidgetRefreshTarget>{};
      for (final entry in _widgetTargetsByRevision.entries) {
        if (entry.key <= _saveCoordinator.persistedRevision) {
          targets.addAll(entry.value);
        }
      }
      _widgetTargetsByRevision.removeWhere(
          (revision, _) => revision <= _saveCoordinator.persistedRevision);
      if (kind == PersistenceSaveKind.crud && targets.isEmpty) {
        targets.addAll(kAllWidgetRefreshTargets);
      }
      if (targets.isNotEmpty) unawaited(_refreshHomeWidgets(targets));
      if (syncReminders) await _synchronizeReminderSchedule();
    }
    return isLatestPersisted;
  }

  Future<void> save(
      {PersistenceSaveKind kind = PersistenceSaveKind.crud,
      Set<WidgetRefreshTarget>? widgetTargets}) async {
    final isLatestPersisted = await _enqueueSnapshot(jsonEncode(exportMap()),
        kind: kind, widgetTargets: widgetTargets);
    if (isLatestPersisted) _clearUndo();
    if (isLatestPersisted &&
        settings.cloudSync.autoUploadOnSave &&
        settings.cloudSync.enabled) {
      await NativeBridge.enqueueCloudBackup();
    }
  }

  Future<void> retryPersistence() async {
    final snapshot = jsonEncode(exportMap());
    await _enqueueSnapshot(snapshot);
  }

  Future<void> updateCloudSyncSettings(CloudSyncSettings value) async {
    final endpointChanged =
        value.serverUrl.trim() != settings.cloudSync.serverUrl.trim() ||
            value.remotePath.trim() != settings.cloudSync.remotePath.trim() ||
            value.provider != settings.cloudSync.provider;
    final nextValue =
        endpointChanged ? value.copyWith(clearRemoteMetadata: true) : value;
    if (nextValue.hasCredentials) {
      await _storage.saveCredentials(
        username: nextValue.username,
        password: nextValue.password,
      );
    } else {
      await _storage.clearCredentials();
    }
    settings = settings.copyWith(cloudSync: nextValue);
    await save(kind: PersistenceSaveKind.settings);
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> clearCloudCredentials() async {
    await _storage.clearCredentials();
    settings = settings.copyWith(
      cloudSync: settings.cloudSync.copyWith(clearCredentials: true),
    );
    await save(kind: PersistenceSaveKind.settings);
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<CloudSyncResult> testCloudConnection() =>
      _cloud.test(settings.cloudSync);

  Future<CloudSyncResult> uploadCloudBackup({bool silent = false}) async {
    final json = exportJson();
    final result = await _cloud.upload(settings.cloudSync, json);
    if (result.conflict) {
      _cloudConflict = CloudSyncConflict(
        remoteResult: result,
        localSummary: _summaryForJson(json),
        detectedAt: DateTime.now(),
      );
      if (!silent) _notifyHomeChanged();
      return result;
    }
    if (result.ok) {
      settings = settings.copyWith(
        cloudSync: _settingsWithRemoteResult(
          settings.cloudSync,
          result,
        ).copyWith(lastUploadAt: DateTime.now()),
      );
      final snapshot = jsonEncode(exportMap());
      await _enqueueSnapshot(snapshot, kind: PersistenceSaveKind.settings);
      _cloudConflict = null;
      _invalidateAnalytics();
      if (!silent) _notifyHomeChanged();
    }
    return result;
  }

  Future<CloudSyncResult> downloadCloudBackup({bool silent = false}) async {
    final result = await _cloud.download(settings.cloudSync);
    if (!result.ok || result.payload == null) return result;

    final localJson = exportJson();
    final localCloud = settings.cloudSync;
    final localHash = sha256.convert(utf8.encode(localJson)).toString();
    if (silent && localHash != result.contentHash) {
      final conflictResult = CloudSyncResult(
        ok: false,
        conflict: true,
        message: tr('store.cloudConflict'),
        statusCode: result.statusCode,
        etag: result.etag,
        contentHash: result.contentHash,
        remoteLastModifiedAt: result.remoteLastModifiedAt,
        remoteSummary: result.remoteSummary,
      );
      _cloudConflict = CloudSyncConflict(
        remoteResult: conflictResult,
        localSummary: _summaryForJson(localJson),
        detectedAt: DateTime.now(),
      );
      notifyListeners();
      return conflictResult;
    }

    Map<String, dynamic> prepared;
    try {
      prepared = prepareRestoreJson(result.payload!);
    } catch (error) {
      return CloudSyncResult(
        ok: false,
        message: '${tr('store.downloadFailed')}：$error',
        statusCode: result.statusCode,
        etag: result.etag,
        contentHash: result.contentHash,
        remoteLastModifiedAt: result.remoteLastModifiedAt,
        remoteSummary: result.remoteSummary,
      );
    }

    try {
      if (!silent) {
        await createSnapshot(tlf('恢复前快照 {date}', {'date': dateStamp()}));
      }
      importMap(prepared);
      settings = settings.copyWith(
        cloudSync: _settingsWithRemoteResult(
          localCloud,
          result,
        ).copyWith(lastDownloadAt: DateTime.now()),
      );
      await _enqueueSnapshot(jsonEncode(exportMap()));
      _clearUndo();
      _cloudConflict = null;
      _invalidateAnalytics();
      if (!silent) _notifyHomeChanged();
    } catch (error) {
      try {
        importMap(Map<String, dynamic>.from(jsonDecode(localJson) as Map));
        await _enqueueSnapshot(jsonEncode(exportMap()));
      } catch (_) {
        // Keep the in-memory rollback best effort; the prior validated local
        // snapshot remains the durable recovery point.
      }
      return CloudSyncResult(
        ok: false,
        message: '${tr('store.downloadFailed')}：$error',
        statusCode: result.statusCode,
        etag: result.etag,
        contentHash: result.contentHash,
        remoteLastModifiedAt: result.remoteLastModifiedAt,
        remoteSummary: result.remoteSummary,
      );
    }
    return result;
  }

  void initializeEmptyData() {
    categories.clear();
    tags.clear();
    assets.clear();
    wishes.clear();
    recoveryRecords.clear();
    reminders.clear();
    snapshots.clear();
    settings = const AppSettings();
    viewMode = settings.defaultHomeViewMode;
    _invalidateAnalytics();
  }

  // Kept for backward compatibility with older docs/scripts. It no longer creates demo/mock assets.
  void seed() => initializeEmptyData();

  Category? categoryById(String? id) {
    if (id == null) return null;
    for (final item in categories) {
      if (item.id == id) return item;
    }
    return null;
  }

  Tag? tagById(String id) {
    for (final item in tags) {
      if (item.id == id) return item;
    }
    return null;
  }

  String categoryName(String? id) {
    final item = categoryById(id);
    if (item == null) return tr('store.uncategorized');
    final key = _categoryL10nKeys[item.id];
    if (key != null) return tr(key);
    return tl(item.name);
  }

  String tagName(String id) {
    final item = tagById(id);
    if (item == null) return id;
    return tl(item.name);
  }

  String categoryIcon(String? id) => categoryById(id)?.icon ?? '📦';

  double getTotalAssetValue() => assets
      .where((a) =>
          settings.includeRetiredInTotal || a.status != AssetStatus.retired)
      .fold(0, (sum, a) => sum + a.assetValue);
  double getAverageDailyCost() {
    final list =
        assets.where((a) => !a.isPriceless && a.includeInDailyCost).toList();
    if (list.isEmpty) return 0;
    return list.fold(0.0, (sum, a) => sum + a.dailyCost) / list.length;
  }

  int statusCount(AssetStatus status) =>
      assets.where((a) => a.status == status).length;

  List<Asset> get filteredAssets {
    final q = query.trim().toLowerCase();
    final list = assets.where((asset) {
      if (categoryFilter == 'uncategorized') {
        if (asset.categoryId != null) return false;
      } else if (categoryFilter != 'all' &&
          asset.categoryId != categoryFilter) {
        return false;
      }
      if (statusFilter != 'all' && asset.status.name != statusFilter)
        return false;
      if (taggedOnly && asset.tagIds.isEmpty) return false;
      if (targetedOnly && asset.targetMode == TargetMode.none) return false;
      final haystack = [
        asset.name,
        asset.note,
        categoryName(asset.categoryId),
        if (asset.isPriceless) tr('store.pricelessKeywords'),
        ...asset.tagIds.map(tagName),
      ].join(' ').toLowerCase();
      return q.isEmpty || haystack.contains(q);
    }).toList();
    switch (sortMode) {
      case SortMode.dailyCost:
        list.sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
        break;
      case SortMode.price:
        list.sort((a, b) => b.totalDisplayValue.compareTo(a.totalDisplayValue));
        break;
      case SortMode.days:
        list.sort((a, b) => b.serviceDays.compareTo(a.serviceDays));
        break;
      case SortMode.recent:
        list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        break;
    }
    return list;
  }

  Map<String, double> categoryDistribution() {
    final result = <String, double>{};
    for (final asset in assets) {
      if (asset.status == AssetStatus.sold) continue;
      if (!settings.includeRetiredInTotal &&
          asset.status == AssetStatus.retired) continue;
      final id = asset.categoryId ?? kUncategorizedAnalyticsKey;
      result[id] = (result[id] ?? 0) + asset.assetValue;
    }
    return result;
  }

  Map<String, int> tagDistribution() {
    final result = <String, int>{};
    for (final asset in assets) {
      for (final id in asset.tagIds) {
        result[id] = (result[id] ?? 0) + 1;
      }
    }
    return result;
  }

  String categoryDistributionLabel(String key) =>
      key == kUncategorizedAnalyticsKey
          ? tr('store.uncategorized')
          : categoryName(key);

  String tagDistributionLabel(String key) => tagName(key);

  double getTotalPurchaseCost() => assets
      .where((a) => !a.isPriceless)
      .fold(0.0, (sum, asset) => sum + asset.acquisitionCost);

  double getActiveAssetValue() => assets
      .where((a) => a.status == AssetStatus.serving)
      .fold(0.0, (sum, a) => sum + a.assetValue);

  double getSoldLossOrGain() => assets
      .where((a) => a.status == AssetStatus.sold && !a.isPriceless)
      .fold(0.0, (sum, a) => sum + ((a.soldPrice ?? 0) - a.acquisitionCost));

  double getNetAssetPosition() =>
      getTotalAssetValue() +
      getLifecycleRecoveredValue() -
      getTotalPurchaseCost();

  List<AssetLeakItem> walletLeaks({int limit = 4}) {
    final avg = getAverageDailyCost();
    final rows = <AssetLeakItem>[];
    for (final asset in assets) {
      if (asset.isPriceless) continue;
      if (!asset.includeInDailyCost) continue;
      final isIdle = asset.status == AssetStatus.retired ||
          asset.tagIds.any((id) => tagName(id)
              .toLowerCase()
              .contains(tr('store.tagIdle').toLowerCase()));
      final highDaily = avg > 0 && asset.dailyCost > avg * 1.35;
      final targetMiss = asset.targetMode != TargetMode.none &&
          asset.targetRatio < .55 &&
          asset.serviceDays > 30;
      final expiringSoon = asset.expiresAt != null &&
          asset.expiresAt!.difference(DateTime.now()).inDays >= 0 &&
          asset.expiresAt!.difference(DateTime.now()).inDays <=
              (asset.remindBeforeDays ?? 7);
      if (!isIdle && !highDaily && !targetMiss && !expiringSoon) continue;
      final score = asset.dailyCost * (isIdle ? 1.4 : 1.0) +
          (highDaily ? 8 : 0) +
          (targetMiss ? 5 : 0) +
          (expiringSoon ? 3 : 0);
      final reason = isIdle
          ? tr('store.leakIdle')
          : highDaily
              ? tr('store.leakHighDaily')
              : targetMiss
                  ? tr('store.leakTargetSlow')
                  : tr('store.leakExpiringSoon');
      final suggestion = isIdle
          ? tr('store.leakSuggestIdle')
          : highDaily
              ? tr('store.leakSuggestHighDaily')
              : targetMiss
                  ? tr('store.leakSuggestTargetSlow')
                  : tr('store.leakSuggestExpiring');
      rows.add(AssetLeakItem(
          asset: asset, reason: reason, suggestion: suggestion, score: score));
    }
    rows.sort((a, b) => b.score.compareTo(a.score));
    return rows.take(limit).toList();
  }

  List<AssetTrendPoint> assetValueTrend({int segments = 8}) {
    if (assets.isEmpty) return const [];
    final sorted = [...assets]
      ..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
    final start = dateOnly(sorted.first.purchaseDate);
    final end = dateOnly(DateTime.now());
    final totalDays = math.max(end.difference(start).inDays, 0);
    final sampleCount = math.max(1, math.min(segments, totalDays + 1));
    final points = <AssetTrendPoint>[];
    for (var i = 0; i < sampleCount; i++) {
      final offset = sampleCount == 1
          ? totalDays
          : (totalDays * i / (sampleCount - 1)).round();
      final cursor = start.add(Duration(days: offset));
      final value = assets.fold(0.0, (sum, asset) {
        final purchaseDate = dateOnly(asset.purchaseDate);
        if (purchaseDate.isAfter(cursor)) return sum;
        if (asset.status == AssetStatus.sold &&
            asset.soldAt != null &&
            !dateOnly(asset.soldAt!).isAfter(cursor)) return sum;
        if (!settings.includeRetiredInTotal &&
            asset.status == AssetStatus.retired &&
            (asset.retiredAt == null ||
                !dateOnly(asset.retiredAt!).isAfter(cursor))) return sum;
        if (!asset.includeInTotal) return sum;
        if (asset.isPriceless) return sum;
        final addonValue = asset.addons.fold(0.0, (addonSum, addon) {
          if (!addon.includeInTotal) return addonSum;
          final addonDate =
              addon.effectivePurchaseDate(purchaseDate) ?? purchaseDate;
          return dateOnly(addonDate).isAfter(cursor)
              ? addonSum
              : addonSum + addon.price;
        });
        return sum + asset.price + addonValue;
      });
      points.add(AssetTrendPoint(
          label: '${cursor.month}/${cursor.day}', value: value));
    }
    return points;
  }

  List<AssetTrendPoint> dailyCostTrend({int segments = 8}) {
    final dailyAssets =
        assets.where((a) => !a.isPriceless && a.includeInDailyCost).toList();
    if (dailyAssets.isEmpty) return const [];
    dailyAssets.sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
    final start = dateOnly(dailyAssets.first.purchaseDate);
    final end = dateOnly(DateTime.now());
    final totalDays = math.max(end.difference(start).inDays, 0);
    final sampleCount = math.max(1, math.min(segments, totalDays + 1));
    final points = <AssetTrendPoint>[];
    DateTime? previousCursor;
    for (var i = 0; i < sampleCount; i++) {
      final offset = sampleCount == 1
          ? totalDays
          : (totalDays * i / (sampleCount - 1)).round();
      final cursor = start.add(Duration(days: offset));
      if (previousCursor != null &&
          dateEpochDay(previousCursor) == dateEpochDay(cursor)) {
        continue;
      }
      previousCursor = cursor;
      final activeDailyCosts = <double>[];
      for (final asset in dailyAssets) {
        final purchaseDate = dateOnly(asset.purchaseDate);
        if (purchaseDate.isAfter(cursor)) continue;
        final recovered = getAssetRecoveryIncomeAt(asset.id, cursor);
        activeDailyCosts.add(asset.dailyCostAt(cursor, recovered: recovered));
      }
      if (activeDailyCosts.isEmpty) continue;
      final average = activeDailyCosts.fold(0.0, (sum, value) => sum + value) /
          activeDailyCosts.length;
      points.add(AssetTrendPoint(
          label: '${cursor.month}/${cursor.day}', value: average));
    }
    return points;
  }

  List<LifecycleEventItem> lifecycleEvents({int limit = 8}) {
    final rows = <LifecycleEventItem>[];
    for (final asset in assets) {
      rows.add(LifecycleEventItem(
        date: asset.purchaseDate,
        title:
            '${asset.isPriceless ? tr('store.eventRecord') : tr('store.eventBuy')} ${asset.name}',
        subtitle:
            '${categoryIcon(asset.categoryId)} ${categoryName(asset.categoryId)} · ${assetBasePriceText(asset, settings)}',
        icon: Icons.add_shopping_cart_rounded,
        color: kBrandStrong,
        sortKey: 'asset:${asset.id}:purchase',
      ));
      if (asset.status == AssetStatus.retired && asset.retiredAt != null) {
        rows.add(LifecycleEventItem(
          date: asset.retiredAt!,
          title: '${tr('store.eventRetire')} ${asset.name}',
          subtitle: asset.isPriceless
              ? '${tr('store.eventTotalRecord')} ${durationText(asset.serviceDays, settings.durationMode)}'
              : '${tr('store.eventTotalServed')} ${durationText(asset.serviceDays, settings.durationMode)}${tr('store.eventFinalDaily')} ${money(asset.dailyCost, settings)} ${tr('store.perDay')}',
          icon: Icons.archive_rounded,
          color: const Color(0xFFFFB020),
          sortKey: 'asset:${asset.id}:retired',
        ));
      }
      if (asset.status == AssetStatus.sold && asset.soldAt != null) {
        rows.add(LifecycleEventItem(
          date: asset.soldAt!,
          title: '${tr('store.eventSold')} ${asset.name}',
          subtitle:
              '${tr('store.eventRecovered')} ${money(asset.soldPrice ?? 0, settings)}${tr('store.eventNetCost')} ${money(getAssetNetConsumptionAfterRecovery(asset), settings)}',
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFF4ADE80),
          sortKey: 'asset:${asset.id}:sold',
        ));
      }
    }
    for (final item in recoveryRecords) {
      final names = item.assetIds
          .map((id) =>
              assets
                  .where((a) => a.id == id)
                  .cast<Asset?>()
                  .firstOrNull
                  ?.name ??
              tr('store.assetDefault'))
          .take(3)
          .join(tr('store.listSep'));
      rows.add(LifecycleEventItem(
        date: item.date,
        title: '${tr('store.eventRecovery')} ${item.title}',
        subtitle:
            '${names.isEmpty ? tr('store.noAssetSelected') : names} · ${tr('store.eventRecoveredAmount')} ${money(item.amount, settings)}',
        icon: Icons.savings_rounded,
        color: const Color(0xFF22C55E),
        sortKey: 'recovery:${item.id}',
      ));
    }
    rows.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      return byDate == 0 ? a.sortKey.compareTo(b.sortKey) : byDate;
    });
    return rows.take(limit).toList();
  }

  List<AssetInsight> assetInsights() {
    final result = <AssetInsight>[];
    final active =
        assets.where((a) => a.status == AssetStatus.serving).toList();
    final avgDaily = getAverageDailyCost();
    final highDaily = [
      ...active.where(
          (a) => !a.isPriceless && avgDaily > 0 && a.dailyCost > avgDaily * 1.6)
    ]..sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
    if (highDaily.isNotEmpty) {
      final a = highDaily.first;
      result.add(AssetInsight(
        icon: Icons.local_fire_department_rounded,
        title: tr('store.insightHighDaily'),
        description:
            '${a.name} ${tr('store.insightHighDailyDesc')} ${money(a.dailyCost, settings)} ${tr('store.perDay')}${tr('store.insightHighDailyAction')}',
        color: const Color(0xFFFF8A65),
      ));
    }

    final targetDone = active
        .where((a) => a.targetMode != TargetMode.none && a.targetRatio >= .98)
        .toList();
    if (targetDone.isNotEmpty) {
      result.add(AssetInsight(
        icon: Icons.flag_circle_rounded,
        title: tr('store.insightTargetDone'),
        description:
            '${targetDone.first.name} ${tr('store.insightTargetDoneDesc')}',
        color: const Color(0xFF4ADE80),
      ));
    }

    final now = DateTime.now();
    final expiring = active.where((a) {
      if (a.expiresAt == null) return false;
      final days = a.expiresAt!.difference(now).inDays;
      return days >= 0 && days <= (a.remindBeforeDays ?? 7);
    }).toList();
    if (expiring.isNotEmpty) {
      result.add(AssetInsight(
        icon: Icons.notifications_active_rounded,
        title: tr('store.insightExpiring'),
        description:
            '${expiring.first.name} ${tr('store.insightExpiringDesc')} ${dateText(expiring.first.expiresAt!)}${tr('store.insightExpiringAction')}',
        color: const Color(0xFFFFC857),
      ));
    }

    final idle = assets
        .where((a) =>
            a.status == AssetStatus.retired ||
            a.tagIds.any((id) => tagName(id)
                .toLowerCase()
                .contains(tr('store.tagIdle').toLowerCase())))
        .length;
    if (idle > 0) {
      result.add(AssetInsight(
        icon: Icons.recycling_rounded,
        title: tr('store.insightIdle'),
        description:
            '${tr('store.insightIdleDesc1')} $idle ${tr('store.insightIdleDesc2')}',
        color: const Color(0xFF60A5FA),
      ));
    }

    final wishBudget = wishes
        .where((w) => !w.archived)
        .fold(0.0, (s, w) => s + w.expectedPrice);
    if (wishBudget > 0 &&
        wishBudget > math.max(getTotalAssetValue(), 1.0) * .35) {
      result.add(AssetInsight(
        icon: Icons.shopping_bag_rounded,
        title: tr('store.insightWishBudget'),
        description:
            '${tr('store.insightWishBudgetDesc')} ${money(wishBudget, settings)}${tr('store.insightWishBudgetAction')}',
        color: const Color(0xFFA78BFA),
      ));
    }

    if (result.isEmpty) {
      result.add(AssetInsight(
        icon: Icons.check_circle_rounded,
        title: tr('store.insightStable'),
        description: tr('store.insightStableDesc'),
        color: kBrandStrong,
      ));
    }
    return result.take(4).toList();
  }

  double getSoldRecoveredValue() => assets
      .where((a) => a.status == AssetStatus.sold && !a.isPriceless)
      .fold(0.0, (sum, a) => sum + (a.soldPrice ?? 0));

  Set<String> get _recoverableAssetIds => assets
      .where((asset) => !asset.isPriceless)
      .map((asset) => asset.id)
      .toSet();

  List<String> _recoverableIdsForRecord(ValueRecoveryRecord item) {
    final allowed = _recoverableAssetIds;
    return item.assetIds.where(allowed.contains).toList();
  }

  double getRecoveryIncomeTotal() => recoveryRecords.fold(0.0, (sum, item) {
        if (_recoverableIdsForRecord(item).isEmpty) return sum;
        return sum + math.max(item.amount, 0);
      });

  double getAssetRecoveryIncome(String assetId) {
    return getAssetRecoveryIncomeAt(assetId, DateTime.now());
  }

  double getAssetRecoveryIncomeAt(String assetId, DateTime asOf) {
    double result = 0;
    for (final item in recoveryRecords) {
      if (dateOnly(item.date).isAfter(dateOnly(asOf))) continue;
      final eligibleIds = _recoverableIdsForRecord(item);
      if (!eligibleIds.contains(assetId)) continue;
      result += math.max(item.amount, 0) / math.max(eligibleIds.length, 1);
    }
    return result;
  }

  double getAssetTotalRecoveredValue(Asset asset) {
    if (asset.isPriceless) return 0;
    final soldRecovered =
        asset.status == AssetStatus.sold ? (asset.soldPrice ?? 0) : 0.0;
    return soldRecovered + getAssetRecoveryIncome(asset.id);
  }

  double getAssetNetConsumptionAfterRecovery(Asset asset) =>
      asset.isPriceless ? 0 : asset.netCost - getAssetRecoveryIncome(asset.id);

  double getLifecycleRecoveredValue() =>
      getSoldRecoveredValue() + getRecoveryIncomeTotal();

  double getLifecycleNetConsumption() => assets.fold(
      0.0, (sum, asset) => sum + getAssetNetConsumptionAfterRecovery(asset));

  List<Asset> pricelessAssets({int limit = 5}) {
    final rows = assets
        .where((a) => a.isPriceless && a.status != AssetStatus.sold)
        .toList()
      ..sort((a, b) => b.serviceDays.compareTo(a.serviceDays));
    return rows.take(limit).toList();
  }

  List<ValueRecoveryRecord> recoveryRecordsForAsset(String assetId) =>
      recoveryRecords.where((e) => e.assetIds.contains(assetId)).toList()
        ..sort((a, b) {
          final byDate = b.date.compareTo(a.date);
          if (byDate != 0) return byDate;
          final byUpdated = b.updatedAt.compareTo(a.updatedAt);
          return byUpdated == 0 ? a.id.compareTo(b.id) : byUpdated;
        });

  Future<void> addRecoveryRecord(ValueRecoveryRecord record) async {
    final referenced = record.assetIds
        .map((id) => assets.where((asset) => asset.id == id).firstOrNull)
        .whereType<Asset>()
        .toList();
    if (referenced.length != record.assetIds.toSet().length) {
      throw const DomainValidationException(<DomainIssue>[
        DomainIssue('validation.recoveryAssetMissing', 'assetIds'),
      ]);
    }
    if (referenced.isNotEmpty) {
      final purchaseDate = referenced
          .map((asset) => asset.purchaseDate)
          .reduce((a, b) => a.isAfter(b) ? a : b);
      final lifecycleEnd = referenced
          .map((asset) => asset.serviceEndDate)
          .reduce((a, b) => a.isBefore(b) ? a : b);
      _validateDomain(DomainValidators.recovery(
        RecoveryValidationInput(
          amount: record.amount,
          date: record.date,
          purchaseDate: purchaseDate,
          lifecycleEnd: lifecycleEnd,
          assetIds: record.assetIds,
        ),
      ));
    } else {
      _validateDomain(DomainValidators.recovery(
        RecoveryValidationInput(
          amount: record.amount,
          date: record.date,
          purchaseDate: record.date,
          lifecycleEnd: record.date,
          assetIds: record.assetIds,
        ),
      ));
    }
    recoveryRecords.add(record);
    recoveryRecords.sort((a, b) => b.date.compareTo(a.date));
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> deleteRecoveryRecord(String id) async {
    recoveryRecords.removeWhere((e) => e.id == id);
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void setQuery(String value) {
    if (query == value) return;
    query = value;
    _notifyHomeChanged();
  }

  void setStatusFilter(String value) {
    if (statusFilter == value) return;
    statusFilter = value;
    _notifyHomeChanged();
  }

  void setCategoryFilter(String value) {
    if (categoryFilter == value) return;
    categoryFilter = value;
    _notifyHomeChanged();
  }

  void setSortMode(SortMode value) {
    if (sortMode == value) return;
    sortMode = value;
    _notifyHomeChanged();
  }

  void setViewMode(HomeViewMode value) {
    viewMode = value;
    updateSettings(settings.copyWith(defaultHomeViewMode: value));
  }

  void setAdvancedFilters({bool? taggedOnlyValue, bool? targetedOnlyValue}) {
    taggedOnly = taggedOnlyValue ?? taggedOnly;
    targetedOnly = targetedOnlyValue ?? targetedOnly;
    _notifyHomeChanged();
  }

  void resetFilters() {
    query = '';
    statusFilter = 'all';
    categoryFilter = 'all';
    taggedOnly = false;
    targetedOnly = false;
    _notifyHomeChanged();
  }

  void setWishArchivedFilter(bool value) {
    wishShowArchived = value;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings next) async {
    final previous = settings;
    if (jsonEncode(previous.toMap()) == jsonEncode(next.toMap())) return;
    settings = next;
    configureRuntimeSettings(settings);
    _invalidateAnalytics();
    _notifyHomeChanged();
    await save(
      kind: PersistenceSaveKind.settings,
      widgetTargets: widgetRefreshTargetsForSettings(previous, next),
    );
  }

  void _validateDomain(DomainValidationResult result) {
    if (!result.isValid) {
      throw DomainValidationException(result.issues);
    }
  }

  AssetValidationInput _assetValidationInput(Asset asset) =>
      AssetValidationInput(
        name: asset.name,
        priceless: asset.isPriceless,
        price: asset.price,
        purchaseDate: asset.purchaseDate,
        isRetired: asset.status == AssetStatus.retired,
        retiredAt: asset.retiredAt,
        isSold: asset.status == AssetStatus.sold,
        soldAt: asset.soldAt,
        soldPrice: asset.soldPrice,
        expiresAt: asset.expiresAt,
        addons: asset.addons
            .map((item) => AddonInput(
                  name: item.name,
                  price: item.price,
                  purchaseDate: item.purchaseDate,
                  followsParentPurchaseDate: item.followParentPurchaseDate,
                ))
            .toList(),
      );

  WishValidationInput _wishValidationInput(Wish wish) => WishValidationInput(
        name: wish.name,
        expectedPrice: wish.expectedPrice,
        addons: wish.addons
            .map((item) => AddonInput(
                  name: item.name,
                  price: item.price,
                  purchaseDate: item.purchaseDate,
                  followsParentPurchaseDate: item.followParentPurchaseDate,
                ))
            .toList(),
      );

  List<String> _resolveTagIds(
      Iterable<String> names, DateTime now, List<Tag> newTags) {
    final tagIds = <String>[];
    final pending = <String, Tag>{};
    for (final raw in names) {
      final name = raw.trim();
      if (name.isEmpty) continue;
      final existed =
          tags.where((tag) => tag.name == name || tag.id == name).firstOrNull;
      if (existed != null) {
        if (!tagIds.contains(existed.id)) tagIds.add(existed.id);
        continue;
      }
      final pendingTag = pending[name];
      if (pendingTag != null) {
        if (!tagIds.contains(pendingTag.id)) tagIds.add(pendingTag.id);
        continue;
      }
      final tag = Tag(
        id: newId('tag'),
        name: name,
        color: '#7cc6f2',
        sortOrder: tags.length + newTags.length,
        createdAt: dateTimeStorageText(now),
        updatedAt: dateTimeStorageText(now),
      );
      pending[name] = tag;
      newTags.add(tag);
      tagIds.add(tag.id);
    }
    return tagIds;
  }

  Future<void> _commitAssetWithTags(Asset asset, List<Tag> newTags) async {
    final previousTags = List<Tag>.of(tags);
    final previousAssets = List<Asset>.of(assets);
    try {
      tags.addAll(newTags);
      tags.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final index = assets.indexWhere((e) => e.id == asset.id);
      if (index >= 0) {
        assets[index] = asset;
      } else {
        assets.add(asset);
      }
      await save();
    } catch (_) {
      tags
        ..clear()
        ..addAll(previousTags);
      assets
        ..clear()
        ..addAll(previousAssets);
      rethrow;
    }
    _invalidateAnalytics();
    _notifyHomeChanged();
  }

  Future<void> _commitWishWithTags(Wish wish, List<Tag> newTags) async {
    final previousTags = List<Tag>.of(tags);
    final previousWishes = List<Wish>.of(wishes);
    try {
      tags.addAll(newTags);
      tags.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      final index = wishes.indexWhere((e) => e.id == wish.id);
      if (index >= 0) {
        wishes[index] = wish;
      } else {
        wishes.add(wish);
      }
      await save();
    } catch (_) {
      tags
        ..clear()
        ..addAll(previousTags);
      wishes
        ..clear()
        ..addAll(previousWishes);
      rethrow;
    }
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> upsertAssetWithTagNames(
      Asset asset, Iterable<String> tagNames) async {
    final nextTags = <Tag>[];
    final tagIds = _resolveTagIds(tagNames, DateTime.now(), nextTags);
    final nextAsset = asset.copyWith(tagIds: tagIds);
    _validateDomain(DomainValidators.asset(_assetValidationInput(nextAsset)));
    await _commitAssetWithTags(nextAsset, nextTags);
  }

  Future<void> upsertWishWithTagNames(
      Wish wish, Iterable<String> tagNames) async {
    final nextTags = <Tag>[];
    final tagIds = _resolveTagIds(tagNames, DateTime.now(), nextTags);
    final nextWish = wish.copyWith(tagIds: tagIds);
    _validateDomain(DomainValidators.wish(_wishValidationInput(nextWish)));
    await _commitWishWithTags(nextWish, nextTags);
  }

  Future<void> upsertAsset(Asset asset) async {
    _validateDomain(DomainValidators.asset(_assetValidationInput(asset)));
    final i = assets.indexWhere((e) => e.id == asset.id);
    if (i >= 0) {
      assets[i] = asset;
    } else {
      assets.add(asset);
    }
    await save();
    _invalidateAnalytics();
    _notifyHomeChanged();
  }

  DestructiveImpact assetDeleteImpact(String id) {
    if (!assets.any((asset) => asset.id == id)) {
      return const DestructiveImpact();
    }
    return DestructiveImpact(
      targetCount: 1,
      affectedAssets: 1,
      affectedWishes:
          wishes.where((wish) => wish.convertedAssetId == id).length,
      affectedRecoveryRecords: recoveryRecords
          .where((record) => record.assetIds.contains(id))
          .length,
    );
  }

  DestructiveImpact wishDeleteImpact(String id) =>
      wishes.any((wish) => wish.id == id)
          ? const DestructiveImpact(targetCount: 1, affectedWishes: 1)
          : const DestructiveImpact();

  DestructiveImpact categoryDeleteImpact(String id) {
    if (!categories.any((category) => category.id == id)) {
      return const DestructiveImpact();
    }
    return DestructiveImpact(
      targetCount: 1,
      affectedCategories: 1,
      affectedAssets: assets.where((asset) => asset.categoryId == id).length,
      affectedWishes: wishes.where((wish) => wish.categoryId == id).length,
    );
  }

  DestructiveImpact tagDeleteImpact(String id) {
    if (!tags.any((tag) => tag.id == id)) return const DestructiveImpact();
    return DestructiveImpact(
      targetCount: 1,
      affectedTags: 1,
      affectedAssets: assets.where((asset) => asset.tagIds.contains(id)).length,
      affectedWishes: wishes.where((wish) => wish.tagIds.contains(id)).length,
    );
  }

  DestructiveImpact snapshotDeleteImpact(String id) =>
      snapshots.any((snapshot) => snapshot.id == id)
          ? const DestructiveImpact(targetCount: 1, affectedSnapshots: 1)
          : const DestructiveImpact();

  DestructiveImpact resetImpact() => DestructiveImpact(
        targetCount: 1,
        affectedAssets: assets.length,
        affectedWishes: wishes.length,
        affectedCategories: categories.length,
        affectedTags: tags.length,
        affectedRecoveryRecords: recoveryRecords.length,
        affectedSnapshots: snapshots.length,
      );

  SnapshotPreview snapshotPreview(SnapshotRecord record) {
    try {
      final prepared = prepareRestoreJson(record.payload);
      int count(String key) {
        final value = prepared[key];
        return value is List ? value.length : 0;
      }

      return SnapshotPreview(
        isValid: true,
        assets: count('assets'),
        wishes: count('wishes'),
        categories: count('categories'),
        tags: count('tags'),
        recoveryRecords: count('recoveryRecords'),
      );
    } catch (_) {
      return const SnapshotPreview(isValid: false);
    }
  }

  void _rememberUndo(String label, String payload) {
    _undoPayload = payload;
    _undoLabel = label;
  }

  void _clearUndo() {
    _undoPayload = null;
    _undoLabel = null;
  }

  Future<bool> _runDestructiveWithUndo({
    required bool exists,
    required String label,
    required Future<void> Function() action,
  }) async {
    if (!exists || _destructiveMutationInFlight) return false;
    _destructiveMutationInFlight = true;
    try {
      final before = exportJson();
      await action();
      _rememberUndo(label, before);
      return true;
    } finally {
      _destructiveMutationInFlight = false;
    }
  }

  Future<bool> deleteAssetWithUndo(String id) => _runDestructiveWithUndo(
        exists: assets.any((asset) => asset.id == id),
        label: tr('delete.assetUndo'),
        action: () => deleteAsset(id),
      );

  Future<bool> deleteWishWithUndo(String id) => _runDestructiveWithUndo(
        exists: wishes.any((wish) => wish.id == id),
        label: tr('delete.wishUndo'),
        action: () => deleteWish(id),
      );

  Future<bool> deleteCategoryWithUndo(String id) => _runDestructiveWithUndo(
        exists: categories.any((category) => category.id == id),
        label: tr('delete.categoryUndo'),
        action: () => deleteCategory(id),
      );

  Future<bool> deleteTagWithUndo(String id) => _runDestructiveWithUndo(
        exists: tags.any((tag) => tag.id == id),
        label: tr('delete.tagUndo'),
        action: () => deleteTag(id),
      );

  Future<bool> deleteSnapshotWithUndo(String id) => _runDestructiveWithUndo(
        exists: snapshots.any((snapshot) => snapshot.id == id),
        label: tr('delete.snapshotUndo'),
        action: () => deleteSnapshot(id),
      );

  Future<bool> clearAllAndSeedWithUndo() async {
    if (_destructiveMutationInFlight) return false;
    _destructiveMutationInFlight = true;
    try {
      await createSnapshot(tlf('清空前快照 {date}', {'date': dateStamp()}));
      final before = exportJson();
      await clearAllAndSeed();
      _rememberUndo(tr('delete.resetUndo'), before);
      return true;
    } finally {
      _destructiveMutationInFlight = false;
    }
  }

  Future<bool> undoLastAction() async {
    final payload = _undoPayload;
    if (payload == null || _undoInFlight) return false;
    _undoInFlight = true;
    final previous = exportMap();
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map) return false;
      importMap(Map<String, dynamic>.from(decoded));
      await _enqueueSnapshot(jsonEncode(exportMap()));
      _undoPayload = null;
      _undoLabel = null;
      _invalidateAnalytics();
      _notifyHomeChanged();
      return true;
    } catch (_) {
      try {
        importMap(previous);
        await _enqueueSnapshot(jsonEncode(previous));
      } catch (_) {}
      return false;
    } finally {
      _undoInFlight = false;
    }
  }

  Future<void> deleteAsset(String id) async {
    assets.removeWhere((a) => a.id == id);
    for (var i = 0; i < wishes.length; i++) {
      if (wishes[i].convertedAssetId == id) {
        wishes[i] = wishes[i].copyWith(
          archived: false,
          clearConvertedAt: true,
          clearConvertedAssetId: true,
        );
      }
    }
    for (var i = recoveryRecords.length - 1; i >= 0; i--) {
      final record = recoveryRecords[i];
      if (!record.assetIds.contains(id)) continue;
      final remainingIds = record.assetIds.where((item) => item != id).toList();
      if (remainingIds.isEmpty) {
        recoveryRecords.removeAt(i);
      } else {
        recoveryRecords[i] = record.copyWith(assetIds: remainingIds);
      }
    }
    await save();
    _invalidateAnalytics();
    _notifyHomeChanged();
  }

  Future<void> upsertWish(Wish wish) async {
    _validateDomain(DomainValidators.wish(_wishValidationInput(wish)));
    final i = wishes.indexWhere((e) => e.id == wish.id);
    if (i >= 0) {
      wishes[i] = wish;
    } else {
      wishes.add(wish);
    }
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> deleteWish(String id) async {
    wishes.removeWhere((w) => w.id == id);
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  DateTime _wishConversionPurchaseDate(Wish wish, DateTime convertedAt) {
    var purchaseDate = dateOnly(convertedAt);
    for (final addon in wish.addons) {
      final addonDate = addon.purchaseDate;
      if (addon.followParentPurchaseDate || addonDate == null) continue;
      final candidate = dateOnly(addonDate);
      if (candidate.isBefore(purchaseDate)) purchaseDate = candidate;
    }
    return purchaseDate;
  }

  Future<String?> convertWishToAsset(String wishId) async {
    final index = wishes.indexWhere((w) => w.id == wishId);
    if (index < 0) return null;
    final wish = wishes[index];
    final convertedAssetId = wish.convertedAssetId;
    if (convertedAssetId != null &&
        assets.any((asset) => asset.id == convertedAssetId)) {
      return convertedAssetId;
    }
    final convertedAt = DateTime.now();
    final assetId = newId('asset');
    final asset = Asset(
      id: assetId,
      name: wish.name,
      iconValue: wish.iconValue,
      price: wish.expectedPrice,
      purchaseDate: _wishConversionPurchaseDate(wish, convertedAt),
      categoryId: wish.categoryId,
      tagIds: List.of(wish.tagIds),
      addons: wish.addons.map((addon) => addon.copyWith()).toList(),
      note: wish.note,
      status: AssetStatus.serving,
      includeInTotal: true,
      includeInDailyCost: true,
      retiredAt: null,
      soldAt: null,
      soldPrice: null,
      targetMode: TargetMode.none,
      targetDailyCost: null,
      targetDate: null,
      targetCustomDays: null,
      expiresAt: null,
      remindBeforeDays: null,
      createdAt: wish.createdAt,
      updatedAt: convertedAt,
    );
    _validateDomain(DomainValidators.asset(_assetValidationInput(asset)));
    final previousAssets = List<Asset>.of(assets);
    final previousWishes = List<Wish>.of(wishes);
    try {
      assets.add(asset);
      wishes[index] = wish.copyWith(
          archived: true, convertedAt: convertedAt, convertedAssetId: assetId);
      await save();
    } catch (_) {
      assets
        ..clear()
        ..addAll(previousAssets);
      wishes
        ..clear()
        ..addAll(previousWishes);
      rethrow;
    }
    _invalidateAnalytics();
    _notifyHomeChanged();
    return assetId;
  }

  Future<void> upsertCategory(Category item) async {
    _validateDomain(DomainValidators.label(item.name));
    final i = categories.indexWhere((e) => e.id == item.id);
    if (i >= 0) {
      categories[i] = item;
    } else {
      categories.add(item);
    }
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    await save();
    _invalidateAnalytics();
    _notifyHomeChanged();
  }

  Future<void> deleteCategory(String id) async {
    categories.removeWhere((e) => e.id == id);
    for (var i = 0; i < assets.length; i++) {
      final a = assets[i];
      if (a.categoryId == id) {
        assets[i] = Asset(
          id: a.id,
          name: a.name,
          iconValue: a.iconValue,
          valueMode: a.valueMode,
          price: a.price,
          purchaseDate: a.purchaseDate,
          categoryId: null,
          tagIds: a.tagIds,
          addons: a.addons,
          note: a.note,
          status: a.status,
          includeInTotal: a.includeInTotal,
          includeInDailyCost: a.includeInDailyCost,
          retiredAt: a.retiredAt,
          soldAt: a.soldAt,
          soldPrice: a.soldPrice,
          targetMode: a.targetMode,
          targetDailyCost: a.targetDailyCost,
          targetDate: a.targetDate,
          targetCustomDays: a.targetCustomDays,
          expiresAt: a.expiresAt,
          remindBeforeDays: a.remindBeforeDays,
          createdAt: a.createdAt,
          updatedAt: DateTime.now(),
        );
      }
    }
    for (var i = 0; i < wishes.length; i++) {
      if (wishes[i].categoryId == id) {
        wishes[i] = wishes[i].copyWith(clearCategoryId: true);
      }
    }
    await save();
    _invalidateAnalytics();
    _notifyHomeChanged();
  }

  Future<void> upsertTag(Tag item) async {
    _validateDomain(DomainValidators.label(item.name));
    final i = tags.indexWhere((e) => e.id == item.id);
    if (i >= 0) {
      tags[i] = item;
    } else {
      tags.add(item);
    }
    tags.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> deleteTag(String id) async {
    tags.removeWhere((e) => e.id == id);
    for (var i = 0; i < assets.length; i++) {
      if (assets[i].tagIds.contains(id))
        assets[i] = assets[i]
            .copyWith(tagIds: assets[i].tagIds.where((e) => e != id).toList());
    }
    for (var i = 0; i < wishes.length; i++) {
      if (wishes[i].tagIds.contains(id)) {
        wishes[i] = wishes[i]
            .copyWith(tagIds: wishes[i].tagIds.where((e) => e != id).toList());
      }
    }
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> markAssetServing(String id) async {
    final i = assets.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = assets[i];
    assets[i] = Asset(
      id: a.id,
      name: a.name,
      iconValue: a.iconValue,
      valueMode: a.valueMode,
      price: a.price,
      purchaseDate: a.purchaseDate,
      categoryId: a.categoryId,
      tagIds: a.tagIds,
      addons: a.addons,
      note: a.note,
      status: AssetStatus.serving,
      includeInTotal: a.includeInTotal,
      includeInDailyCost: a.includeInDailyCost,
      retiredAt: null,
      soldAt: null,
      soldPrice: null,
      targetMode: a.targetMode,
      targetDailyCost: a.targetDailyCost,
      targetDate: a.targetDate,
      targetCustomDays: a.targetCustomDays,
      expiresAt: a.expiresAt,
      remindBeforeDays: a.remindBeforeDays,
      createdAt: a.createdAt,
      updatedAt: DateTime.now(),
    );
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> markAssetRetired(String id, {DateTime? retiredAt}) async {
    final i = assets.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = assets[i];
    assets[i] = Asset(
      id: a.id,
      name: a.name,
      iconValue: a.iconValue,
      valueMode: a.valueMode,
      price: a.price,
      purchaseDate: a.purchaseDate,
      categoryId: a.categoryId,
      tagIds: a.tagIds,
      addons: a.addons,
      note: a.note,
      status: AssetStatus.retired,
      includeInTotal: a.includeInTotal,
      includeInDailyCost: a.includeInDailyCost,
      retiredAt: retiredAt ?? DateTime.now(),
      soldAt: null,
      soldPrice: null,
      targetMode: a.targetMode,
      targetDailyCost: a.targetDailyCost,
      targetDate: a.targetDate,
      targetCustomDays: a.targetCustomDays,
      expiresAt: a.expiresAt,
      remindBeforeDays: a.remindBeforeDays,
      createdAt: a.createdAt,
      updatedAt: DateTime.now(),
    );
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> markAssetSold(String id,
      {required DateTime soldAt, required double soldPrice}) async {
    final i = assets.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = assets[i];
    assets[i] = Asset(
      id: a.id,
      name: a.name,
      iconValue: a.iconValue,
      valueMode: a.valueMode,
      price: a.price,
      purchaseDate: a.purchaseDate,
      categoryId: a.categoryId,
      tagIds: a.tagIds,
      addons: a.addons,
      note: a.note,
      status: AssetStatus.sold,
      includeInTotal: a.includeInTotal,
      includeInDailyCost: a.includeInDailyCost,
      retiredAt: a.retiredAt,
      soldAt: soldAt,
      soldPrice: soldPrice,
      targetMode: a.targetMode,
      targetDailyCost: a.targetDailyCost,
      targetDate: a.targetDate,
      targetCustomDays: a.targetCustomDays,
      expiresAt: a.expiresAt,
      remindBeforeDays: a.remindBeforeDays,
      createdAt: a.createdAt,
      updatedAt: DateTime.now(),
    );
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  List<Asset> dueSoonAssets({int limit = 5}) {
    final now = DateTime.now();
    final rows = assets.where((a) {
      if (a.expiresAt == null || a.status == AssetStatus.sold) return false;
      final days = a.expiresAt!.difference(now).inDays;
      return days >= 0 && days <= (a.remindBeforeDays ?? 7);
    }).toList()
      ..sort((a, b) => a.expiresAt!.compareTo(b.expiresAt!));
    return rows.take(limit).toList();
  }

  Future<void> createSnapshot(String label) async {
    final payload = exportJson(includeSnapshots: false);
    snapshots.insert(
        0,
        SnapshotRecord(
            id: newId('snapshot'),
            label:
                label.trim().isEmpty ? tr('store.localSnapshot') : label.trim(),
            payload: payload,
            createdAt: DateTime.now()));
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> deleteSnapshot(String id) async {
    snapshots.removeWhere((item) => item.id == id);
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> renameSnapshot(String id, String label) async {
    final nextLabel = label.trim();
    if (nextLabel.isEmpty) return;
    final index = snapshots.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final old = snapshots[index];
    snapshots[index] = SnapshotRecord(
        id: old.id,
        label: nextLabel,
        payload: old.payload,
        createdAt: old.createdAt);
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> applyRecommendedCategorySystem() async {
    final now = dateTimeStorageText(DateTime.now());
    final presets = <Map<String, String>>[
      {
        'id': 'cat_digital',
        'name': tr('store.catDigital'),
        'icon': '💻',
        'color': '#60A5FA'
      },
      {
        'id': 'cat_audio_video',
        'name': tr('store.catAudioVideo'),
        'icon': '🎧',
        'color': '#38BDF8'
      },
      {
        'id': 'cat_photo_creative',
        'name': tr('store.catPhotoCreative'),
        'icon': '📷',
        'color': '#A78BFA'
      },
      {
        'id': 'cat_game_hobby',
        'name': tr('store.catGameHobby'),
        'icon': '🎮',
        'color': '#F472B6'
      },
      {
        'id': 'cat_work_study',
        'name': tr('store.catWorkStudy'),
        'icon': '📚',
        'color': '#34D399'
      },
      {
        'id': 'cat_wear_style',
        'name': tr('store.catWearStyle'),
        'icon': '👕',
        'color': '#FB7185'
      },
      {
        'id': 'cat_home_life',
        'name': tr('store.catHomeLife'),
        'icon': '🏠',
        'color': '#FDBA74'
      },
      {
        'id': 'cat_transport',
        'name': tr('store.catTransport'),
        'icon': '🚗',
        'color': '#4ADE80'
      },
      {
        'id': 'cat_sport_health',
        'name': tr('store.catSportHealth'),
        'icon': '🏃',
        'color': '#A3E635'
      },
      {
        'id': 'cat_tools_repair',
        'name': tr('store.catToolsRepair'),
        'icon': '🧰',
        'color': '#FACC15'
      },
      {
        'id': 'cat_collection',
        'name': tr('store.catCollection'),
        'icon': '⭐',
        'color': '#818CF8'
      },
      {
        'id': 'cat_service',
        'name': tr('store.catService'),
        'icon': '💳',
        'color': '#94A3B8'
      },
    ];

    final aliases = <String, String>{
      tr('store.aliasPhone'): 'cat_digital',
      tr('store.aliasComputer'): 'cat_digital',
      tr('store.aliasTablet'): 'cat_digital',
      tr('store.aliasDigitalAccessories'): 'cat_digital',
      tr('store.aliasDigital'): 'cat_digital',
      tr('store.aliasEarphone'): 'cat_audio_video',
      tr('store.aliasAudio'): 'cat_audio_video',
      tr('store.aliasAv'): 'cat_audio_video',
      tr('store.aliasPhotography'): 'cat_photo_creative',
      tr('store.aliasCamera'): 'cat_photo_creative',
      tr('store.aliasLens'): 'cat_photo_creative',
      tr('store.aliasGame'): 'cat_game_hobby',
      tr('store.aliasEntertainment'): 'cat_game_hobby',
      tr('store.aliasHobby'): 'cat_game_hobby',
      tr('store.aliasStudy'): 'cat_work_study',
      tr('store.aliasOffice'): 'cat_work_study',
      tr('store.aliasBook'): 'cat_work_study',
      tr('store.aliasClothing'): 'cat_wear_style',
      tr('store.aliasOutfit'): 'cat_wear_style',
      tr('store.aliasShoesBags'): 'cat_wear_style',
      tr('store.aliasHome'): 'cat_home_life',
      tr('store.aliasAppliance'): 'cat_home_life',
      tr('store.aliasLife'): 'cat_home_life',
      tr('store.aliasTransport'): 'cat_transport',
      tr('store.aliasTravel'): 'cat_transport',
      tr('store.aliasTrip'): 'cat_transport',
      tr('store.aliasSport'): 'cat_sport_health',
      tr('store.aliasHealth'): 'cat_sport_health',
      tr('store.aliasTool'): 'cat_tools_repair',
      tr('store.aliasRepair'): 'cat_tools_repair',
      tr('store.aliasCollection'): 'cat_collection',
      tr('store.aliasMemorial'): 'cat_collection',
      tr('store.aliasSubscribe'): 'cat_service',
      tr('store.aliasSoftware'): 'cat_service',
      tr('store.aliasService'): 'cat_service',
    };

    final oldToNew = <String, String>{};
    for (final old in List<Category>.from(categories)) {
      for (final entry in aliases.entries) {
        if (old.name.contains(entry.key)) {
          oldToNew[old.id] = entry.value;
          break;
        }
      }
    }

    for (var i = 0; i < presets.length; i++) {
      final preset = presets[i];
      final existingIndex = categories.indexWhere(
          (item) => item.id == preset['id'] || item.name == preset['name']);
      final item = Category(
        id: preset['id']!,
        name: preset['name']!,
        icon: preset['icon']!,
        color: preset['color']!,
        sortOrder: i,
        createdAt:
            existingIndex >= 0 ? categories[existingIndex].createdAt : now,
        updatedAt: now,
      );
      if (existingIndex >= 0) {
        categories[existingIndex] = item;
      } else {
        categories.add(item);
      }
    }

    for (var i = 0; i < assets.length; i++) {
      final target = oldToNew[assets[i].categoryId];
      if (target != null) assets[i] = assets[i].copyWith(categoryId: target);
    }
    for (var i = 0; i < wishes.length; i++) {
      final target = oldToNew[wishes[i].categoryId];
      if (target != null) wishes[i] = wishes[i].copyWith(categoryId: target);
    }

    final presetIds = presets.map((e) => e['id']!).toSet();
    categories.removeWhere((item) =>
        oldToNew.containsKey(item.id) && !presetIds.contains(item.id));
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    await save();
    _invalidateAnalytics();
    _notifyHomeChanged();
  }

  Map<String, dynamic> prepareRestoreJson(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      throw const PersistedDataException(
        'data_invalid_object',
        'Restore payload must be a JSON object',
      );
    }
    return migratePersistedMap(Map<String, dynamic>.from(decoded));
  }

  Future<bool> restoreFromJson(
    String raw, {
    bool createPreRestoreSnapshot = false,
    String? preRestoreLabel,
  }) async {
    if (_restoreInFlight) return false;
    Map<String, dynamic> prepared;
    Map<String, dynamic> decoded;
    try {
      final value = jsonDecode(raw);
      if (value is! Map) return false;
      decoded = Map<String, dynamic>.from(value);
      prepared = prepareRestoreJson(raw);
    } catch (_) {
      return false;
    }

    _restoreInFlight = true;
    Map<String, dynamic>? previous;
    try {
      if (createPreRestoreSnapshot) {
        await createSnapshot(
            preRestoreLabel ?? tlf('恢复前快照 {date}', {'date': dateStamp()}));
      }
      previous = exportMap();
      // Snapshot payloads intentionally omit nested snapshots. Keep the
      // current snapshot history, including the automatic pre-restore one,
      // instead of silently deleting the history during a data restore.
      if (!decoded.containsKey('snapshots')) {
        prepared['snapshots'] = previous['snapshots'];
      }
      importMap(prepared);
      await _enqueueSnapshot(jsonEncode(exportMap()));
      _clearUndo();
      _invalidateAnalytics();
      _notifyHomeChanged();
      return true;
    } catch (_) {
      try {
        final rollback = previous;
        if (rollback != null) {
          importMap(rollback);
          await _enqueueSnapshot(jsonEncode(rollback));
        } else if (_lastValidatedSnapshot != null) {
          importMap(prepareRestoreJson(_lastValidatedSnapshot!));
          await _enqueueSnapshot(jsonEncode(exportMap()));
        }
      } catch (_) {}
      return false;
    } finally {
      _restoreInFlight = false;
    }
  }

  Future<bool> restoreSnapshot(SnapshotRecord record) => restoreFromJson(
        record.payload,
        createPreRestoreSnapshot: true,
        preRestoreLabel: tlf('恢复前快照 {date}', {'date': dateStamp()}),
      );

  Future<void> clearAllAndSeed() async {
    initializeEmptyData();
    await save();
    _notifyHomeChanged();
  }
}
