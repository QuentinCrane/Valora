part of '../main.dart';

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

  const LifecycleEventItem(
      {required this.date,
      required this.title,
      required this.subtitle,
      required this.icon,
      required this.color});
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

class LocalSqliteStorage {
  static const MethodChannel _channel = MethodChannel('valora/local_store');
  const LocalSqliteStorage();

  Future<String> load() async {
    return await _channel.invokeMethod<String>('loadJson') ?? '';
  }

  Future<void> save(String json) async {
    final ok = await _channel.invokeMethod<bool>('saveJson', {'json': json});
    if (ok != true) {
      throw StateError(tr('store.localWriteFailed'));
    }
  }
}

class CloudSyncResult {
  final bool ok;
  final String message;
  final String? payload;
  const CloudSyncResult(
      {required this.ok, required this.message, this.payload});
}

class CloudSyncService {
  const CloudSyncService();

  Uri _buildUri(CloudSyncSettings settings, [String? overridePath]) {
    final rawBase = settings.serverUrl.trim();
    final base = rawBase.endsWith('/') ? rawBase : '$rawBase/';
    final safePath = (overridePath ?? settings.remotePath)
        .trim()
        .replaceAll(RegExp(r'^/+'), '');
    return Uri.parse(base).resolve(safePath);
  }

  String _basicAuth(CloudSyncSettings settings) {
    final token =
        base64Encode(utf8.encode('${settings.username}:${settings.password}'));
    return 'Basic $token';
  }

  Future<HttpClientResponse> _send(
      CloudSyncSettings settings, String method, Uri uri,
      {String? body,
      String contentType = 'application/json; charset=utf-8'}) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 16);
    try {
      final req = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 18));
      req.followRedirects = true;
      req.headers
          .set(HttpHeaders.userAgentHeader, 'Valora-Assets/1.0 Flutter WebDAV');
      if (settings.username.trim().isNotEmpty || settings.password.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, _basicAuth(settings));
      }
      if (body != null) {
        final bytes = utf8.encode(body);
        req.headers.set(HttpHeaders.contentTypeHeader, contentType);
        req.headers
            .set(HttpHeaders.contentLengthHeader, bytes.length.toString());
        req.add(bytes);
      }
      return await req.close().timeout(const Duration(seconds: 28));
    } finally {
      client.close(force: false);
    }
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
        final resp = await _send(settings, 'MKCOL', uri);
        await resp.drain();
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
      final xml =
          '<?xml version="1.0" encoding="utf-8" ?><propfind xmlns="DAV:"><prop><displayname/></prop></propfind>';
      final resp = await _send(settings, 'PROPFIND', root,
          body: xml, contentType: 'application/xml; charset=utf-8');
      final text = await utf8.decoder.bind(resp).join();
      final ok = resp.statusCode == 207 ||
          resp.statusCode == 200 ||
          resp.statusCode == 301 ||
          resp.statusCode == 302;
      return CloudSyncResult(
          ok: ok,
          message: ok
              ? '${tr('store.cloudTestOk')}（HTTP ${resp.statusCode}）'
              : '${tr('store.cloudTestFail')}：HTTP ${resp.statusCode} ${text.take(120)}');
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
      await _ensureWebDavFolders(settings);
      final uri = _buildUri(settings);
      final resp = await _send(settings, 'PUT', uri, body: json);
      final text = await utf8.decoder.bind(resp).join();
      final ok = resp.statusCode >= 200 && resp.statusCode < 300;
      return CloudSyncResult(
          ok: ok,
          message: ok
              ? '${tr('store.cloudUploaded')}：${settings.remotePath}'
              : '${tr('store.uploadFailed')}：HTTP ${resp.statusCode} ${text.take(120)}');
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
      final text = await utf8.decoder.bind(resp).join();
      final ok = resp.statusCode >= 200 &&
          resp.statusCode < 300 &&
          text.trim().startsWith('{');
      return CloudSyncResult(
          ok: ok,
          message: ok
              ? tr('store.cloudDownloaded')
              : '${tr('store.downloadFailed')}：HTTP ${resp.statusCode} ${text.take(120)}',
          payload: ok ? text : null);
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

