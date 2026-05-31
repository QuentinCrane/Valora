part of '../main.dart';

class AssetInsight {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const AssetInsight({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });
}

class AssetLeakItem {
  final Asset asset;
  final String reason;
  final String suggestion;
  final double score;

  const AssetLeakItem({
    required this.asset,
    required this.reason,
    required this.suggestion,
    required this.score,
  });
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

  const LifecycleEventItem({
    required this.date,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
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
    required this.insights,
  });
}

class LocalSqliteStorage {
  static const MethodChannel _channel = MethodChannel('valora/local_store');
  const LocalSqliteStorage();

  Future<String> load() async {
    try {
      return await _channel.invokeMethod<String>('loadJson') ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> save(String json) async {
    final ok = await _channel.invokeMethod<bool>('saveJson', {'json': json});
    if (ok != true) {
      throw StateError('本地数据写入失败');
    }
  }
}

class CloudSyncResult {
  final bool ok;
  final String message;
  final String? payload;
  const CloudSyncResult({
    required this.ok,
    required this.message,
    this.payload,
  });
}

class CloudSyncService {
  const CloudSyncService();

  Uri _buildUri(CloudSyncSettings settings, [String? overridePath]) {
    final rawBase = settings.serverUrl.trim();
    final base = rawBase.endsWith('/') ? rawBase : '$rawBase/';
    final safePath = (overridePath ?? settings.remotePath).trim().replaceAll(
      RegExp(r'^/+'),
      '',
    );
    return Uri.parse(base).resolve(safePath);
  }

  String _basicAuth(CloudSyncSettings settings) {
    final token = base64Encode(
      utf8.encode('${settings.username}:${settings.password}'),
    );
    return 'Basic $token';
  }

  Future<HttpClientResponse> _send(
    CloudSyncSettings settings,
    String method,
    Uri uri, {
    String? body,
    String contentType = 'application/json; charset=utf-8',
  }) async {
    final client = HttpClient()
      ..connectionTimeout = const Duration(seconds: 16);
    try {
      final req = await client
          .openUrl(method, uri)
          .timeout(const Duration(seconds: 18));
      req.followRedirects = true;
      req.headers.set(
        HttpHeaders.userAgentHeader,
        'Valora-Assets/1.0 Flutter WebDAV',
      );
      if (settings.username.trim().isNotEmpty || settings.password.isNotEmpty) {
        req.headers.set(HttpHeaders.authorizationHeader, _basicAuth(settings));
      }
      if (body != null) {
        final bytes = utf8.encode(body);
        req.headers.set(HttpHeaders.contentTypeHeader, contentType);
        req.headers.set(
          HttpHeaders.contentLengthHeader,
          bytes.length.toString(),
        );
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
      return const CloudSyncResult(
        ok: false,
        message: '请先启用并填写 WebDAV / Nextcloud / 坚果云地址',
      );
    try {
      final root = Uri.parse(
        settings.serverUrl.trim().endsWith('/')
            ? settings.serverUrl.trim()
            : '${settings.serverUrl.trim()}/',
      );
      final xml =
          '<?xml version="1.0" encoding="utf-8" ?><propfind xmlns="DAV:"><prop><displayname/></prop></propfind>';
      final resp = await _send(
        settings,
        'PROPFIND',
        root,
        body: xml,
        contentType: 'application/xml; charset=utf-8',
      );
      final text = await utf8.decoder.bind(resp).join();
      final ok =
          resp.statusCode == 207 ||
          resp.statusCode == 200 ||
          resp.statusCode == 301 ||
          resp.statusCode == 302;
      return CloudSyncResult(
        ok: ok,
        message: ok
            ? '云端连接成功（HTTP ${resp.statusCode}）'
            : '云端连接异常：HTTP ${resp.statusCode} ${text.take(120)}',
      );
    } catch (e) {
      return CloudSyncResult(ok: false, message: '连接失败：$e');
    }
  }

  Future<CloudSyncResult> upload(
    CloudSyncSettings settings,
    String json,
  ) async {
    if (!settings.enabled)
      return const CloudSyncResult(ok: false, message: '请先配置云端同步');
    try {
      await _ensureWebDavFolders(settings);
      final uri = _buildUri(settings);
      final resp = await _send(settings, 'PUT', uri, body: json);
      final text = await utf8.decoder.bind(resp).join();
      final ok = resp.statusCode >= 200 && resp.statusCode < 300;
      return CloudSyncResult(
        ok: ok,
        message: ok
            ? '已上传到云端：${settings.remotePath}'
            : '上传失败：HTTP ${resp.statusCode} ${text.take(120)}',
      );
    } catch (e) {
      return CloudSyncResult(ok: false, message: '上传失败：$e');
    }
  }

  Future<CloudSyncResult> download(CloudSyncSettings settings) async {
    if (!settings.enabled)
      return const CloudSyncResult(ok: false, message: '请先配置云端同步');
    try {
      final resp = await _send(settings, 'GET', _buildUri(settings));
      final text = await utf8.decoder.bind(resp).join();
      final ok =
          resp.statusCode >= 200 &&
          resp.statusCode < 300 &&
          text.trim().startsWith('{');
      return CloudSyncResult(
        ok: ok,
        message: ok
            ? '已从云端读取备份'
            : '读取失败：HTTP ${resp.statusCode} ${text.take(120)}',
        payload: ok ? text : null,
      );
    } catch (e) {
      return CloudSyncResult(ok: false, message: '读取失败：$e');
    }
  }
}

extension _StringTake on String {
  String take(int max) => length <= max ? this : substring(0, max);
}

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
    final topDaily = [...assets]
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
      categoryDistribution: Map<String, double>.unmodifiable(
        categoryDistribution(),
      ),
      tagDistribution: Map<String, int>.unmodifiable(tagDistribution()),
      topDailyAssets: List<Asset>.unmodifiable(topDaily),
      valueTrend: List<AssetTrendPoint>.unmodifiable(assetValueTrend()),
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
    settings = AppSettings.fromMap(
      Map<String, dynamic>.from(data['settings'] ?? data),
    );
    categories
      ..clear()
      ..addAll(
        ((data['categories'] as List?) ?? []).map(
          (e) => Category.fromMap(Map<String, dynamic>.from(e)),
        ),
      );
    tags
      ..clear()
      ..addAll(
        ((data['tags'] as List?) ?? []).map(
          (e) => Tag.fromMap(Map<String, dynamic>.from(e)),
        ),
      );
    assets
      ..clear()
      ..addAll(
        ((data['assets'] as List?) ?? []).map(
          (e) => Asset.fromMap(Map<String, dynamic>.from(e)),
        ),
      );
    wishes
      ..clear()
      ..addAll(
        ((data['wishes'] as List?) ?? []).map(
          (e) => Wish.fromMap(Map<String, dynamic>.from(e)),
        ),
      );
    recoveryRecords
      ..clear()
      ..addAll(
        ((data['recoveryRecords'] as List?) ?? []).map(
          (e) => ValueRecoveryRecord.fromMap(Map<String, dynamic>.from(e)),
        ),
      );
    snapshots
      ..clear()
      ..addAll(
        ((data['snapshots'] as List?) ?? []).map(
          (e) => SnapshotRecord.fromMap(Map<String, dynamic>.from(e)),
        ),
      );
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    tags.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    if (assets.isEmpty && wishes.isEmpty) snapshots.clear();
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
    if (includeSnapshots) 'snapshots': snapshots.map((e) => e.toMap()).toList(),
  };

  String exportJson({bool includeSnapshots = true}) =>
      const JsonEncoder.withIndent(
        '  ',
      ).convert(exportMap(includeSnapshots: includeSnapshots));

  Future<void> save() async {
    final snapshot = jsonEncode(exportMap());
    await _storage.save(snapshot);
    final echoed = await _storage.load();
    if (echoed != snapshot) {
      throw StateError('本地 SQLite 写入校验失败：写入后读回内容不一致');
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
        cloudSync: settings.cloudSync.copyWith(lastUploadAt: DateTime.now()),
      );
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
        cloudSync: localCloud.copyWith(lastDownloadAt: DateTime.now()),
      );
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

  String categoryName(String? id) => categoryById(id)?.name ?? '未分类';
  String categoryIcon(String? id) => categoryById(id)?.icon ?? '📦';

  double getTotalAssetValue() => assets
      .where(
        (a) =>
            settings.includeRetiredInTotal || a.status != AssetStatus.retired,
      )
      .fold(0, (sum, a) => sum + a.assetValue);
  double getAverageDailyCost() {
    final list = assets.where((a) => a.includeInDailyCost).toList();
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
        ...asset.tagIds.map((id) => tagById(id)?.name ?? ''),
      ].join(' ').toLowerCase();
      return q.isEmpty || haystack.contains(q);
    }).toList();
    switch (sortMode) {
      case SortMode.dailyCost:
        list.sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
        break;
      case SortMode.price:
        list.sort((a, b) => b.price.compareTo(a.price));
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
          asset.status == AssetStatus.retired)
        continue;
      final name = categoryName(asset.categoryId);
      result[name] = (result[name] ?? 0) + asset.assetValue;
    }
    return result;
  }

  Map<String, int> tagDistribution() {
    final result = <String, int>{};
    for (final asset in assets) {
      for (final id in asset.tagIds) {
        final name = tagById(id)?.name ?? id;
        result[name] = (result[name] ?? 0) + 1;
      }
    }
    return result;
  }

  double getTotalPurchaseCost() =>
      assets.fold(0.0, (sum, asset) => sum + asset.price + asset.addonTotal);

  double getActiveAssetValue() => assets
      .where((a) => a.status == AssetStatus.serving)
      .fold(0.0, (sum, a) => sum + a.assetValue);

  double getSoldLossOrGain() => assets
      .where((a) => a.status == AssetStatus.sold)
      .fold(
        0.0,
        (sum, a) => sum + ((a.soldPrice ?? 0) - a.price - a.dailyAddonTotal),
      );

  double getNetAssetPosition() =>
      getTotalAssetValue() +
      getLifecycleRecoveredValue() -
      getTotalPurchaseCost();

  List<AssetLeakItem> walletLeaks({int limit = 4}) {
    final avg = getAverageDailyCost();
    final rows = <AssetLeakItem>[];
    for (final asset in assets) {
      if (!asset.includeInDailyCost) continue;
      final isIdle =
          asset.status == AssetStatus.retired ||
          asset.tagIds.any((id) => (tagById(id)?.name ?? '').contains('吃灰'));
      final highDaily = avg > 0 && asset.dailyCost > avg * 1.35;
      final targetMiss =
          asset.targetMode != TargetMode.none &&
          asset.targetRatio < .55 &&
          asset.serviceDays > 30;
      final expiringSoon =
          asset.expiresAt != null &&
          asset.expiresAt!.difference(DateTime.now()).inDays >= 0 &&
          asset.expiresAt!.difference(DateTime.now()).inDays <=
              (asset.remindBeforeDays ?? 7);
      if (!isIdle && !highDaily && !targetMiss && !expiringSoon) continue;
      final score =
          asset.dailyCost * (isIdle ? 1.4 : 1.0) +
          (highDaily ? 8 : 0) +
          (targetMiss ? 5 : 0) +
          (expiringSoon ? 3 : 0);
      final reason = isIdle
          ? '闲置/吃灰仍在摊销'
          : highDaily
          ? '日均成本高于资产均值'
          : targetMiss
          ? '目标进度偏慢'
          : '临近到期需要处理';
      final suggestion = isIdle
          ? '考虑继续使用、转赠或二手流转，避免长期占用预算。'
          : highDaily
          ? '延长使用周期或复盘是否真的高频使用。'
          : targetMiss
          ? '检查目标是否过严，或给它安排明确使用场景。'
          : '提前决定续费、保修、退订或归档。';
      rows.add(
        AssetLeakItem(
          asset: asset,
          reason: reason,
          suggestion: suggestion,
          score: score,
        ),
      );
    }
    rows.sort((a, b) => b.score.compareTo(a.score));
    return rows.take(limit).toList();
  }

  List<AssetTrendPoint> assetValueTrend({int segments = 8}) {
    if (assets.isEmpty) return const [];
    final sorted = [...assets]
      ..sort((a, b) => a.purchaseDate.compareTo(b.purchaseDate));
    final start = DateTime(
      sorted.first.purchaseDate.year,
      sorted.first.purchaseDate.month,
      sorted.first.purchaseDate.day,
    );
    final end = DateTime.now();
    final totalDays = math.max(end.difference(start).inDays, 1);
    final step = math.max((totalDays / math.max(segments - 1, 1)).ceil(), 1);
    final points = <AssetTrendPoint>[];
    for (var i = 0; i < segments; i++) {
      final cursor = i == segments - 1
          ? end
          : start.add(Duration(days: i * step));
      final value = assets.fold(0.0, (sum, asset) {
        if (asset.purchaseDate.isAfter(cursor)) return sum;
        if (asset.status == AssetStatus.sold &&
            asset.soldAt != null &&
            !asset.soldAt!.isAfter(cursor))
          return sum;
        if (!settings.includeRetiredInTotal &&
            asset.status == AssetStatus.retired)
          return sum;
        if (!asset.includeInTotal) return sum;
        return sum + asset.price + asset.addonTotal;
      });
      points.add(
        AssetTrendPoint(label: '${cursor.month}/${cursor.day}', value: value),
      );
    }
    return points;
  }

  List<LifecycleEventItem> lifecycleEvents({int limit = 8}) {
    final rows = <LifecycleEventItem>[];
    for (final asset in assets) {
      rows.add(
        LifecycleEventItem(
          date: asset.purchaseDate,
          title: '买入 ${asset.name}',
          subtitle:
              '${categoryIcon(asset.categoryId)} ${categoryName(asset.categoryId)} · ${money(asset.price, settings)}',
          icon: Icons.add_shopping_cart_rounded,
          color: kBrandStrong,
        ),
      );
      if (asset.status == AssetStatus.retired && asset.retiredAt != null) {
        rows.add(
          LifecycleEventItem(
            date: asset.retiredAt!,
            title: '退役 ${asset.name}',
            subtitle:
                '共服役 ${durationText(asset.serviceDays, settings.durationMode)}，最终日耗 ${money(asset.dailyCost, settings)} /天',
            icon: Icons.archive_rounded,
            color: const Color(0xFFFFB020),
          ),
        );
      }
      if (asset.status == AssetStatus.sold && asset.soldAt != null) {
        rows.add(
          LifecycleEventItem(
            date: asset.soldAt!,
            title: '卖出 ${asset.name}',
            subtitle:
                '回收 ${money(asset.soldPrice ?? 0, settings)}，净消耗 ${money(asset.netCost, settings)}',
            icon: Icons.swap_horiz_rounded,
            color: const Color(0xFF4ADE80),
          ),
        );
      }
    }
    for (final item in recoveryRecords) {
      final names = item.assetIds
          .map(
            (id) =>
                assets
                    .where((a) => a.id == id)
                    .cast<Asset?>()
                    .firstOrNull
                    ?.name ??
                '资产',
          )
          .take(3)
          .join('、');
      rows.add(
        LifecycleEventItem(
          date: item.date,
          title: '使用收益 ${item.title}',
          subtitle:
              '${names.isEmpty ? '未选择资产' : names} · 回收 ${money(item.amount, settings)}',
          icon: Icons.savings_rounded,
          color: const Color(0xFF22C55E),
        ),
      );
    }
    rows.sort((a, b) => b.date.compareTo(a.date));
    return rows.take(limit).toList();
  }

  List<AssetInsight> assetInsights() {
    final result = <AssetInsight>[];
    final active = assets
        .where((a) => a.status == AssetStatus.serving)
        .toList();
    final avgDaily = getAverageDailyCost();
    final highDaily = [
      ...active.where((a) => avgDaily > 0 && a.dailyCost > avgDaily * 1.6),
    ]..sort((a, b) => b.dailyCost.compareTo(a.dailyCost));
    if (highDaily.isNotEmpty) {
      final a = highDaily.first;
      result.add(
        AssetInsight(
          icon: Icons.local_fire_department_rounded,
          title: '日耗偏高',
          description:
              '${a.name} 当前约 ${money(a.dailyCost, settings)} /天，可考虑延长使用周期或复盘必要性。',
          color: const Color(0xFFFF8A65),
        ),
      );
    }

    final targetDone = active
        .where((a) => a.targetMode != TargetMode.none && a.targetRatio >= .98)
        .toList();
    if (targetDone.isNotEmpty) {
      result.add(
        AssetInsight(
          icon: Icons.flag_circle_rounded,
          title: '目标接近完成',
          description: '${targetDone.first.name} 的使用目标已经接近完成，适合记录一次阶段复盘。',
          color: const Color(0xFF4ADE80),
        ),
      );
    }

    final now = DateTime.now();
    final expiring = active.where((a) {
      if (a.expiresAt == null) return false;
      final days = a.expiresAt!.difference(now).inDays;
      return days >= 0 && days <= (a.remindBeforeDays ?? 7);
    }).toList();
    if (expiring.isNotEmpty) {
      result.add(
        AssetInsight(
          icon: Icons.notifications_active_rounded,
          title: '即将到期',
          description:
              '${expiring.first.name} 将在 ${dateText(expiring.first.expiresAt!)} 前后到期，记得处理续费或保修。',
          color: const Color(0xFFFFC857),
        ),
      );
    }

    final idle = assets
        .where(
          (a) =>
              a.status == AssetStatus.retired ||
              a.tagIds.any((id) => (tagById(id)?.name ?? '').contains('吃灰')),
        )
        .length;
    if (idle > 0) {
      result.add(
        AssetInsight(
          icon: Icons.recycling_rounded,
          title: '闲置复盘',
          description: '已有 $idle 件资产处于退役或吃灰状态，可以集中判断留存、转赠或二手流转。',
          color: const Color(0xFF60A5FA),
        ),
      );
    }

    final wishBudget = wishes
        .where((w) => !w.archived)
        .fold(0.0, (s, w) => s + w.expectedPrice);
    if (wishBudget > 0 &&
        wishBudget > math.max(getTotalAssetValue(), 1.0) * .35) {
      result.add(
        AssetInsight(
          icon: Icons.shopping_bag_rounded,
          title: '心愿预算偏高',
          description:
              '未完成心愿预算约 ${money(wishBudget, settings)}，建议先确认真实使用场景再购买。',
          color: const Color(0xFFA78BFA),
        ),
      );
    }

    if (result.isEmpty) {
      result.add(
        const AssetInsight(
          icon: Icons.check_circle_rounded,
          title: '资产状态稳定',
          description: '当前没有明显高日耗、临期或闲置风险。继续记录，后续会生成更准确的复盘建议。',
          color: kBrandStrong,
        ),
      );
    }
    return result.take(4).toList();
  }

  double getSoldRecoveredValue() => assets
      .where((a) => a.status == AssetStatus.sold)
      .fold(0.0, (sum, a) => sum + (a.soldPrice ?? 0));

  double getRecoveryIncomeTotal() =>
      recoveryRecords.fold(0.0, (sum, item) => sum + math.max(item.amount, 0));

  double getAssetRecoveryIncome(String assetId) {
    double result = 0;
    for (final item in recoveryRecords) {
      if (!item.assetIds.contains(assetId)) continue;
      result += item.amount / math.max(item.assetIds.length, 1);
    }
    return result;
  }

  double getAssetTotalRecoveredValue(Asset asset) {
    final soldRecovered = asset.status == AssetStatus.sold
        ? (asset.soldPrice ?? 0)
        : 0.0;
    return soldRecovered + getAssetRecoveryIncome(asset.id);
  }

  double getAssetNetConsumptionAfterRecovery(Asset asset) => math.max(
    asset.price + asset.dailyAddonTotal - getAssetTotalRecoveredValue(asset),
    0,
  );

  double getLifecycleRecoveredValue() =>
      getSoldRecoveredValue() + getRecoveryIncomeTotal();

  double getLifecycleNetConsumption() => math.max(
    assets.fold(0.0, (sum, a) => sum + math.max(a.netCost, 0)) -
        getRecoveryIncomeTotal(),
    0,
  );

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

  String? convertWishToAsset(String wishId) {
    final index = wishes.indexWhere((w) => w.id == wishId);
    if (index < 0) return null;
    final wish = wishes[index];
    if (wish.convertedAssetId != null) return wish.convertedAssetId;
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
      archived: true,
      convertedAt: DateTime.now(),
      convertedAssetId: assetId,
    );
    save();
    _invalidateAnalytics();
    notifyListeners();
    return assetId;
  }

  void upsertCategory(Category item) {
    final i = categories.indexWhere((e) => e.id == item.id);
    if (i >= 0) {
      categories[i] = item;
    } else {
      categories.add(item);
    }
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void deleteCategory(String id) {
    categories.removeWhere((e) => e.id == id);
    for (var i = 0; i < assets.length; i++) {
      final a = assets[i];
      if (a.categoryId == id) {
        assets[i] = Asset(
          id: a.id,
          name: a.name,
          iconValue: a.iconValue,
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
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void upsertTag(Tag item) {
    final i = tags.indexWhere((e) => e.id == item.id);
    if (i >= 0) {
      tags[i] = item;
    } else {
      tags.add(item);
    }
    tags.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void deleteTag(String id) {
    tags.removeWhere((e) => e.id == id);
    for (var i = 0; i < assets.length; i++) {
      if (assets[i].tagIds.contains(id))
        assets[i] = assets[i].copyWith(
          tagIds: assets[i].tagIds.where((e) => e != id).toList(),
        );
    }
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void markAssetServing(String id) {
    final i = assets.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = assets[i];
    assets[i] = Asset(
      id: a.id,
      name: a.name,
      iconValue: a.iconValue,
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
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void markAssetRetired(String id, {DateTime? retiredAt}) {
    final i = assets.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = assets[i];
    assets[i] = Asset(
      id: a.id,
      name: a.name,
      iconValue: a.iconValue,
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
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void markAssetSold(
    String id, {
    required DateTime soldAt,
    required double soldPrice,
  }) {
    final i = assets.indexWhere((a) => a.id == id);
    if (i < 0) return;
    final a = assets[i];
    assets[i] = Asset(
      id: a.id,
      name: a.name,
      iconValue: a.iconValue,
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
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  List<Asset> dueSoonAssets({int limit = 5}) {
    final now = DateTime.now();
    final rows = assets.where((a) {
      if (a.expiresAt == null || a.status == AssetStatus.sold) return false;
      final days = a.expiresAt!.difference(now).inDays;
      return days >= 0 && days <= (a.remindBeforeDays ?? 7);
    }).toList()..sort((a, b) => a.expiresAt!.compareTo(b.expiresAt!));
    return rows.take(limit).toList();
  }

  void createSnapshot(String label) {
    final payload = exportJson(includeSnapshots: false);
    snapshots.insert(
      0,
      SnapshotRecord(
        id: newId('snapshot'),
        label: label.trim().isEmpty ? '本机快照' : label.trim(),
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void deleteSnapshot(String id) {
    snapshots.removeWhere((item) => item.id == id);
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void renameSnapshot(String id, String label) {
    final nextLabel = label.trim();
    if (nextLabel.isEmpty) return;
    final index = snapshots.indexWhere((item) => item.id == id);
    if (index < 0) return;
    final old = snapshots[index];
    snapshots[index] = SnapshotRecord(
      id: old.id,
      label: nextLabel,
      payload: old.payload,
      createdAt: old.createdAt,
    );
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  void applyRecommendedCategorySystem() {
    final now = DateTime.now().toIso8601String();
    final presets = <Map<String, String>>[
      {'id': 'cat_digital', 'name': '电子数码', 'icon': '💻', 'color': '#60A5FA'},
      {
        'id': 'cat_audio_video',
        'name': '影音娱乐',
        'icon': '🎧',
        'color': '#38BDF8',
      },
      {
        'id': 'cat_photo_creative',
        'name': '影像创作',
        'icon': '📷',
        'color': '#A78BFA',
      },
      {
        'id': 'cat_game_hobby',
        'name': '游戏兴趣',
        'icon': '🎮',
        'color': '#F472B6',
      },
      {
        'id': 'cat_work_study',
        'name': '学习办公',
        'icon': '📚',
        'color': '#34D399',
      },
      {
        'id': 'cat_wear_style',
        'name': '穿搭配饰',
        'icon': '👕',
        'color': '#FB7185',
      },
      {'id': 'cat_home_life', 'name': '家居生活', 'icon': '🏠', 'color': '#FDBA74'},
      {'id': 'cat_transport', 'name': '出行交通', 'icon': '🚗', 'color': '#4ADE80'},
      {
        'id': 'cat_sport_health',
        'name': '健康运动',
        'icon': '🏃',
        'color': '#A3E635',
      },
      {
        'id': 'cat_tools_repair',
        'name': '工具维修',
        'icon': '🧰',
        'color': '#FACC15',
      },
      {'id': 'cat_collection', 'name': '收藏纪念', 'icon': '⭐', 'color': '#818CF8'},
      {'id': 'cat_service', 'name': '软件服务', 'icon': '💳', 'color': '#94A3B8'},
    ];

    final aliases = <String, String>{
      '手机': 'cat_digital',
      '电脑': 'cat_digital',
      '平板': 'cat_digital',
      '数码配件': 'cat_digital',
      '电子': 'cat_digital',
      '耳机': 'cat_audio_video',
      '音频': 'cat_audio_video',
      '影音': 'cat_audio_video',
      '摄影': 'cat_photo_creative',
      '相机': 'cat_photo_creative',
      '镜头': 'cat_photo_creative',
      '游戏': 'cat_game_hobby',
      '娱乐': 'cat_game_hobby',
      '兴趣': 'cat_game_hobby',
      '学习': 'cat_work_study',
      '办公': 'cat_work_study',
      '书籍': 'cat_work_study',
      '服饰': 'cat_wear_style',
      '穿搭': 'cat_wear_style',
      '鞋包': 'cat_wear_style',
      '家居': 'cat_home_life',
      '家电': 'cat_home_life',
      '生活': 'cat_home_life',
      '交通': 'cat_transport',
      '出行': 'cat_transport',
      '旅行': 'cat_transport',
      '运动': 'cat_sport_health',
      '健康': 'cat_sport_health',
      '工具': 'cat_tools_repair',
      '维修': 'cat_tools_repair',
      '收藏': 'cat_collection',
      '纪念': 'cat_collection',
      '订阅': 'cat_service',
      '软件': 'cat_service',
      '服务': 'cat_service',
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
        (item) => item.id == preset['id'] || item.name == preset['name'],
      );
      final item = Category(
        id: preset['id']!,
        name: preset['name']!,
        icon: preset['icon']!,
        color: preset['color']!,
        sortOrder: i,
        createdAt: existingIndex >= 0
            ? categories[existingIndex].createdAt
            : now,
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
    categories.removeWhere(
      (item) => oldToNew.containsKey(item.id) && !presetIds.contains(item.id),
    );
    categories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    save();
    _invalidateAnalytics();
    notifyListeners();
  }

  bool restoreFromJson(String raw) {
    try {
      importMap(Map<String, dynamic>.from(jsonDecode(raw)));
      save();
      _invalidateAnalytics();
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  bool restoreSnapshot(SnapshotRecord record) =>
      restoreFromJson(record.payload);

  void clearAllAndSeed() {
    initializeEmptyData();
    save();
    notifyListeners();
  }
}