class AppStore extends ChangeNotifier {
  final LocalSqliteStorage _storage = const LocalSqliteStorage();
  final CloudSyncService _cloud = const CloudSyncService();

  AppSettings settings = const AppSettings();
  final List<Category> categories = [];
  final List<Tag> tags = [];
  final List<Asset> assets = [];
  final List<Wish> wishes = [];
  final List<ValueRecoveryRecord> recoveryRecords = [];
  final List<SnapshotRecord> snapshots = [];

  String query = '';
  String statusFilter = 'all';
  String categoryFilter = 'all';
  bool taggedOnly = false;
  bool targetedOnly = false;
  SortMode sortMode = SortMode.dailyCost;
  HomeViewMode viewMode = HomeViewMode.grid;
  bool wishShowArchived = false;

  String? _analyticsSnapshotKey;
  AnalyticsSnapshot? _analyticsSnapshot;

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

  Future<void> load() async {
    try {
      final raw = await _storage.load();
      if (raw.trim().isEmpty) {
        initializeEmptyData();
        await save();
      } else {
        importMap(Map<String, dynamic>.from(jsonDecode(raw)));
      }
    } catch (_) {
      initializeEmptyData();
    }
    viewMode = settings.defaultHomeViewMode;
    configureRuntimeSettings(settings);
    if (settings.cloudSync.syncOnLaunch && settings.cloudSync.enabled) {
      Future<void>(() async {
        await downloadCloudBackup(silent: true);
      });
    }
    _invalidateAnalytics();
    notifyListeners();
  }

  void importMap(Map<String, dynamic> data) {
    final nextSettings = AppSettings.fromMap(
        Map<String, dynamic>.from(data['settings'] ?? data));
    final nextCategories = ((data['categories'] as List?) ?? [])
        .map((e) => Category.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextTags = ((data['tags'] as List?) ?? [])
        .map((e) => Tag.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextAssets = ((data['assets'] as List?) ?? [])
        .map((e) => Asset.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextWishes = ((data['wishes'] as List?) ?? [])
        .map((e) => Wish.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextRecoveryRecords = ((data['recoveryRecords'] as List?) ?? [])
        .map((e) => ValueRecoveryRecord.fromMap(Map<String, dynamic>.from(e)))
        .toList();
    final nextSnapshots = ((data['snapshots'] as List?) ?? [])
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
    snapshots
      ..clear()
      ..addAll(nextSnapshots);
    _invalidateAnalytics();
  }

  Map<String, dynamic> exportMap({bool includeSnapshots = true}) => {
        'version': 2,
        'generatedBy': 'valora-flutter-migration',
        'settings': settings.toMap(),
        'categories': categories.map((e) => e.toMap()).toList(),
        'tags': tags.map((e) => e.toMap()).toList(),
        'assets': assets.map((e) => e.toMap()).toList(),
        'wishes': wishes.map((e) => e.toMap()).toList(),
        'recoveryRecords': recoveryRecords.map((e) => e.toMap()).toList(),
        if (includeSnapshots)
          'snapshots': snapshots.map((e) => e.toMap()).toList(),
      };

  String exportJson({bool includeSnapshots = true}) =>
      const JsonEncoder.withIndent('  ')
          .convert(exportMap(includeSnapshots: includeSnapshots));

  Future<void> save() async {
    final snapshot = jsonEncode(exportMap());
    await _storage.save(snapshot);
    final echoed = await _storage.load();
    if (echoed != snapshot) {
      throw StateError(tr('store.sqliteVerifyFailed'));
    }
    NativeBridge.updateHomeWidget(
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
    );
    if (settings.cloudSync.autoUploadOnSave && settings.cloudSync.enabled) {
      Future<void>(() async {
        await uploadCloudBackup(silent: true);
      });
    }
  }

  Future<void> updateCloudSyncSettings(CloudSyncSettings value) async {
    settings = settings.copyWith(cloudSync: value);
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<CloudSyncResult> testCloudConnection() =>
      _cloud.test(settings.cloudSync);

  Future<CloudSyncResult> uploadCloudBackup({bool silent = false}) async {
    final result = await _cloud.upload(settings.cloudSync, exportJson());
    if (result.ok) {
      settings = settings.copyWith(
          cloudSync: settings.cloudSync.copyWith(lastUploadAt: DateTime.now()));
      await _storage.save(jsonEncode(exportMap()));
      _invalidateAnalytics();
      if (!silent) notifyListeners();
    }
    return result;
  }

  Future<CloudSyncResult> downloadCloudBackup({bool silent = false}) async {
    final result = await _cloud.download(settings.cloudSync);
    if (result.ok && result.payload != null) {
      final localCloud = settings.cloudSync;
      importMap(Map<String, dynamic>.from(jsonDecode(result.payload!)));
      settings = settings.copyWith(
          cloudSync: localCloud.copyWith(lastDownloadAt: DateTime.now()));
      await save();
      if (!silent) notifyListeners();
    }
    return result;
  }

  void initializeEmptyData() {
    categories.clear();
    tags.clear();
    assets.clear();
    wishes.clear();
    recoveryRecords.clear();
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
      final name = categoryName(asset.categoryId);
      result[name] = (result[name] ?? 0) + asset.assetValue;
    }
    return result;
  }

  Map<String, int> tagDistribution() {
    final result = <String, int>{};
    for (final asset in assets) {
      for (final id in asset.tagIds) {
        final name = tagName(id);
        result[name] = (result[name] ?? 0) + 1;
      }
    }
    return result;
  }

  double getTotalPurchaseCost() => assets
      .where((a) => !a.isPriceless)
      .fold(0.0, (sum, asset) => sum + asset.price + asset.addonTotal);

  double getActiveAssetValue() => assets
      .where((a) => a.status == AssetStatus.serving)
      .fold(0.0, (sum, a) => sum + a.assetValue);

  double getSoldLossOrGain() =>
      assets.where((a) => a.status == AssetStatus.sold && !a.isPriceless).fold(
          0.0,
          (sum, a) => sum + ((a.soldPrice ?? 0) - a.price - a.dailyAddonTotal));

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
        var serviceEnd = cursor;
        if (asset.status == AssetStatus.retired &&
            asset.retiredAt != null &&
            !dateOnly(asset.retiredAt!).isAfter(cursor)) {
          serviceEnd = dateOnly(asset.retiredAt!);
        }
        if (asset.status == AssetStatus.sold &&
            asset.soldAt != null &&
            !dateOnly(asset.soldAt!).isAfter(cursor)) {
          serviceEnd = dateOnly(asset.soldAt!);
        }
        final days = diffDaysInclusive(purchaseDate, serviceEnd);
        final recovered = asset.status == AssetStatus.sold &&
                asset.soldAt != null &&
                !dateOnly(asset.soldAt!).isAfter(cursor)
            ? (asset.soldPrice ?? 0)
            : 0.0;
        final netCost = asset.price + asset.dailyAddonTotal - recovered;
        activeDailyCosts.add(netCost / math.max(days, 1));
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
        ));
      }
      if (asset.status == AssetStatus.sold && asset.soldAt != null) {
        rows.add(LifecycleEventItem(
          date: asset.soldAt!,
          title: '${tr('store.eventSold')} ${asset.name}',
          subtitle:
              '${tr('store.eventRecovered')} ${money(asset.soldPrice ?? 0, settings)}${tr('store.eventNetCost')} ${money(asset.netCost, settings)}',
          icon: Icons.swap_horiz_rounded,
          color: const Color(0xFF4ADE80),
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
      ));
    }
    rows.sort((a, b) => b.date.compareTo(a.date));
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
    double result = 0;
    for (final item in recoveryRecords) {
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

  double getAssetNetConsumptionAfterRecovery(Asset asset) => asset.isPriceless
      ? 0
      : math.max(
          asset.price +
              asset.dailyAddonTotal -
              getAssetTotalRecoveredValue(asset),
          0);

  double getLifecycleRecoveredValue() =>
      getSoldRecoveredValue() + getRecoveryIncomeTotal();

  double getLifecycleNetConsumption() => math.max(
      assets.fold(0.0, (sum, a) => sum + math.max(a.netCost, 0)) -
          getRecoveryIncomeTotal(),
      0);

  List<Asset> pricelessAssets({int limit = 5}) {
    final rows = assets
        .where((a) => a.isPriceless && a.status != AssetStatus.sold)
        .toList()
      ..sort((a, b) => b.serviceDays.compareTo(a.serviceDays));
    return rows.take(limit).toList();
  }

  List<ValueRecoveryRecord> recoveryRecordsForAsset(String assetId) =>
      recoveryRecords.where((e) => e.assetIds.contains(assetId)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));

  Future<void> addRecoveryRecord(ValueRecoveryRecord record) async {
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
    query = value;
    notifyListeners();
  }

  void setStatusFilter(String value) {
    statusFilter = value;
    notifyListeners();
  }

  void setCategoryFilter(String value) {
    categoryFilter = value;
    notifyListeners();
  }

  void setSortMode(SortMode value) {
    sortMode = value;
    notifyListeners();
  }

  void setViewMode(HomeViewMode value) {
    viewMode = value;
    updateSettings(settings.copyWith(defaultHomeViewMode: value));
  }

  void setAdvancedFilters({bool? taggedOnlyValue, bool? targetedOnlyValue}) {
    taggedOnly = taggedOnlyValue ?? taggedOnly;
    targetedOnly = targetedOnlyValue ?? targetedOnly;
    notifyListeners();
  }

  void resetFilters() {
    query = '';
    statusFilter = 'all';
    categoryFilter = 'all';
    taggedOnly = false;
    targetedOnly = false;
    notifyListeners();
  }

  void setWishArchivedFilter(bool value) {
    wishShowArchived = value;
    notifyListeners();
  }

  Future<void> updateSettings(AppSettings next) async {
    settings = next;
    configureRuntimeSettings(settings);
    await save();
    _invalidateAnalytics();
    notifyListeners();
  }

  Future<void> upsertAsset(Asset asset) async {
    final i = assets.indexWhere((e) => e.id == asset.id);
    if (i >= 0) {
      assets[i] = asset;
    } else {
      assets.add(asset);
    }
    await save();
    _invalidateAnalytics();
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> upsertWish(Wish wish) async {
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

  Future<String?> convertWishToAsset(String wishId) async {
    final index = wishes.indexWhere((w) => w.id == wishId);
    if (index < 0) return null;
    final wish = wishes[index];
    final convertedAssetId = wish.convertedAssetId;
    if (convertedAssetId != null &&
        assets.any((asset) => asset.id == convertedAssetId)) {
      return convertedAssetId;
    }
    final assetId = newId('asset');
    final asset = Asset(
      id: assetId,
      name: wish.name,
      iconValue: wish.iconValue,
      price: wish.expectedPrice,
      purchaseDate: DateTime.now(),
      categoryId: wish.categoryId,
      tagIds: List.of(wish.tagIds),
      addons: wish.addons.map((e) => e).toList(),
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
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    assets.add(asset);
    wishes[index] = wish.copyWith(
        archived: true, convertedAt: DateTime.now(), convertedAssetId: assetId);
    await save();
    _invalidateAnalytics();
    notifyListeners();
    return assetId;
  }

  Future<void> upsertCategory(Category item) async {
    final i = categories.indexWhere((e) => e.id == item.id);
    if (i >= 0) {
      categories[i] = item;
    } else {
      categories.add(item);
    }
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    await save();
    _invalidateAnalytics();
    notifyListeners();
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
    notifyListeners();
  }

  Future<void> upsertTag(Tag item) async {
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
    final now = DateTime.now().toIso8601String();
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
    notifyListeners();
  }

  Future<bool> restoreFromJson(String raw) async {
    final previous = exportMap();
    try {
      importMap(Map<String, dynamic>.from(jsonDecode(raw)));
      await save();
      _invalidateAnalytics();
      notifyListeners();
      return true;
    } catch (_) {
      try {
        importMap(previous);
      } catch (_) {}
      return false;
    }
  }

  Future<bool> restoreSnapshot(SnapshotRecord record) =>
      restoreFromJson(record.payload);

  Future<void> clearAllAndSeed() async {
    initializeEmptyData();
    await save();
    notifyListeners();
  }
}
