part of '../main.dart';

class AddonItem {
  final String id;
  final String name;
  final double price;
  final DateTime? purchaseDate;
  final bool followParentPurchaseDate;
  final bool includeInTotal;
  final bool includeInDailyCost;

  const AddonItem({
    required this.id,
    required this.name,
    required this.price,
    this.purchaseDate,
    this.followParentPurchaseDate = false,
    this.includeInTotal = true,
    this.includeInDailyCost = true,
  });

  String get purchaseDateLabel =>
      purchaseDate == null ? '未设置购买时间' : dateText(purchaseDate!);
  DateTime? effectivePurchaseDate(DateTime parentPurchaseDate) =>
      followParentPurchaseDate ? parentPurchaseDate : purchaseDate;
  String effectivePurchaseDateLabel(DateTime parentPurchaseDate) =>
      followParentPurchaseDate
      ? '跟随父资产：${dateText(parentPurchaseDate)}'
      : purchaseDateLabel;

  AddonItem copyWith({
    String? id,
    String? name,
    double? price,
    DateTime? purchaseDate,
    bool? clearPurchaseDate,
    bool? followParentPurchaseDate,
    bool? includeInTotal,
    bool? includeInDailyCost,
  }) => AddonItem(
    id: id ?? this.id,
    name: name ?? this.name,
    price: price ?? this.price,
    purchaseDate: clearPurchaseDate == true
        ? null
        : (purchaseDate ?? this.purchaseDate),
    followParentPurchaseDate:
        followParentPurchaseDate ?? this.followParentPurchaseDate,
    includeInTotal: includeInTotal ?? this.includeInTotal,
    includeInDailyCost: includeInDailyCost ?? this.includeInDailyCost,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'price': price,
    'purchaseDate': purchaseDate == null
        ? null
        : dateStorageText(purchaseDate!),
    'purchaseDateYmd': purchaseDate == null
        ? null
        : dateStorageText(purchaseDate!),
    'purchaseDateEpochDay': purchaseDate == null
        ? null
        : dateEpochDay(purchaseDate!),
    'followParentPurchaseDate': followParentPurchaseDate,
    'includeInTotal': includeInTotal,
    'includeInDailyCost': includeInDailyCost,
  };

  factory AddonItem.fromMap(Map<String, dynamic> map) => AddonItem(
    id: map['id']?.toString() ?? newId('addon'),
    name: map['name']?.toString() ?? '附加项',
    price: asDouble(map['price']),
    purchaseDate:
        parseOptionalPersistedDate(
          map['purchaseDateYmd'] ?? map['purchaseDate'],
        ) ??
        dateFromEpochDay(map['purchaseDateEpochDay']),
    followParentPurchaseDate: map['followParentPurchaseDate'] == true,
    includeInTotal: map['includeInTotal'] != false,
    includeInDailyCost: map['includeInDailyCost'] != false,
  );
}

class ValueRecoveryRecord {
  final String id;
  final String title;
  final List<String> assetIds;
  final double amount;
  final DateTime date;
  final String note;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ValueRecoveryRecord({
    required this.id,
    required this.title,
    required this.assetIds,
    required this.amount,
    required this.date,
    required this.note,
    required this.createdAt,
    required this.updatedAt,
  });

  ValueRecoveryRecord copyWith({
    String? title,
    List<String>? assetIds,
    double? amount,
    DateTime? date,
    String? note,
  }) => ValueRecoveryRecord(
    id: id,
    title: title ?? this.title,
    assetIds: assetIds ?? this.assetIds,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    note: note ?? this.note,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'assetIds': assetIds,
    'amount': amount,
    'date': dateStorageText(date),
    'note': note,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory ValueRecoveryRecord.fromMap(
    Map<String, dynamic> map,
  ) => ValueRecoveryRecord(
    id: map['id']?.toString() ?? newId('recovery'),
    title: map['title']?.toString() ?? '使用收益',
    assetIds: ((map['assetIds'] as List?) ?? [])
        .map((e) => e.toString())
        .where((e) => e.trim().isNotEmpty)
        .toList(),
    amount: asDouble(map['amount']),
    date: parsePersistedRequiredDate(
      map['date'],
      fallback: parseOptionalPersistedDate(map['createdAt']) ?? DateTime.now(),
    ),
    note: map['note']?.toString() ?? '',
    createdAt: parsePersistedDate(map['createdAt'], fallback: DateTime.now()),
    updatedAt: parsePersistedDate(map['updatedAt'], fallback: DateTime.now()),
  );
}

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  Category copyWith({
    String? name,
    String? icon,
    String? color,
    int? sortOrder,
  }) => Category(
    id: id,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt,
    updatedAt: DateTime.now().toIso8601String(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'icon': icon,
    'color': color,
    'sortOrder': sortOrder,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
    id: map['id']?.toString() ?? newId('cat'),
    name: map['name']?.toString() ?? '未分类',
    icon: map['icon']?.toString() ?? '📦',
    color: map['color']?.toString() ?? '#7cc6f2',
    sortOrder: asInt(map['sortOrder']),
    createdAt: map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    updatedAt: map['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
  );
}

class Tag {
  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
  });

  Tag copyWith({String? name, String? color, int? sortOrder}) => Tag(
    id: id,
    name: name ?? this.name,
    color: color ?? this.color,
    sortOrder: sortOrder ?? this.sortOrder,
    createdAt: createdAt,
    updatedAt: DateTime.now().toIso8601String(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'color': color,
    'sortOrder': sortOrder,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
  };

  factory Tag.fromMap(Map<String, dynamic> map) => Tag(
    id: map['id']?.toString() ?? newId('tag'),
    name: map['name']?.toString() ?? '标签',
    color: map['color']?.toString() ?? '#7cc6f2',
    sortOrder: asInt(map['sortOrder']),
    createdAt: map['createdAt']?.toString() ?? DateTime.now().toIso8601String(),
    updatedAt: map['updatedAt']?.toString() ?? DateTime.now().toIso8601String(),
  );
}

class Asset {
  final String id;
  final String name;
  final String iconValue;
  final double price;
  final DateTime purchaseDate;
  final String? categoryId;
  final List<String> tagIds;
  final List<AddonItem> addons;
  final String note;
  final AssetStatus status;
  final bool includeInTotal;
  final bool includeInDailyCost;
  final DateTime? retiredAt;
  final DateTime? soldAt;
  final double? soldPrice;
  final TargetMode targetMode;
  final double? targetDailyCost;
  final DateTime? targetDate;
  final int? targetCustomDays;
  final DateTime? expiresAt;
  final int? remindBeforeDays;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Asset({
    required this.id,
    required this.name,
    required this.iconValue,
    required this.price,
    required this.purchaseDate,
    required this.categoryId,
    required this.tagIds,
    required this.addons,
    required this.note,
    required this.status,
    required this.includeInTotal,
    required this.includeInDailyCost,
    required this.retiredAt,
    required this.soldAt,
    required this.soldPrice,
    required this.targetMode,
    required this.targetDailyCost,
    required this.targetDate,
    required this.targetCustomDays,
    required this.expiresAt,
    required this.remindBeforeDays,
    required this.createdAt,
    required this.updatedAt,
  });

  DateTime get serviceEndDate {
    if (status == AssetStatus.sold && soldAt != null) return soldAt!;
    if (status == AssetStatus.retired && retiredAt != null) return retiredAt!;
    return DateTime.now();
  }

  int get serviceDays => diffDaysInclusive(purchaseDate, serviceEndDate);
  double get addonTotal => addons.fold(
    0.0,
    (sum, item) => sum + (item.includeInTotal ? item.price : 0),
  );
  double get dailyAddonTotal => addons.fold(
    0.0,
    (sum, item) => sum + (item.includeInDailyCost ? item.price : 0),
  );
  double get totalDisplayValue => price + addonTotal;
  double get netCost =>
      price +
      dailyAddonTotal -
      (status == AssetStatus.sold ? (soldPrice ?? 0) : 0);
  double get dailyCost =>
      includeInDailyCost ? netCost / math.max(serviceDays, 1) : 0;
  double get assetValue {
    if (!includeInTotal) return 0;
    if (status == AssetStatus.sold) return 0;
    return price + addonTotal;
  }

  double get targetRatio {
    if (targetMode == TargetMode.daily && (targetDailyCost ?? 0) > 0) {
      return ((targetDailyCost ?? 0) / math.max(dailyCost, 0.01))
          .clamp(0, 1)
          .toDouble();
    }
    if (targetMode == TargetMode.date && targetDate != null) {
      final totalDays = diffDaysInclusive(purchaseDate, targetDate!);
      final passedDays = diffDaysInclusive(
        purchaseDate,
        DateTime.now().isAfter(targetDate!) ? targetDate! : DateTime.now(),
      );
      return (passedDays / math.max(totalDays, 1)).clamp(0, 1).toDouble();
    }
    if (targetMode == TargetMode.custom && (targetCustomDays ?? 0) > 0) {
      return (serviceDays / targetCustomDays!).clamp(0, 1).toDouble();
    }
    return 0;
  }

  int? get targetDays {
    if (targetMode == TargetMode.daily && (targetDailyCost ?? 0) > 0) {
      return math.max((netCost / math.max(targetDailyCost!, .01)).ceil(), 1);
    }
    if (targetMode == TargetMode.date && targetDate != null) {
      return diffDaysInclusive(purchaseDate, targetDate!);
    }
    if (targetMode == TargetMode.custom && (targetCustomDays ?? 0) > 0) {
      return targetCustomDays;
    }
    return null;
  }

  int? get remainingTargetDays {
    final days = targetDays;
    if (days == null) return null;
    return math.max(days - serviceDays, 0);
  }

  DateTime? get estimatedTargetDate {
    final days = targetDays;
    if (days == null) return null;
    return purchaseDate.add(Duration(days: math.max(days - 1, 0)));
  }

  double get serviceProgressRatio {
    final days = targetDays;
    if (days == null || days <= 0) return 0;
    return (serviceDays / days).clamp(0, 1).toDouble();
  }

  Asset copyWith({
    String? name,
    String? iconValue,
    double? price,
    DateTime? purchaseDate,
    String? categoryId,
    List<String>? tagIds,
    List<AddonItem>? addons,
    String? note,
    AssetStatus? status,
    bool? includeInTotal,
    bool? includeInDailyCost,
    DateTime? retiredAt,
    DateTime? soldAt,
    double? soldPrice,
    TargetMode? targetMode,
    double? targetDailyCost,
    DateTime? targetDate,
    int? targetCustomDays,
    DateTime? expiresAt,
    int? remindBeforeDays,
  }) => Asset(
    id: id,
    name: name ?? this.name,
    iconValue: iconValue ?? this.iconValue,
    price: price ?? this.price,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    categoryId: categoryId ?? this.categoryId,
    tagIds: tagIds ?? this.tagIds,
    addons: addons ?? this.addons,
    note: note ?? this.note,
    status: status ?? this.status,
    includeInTotal: includeInTotal ?? this.includeInTotal,
    includeInDailyCost: includeInDailyCost ?? this.includeInDailyCost,
    retiredAt: retiredAt ?? this.retiredAt,
    soldAt: soldAt ?? this.soldAt,
    soldPrice: soldPrice ?? this.soldPrice,
    targetMode: targetMode ?? this.targetMode,
    targetDailyCost: targetDailyCost ?? this.targetDailyCost,
    targetDate: targetDate ?? this.targetDate,
    targetCustomDays: targetCustomDays ?? this.targetCustomDays,
    expiresAt: expiresAt ?? this.expiresAt,
    remindBeforeDays: remindBeforeDays ?? this.remindBeforeDays,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'iconValue': iconValue,
    'price': price,
    'purchaseDate': dateStorageText(purchaseDate),
    'purchaseDateYmd': dateStorageText(purchaseDate),
    'purchaseDateEpochDay': dateEpochDay(purchaseDate),
    'categoryId': categoryId,
    'tagIds': tagIds,
    'addons': addons.map((e) => e.toMap()).toList(),
    'note': note,
    'status': status.name,
    'includeInTotal': includeInTotal,
    'includeInDailyCost': includeInDailyCost,
    'retiredAt': retiredAt == null ? null : dateStorageText(retiredAt!),
    'soldAt': soldAt == null ? null : dateStorageText(soldAt!),
    'soldPrice': soldPrice,
    'targetMode': targetMode.name,
    'targetDailyCost': targetDailyCost,
    'targetDate': targetDate == null ? null : dateStorageText(targetDate!),
    'targetCustomDays': targetCustomDays,
    'expiresAt': expiresAt == null ? null : dateStorageText(expiresAt!),
    'remindBeforeDays': remindBeforeDays,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Asset.fromMap(Map<String, dynamic> map) => Asset(
    id: map['id']?.toString() ?? newId('asset'),
    name: map['name']?.toString() ?? '未命名资产',
    iconValue: map['iconValue']?.toString() ?? map['emoji']?.toString() ?? '📦',
    price: asDouble(map['price']),
    purchaseDate: parsePersistedRequiredDate(
      map['purchaseDateYmd'] ?? map['purchaseDate'],
      fallback:
          dateFromEpochDay(map['purchaseDateEpochDay']) ??
          parseOptionalPersistedDate(map['createdAt']) ??
          parseOptionalPersistedDate(map['updatedAt']),
    ),
    categoryId: map['categoryId']?.toString(),
    tagIds: ((map['tagIds'] as List?) ?? (map['tags'] as List?) ?? [])
        .map((e) => e.toString())
        .toList(),
    addons: ((map['addons'] as List?) ?? [])
        .map((e) => AddonItem.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    note: map['note']?.toString() ?? '',
    status: AssetStatusX.fromValue(map['status']?.toString()),
    includeInTotal: map['includeInTotal'] != false,
    includeInDailyCost: map['includeInDailyCost'] != false,
    retiredAt: parseOptionalPersistedDate(map['retiredAt']),
    soldAt: parseOptionalPersistedDate(map['soldAt']),
    soldPrice: map['soldPrice'] == null ? null : asDouble(map['soldPrice']),
    targetMode: TargetModeX.fromValue(map['targetMode']?.toString()),
    targetDailyCost: map['targetDailyCost'] == null
        ? null
        : asDouble(map['targetDailyCost']),
    targetDate: parseOptionalPersistedDate(map['targetDate']),
    targetCustomDays: map['targetCustomDays'] == null
        ? null
        : asInt(map['targetCustomDays']),
    expiresAt: parseOptionalPersistedDate(map['expiresAt']),
    remindBeforeDays: map['remindBeforeDays'] == null
        ? null
        : asInt(map['remindBeforeDays']),
    createdAt: parsePersistedDate(map['createdAt'], fallback: DateTime.now()),
    updatedAt: parsePersistedDate(map['updatedAt'], fallback: DateTime.now()),
  );
}

class Wish {
  final String id;
  final String name;
  final String iconValue;
  final double expectedPrice;
  final String note;
  final String? categoryId;
  final List<String> tagIds;
  final bool archived;
  final DateTime? convertedAt;
  final String? convertedAssetId;
  final List<AddonItem> addons;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Wish({
    required this.id,
    required this.name,
    required this.iconValue,
    required this.expectedPrice,
    required this.note,
    required this.categoryId,
    required this.tagIds,
    required this.archived,
    required this.convertedAt,
    required this.convertedAssetId,
    required this.addons,
    required this.createdAt,
    required this.updatedAt,
  });

  Wish copyWith({
    String? name,
    String? iconValue,
    double? expectedPrice,
    String? note,
    String? categoryId,
    List<String>? tagIds,
    bool? archived,
    DateTime? convertedAt,
    String? convertedAssetId,
    List<AddonItem>? addons,
  }) => Wish(
    id: id,
    name: name ?? this.name,
    iconValue: iconValue ?? this.iconValue,
    expectedPrice: expectedPrice ?? this.expectedPrice,
    note: note ?? this.note,
    categoryId: categoryId ?? this.categoryId,
    tagIds: tagIds ?? this.tagIds,
    archived: archived ?? this.archived,
    convertedAt: convertedAt ?? this.convertedAt,
    convertedAssetId: convertedAssetId ?? this.convertedAssetId,
    addons: addons ?? this.addons,
    createdAt: createdAt,
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'iconValue': iconValue,
    'expectedPrice': expectedPrice,
    'note': note,
    'categoryId': categoryId,
    'tagIds': tagIds,
    'archived': archived,
    'convertedAt': convertedAt?.toIso8601String(),
    'convertedAssetId': convertedAssetId,
    'addons': addons.map((e) => e.toMap()).toList(),
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory Wish.fromMap(Map<String, dynamic> map) => Wish(
    id: map['id']?.toString() ?? newId('wish'),
    name: map['name']?.toString() ?? '未命名心愿',
    iconValue: map['iconValue']?.toString() ?? map['emoji']?.toString() ?? '✨',
    expectedPrice: asDouble(map['expectedPrice']),
    note: map['note']?.toString() ?? map['reason']?.toString() ?? '',
    categoryId: map['categoryId']?.toString(),
    tagIds: ((map['tagIds'] as List?) ?? []).map((e) => e.toString()).toList(),
    archived: map['archived'] == true || map['done'] == true,
    convertedAt: parseOptionalPersistedDate(map['convertedAt']),
    convertedAssetId: map['convertedAssetId']?.toString(),
    addons: ((map['addons'] as List?) ?? [])
        .map((e) => AddonItem.fromMap(Map<String, dynamic>.from(e)))
        .toList(),
    createdAt: parsePersistedDate(map['createdAt'], fallback: DateTime.now()),
    updatedAt: parsePersistedDate(map['updatedAt'], fallback: DateTime.now()),
  );
}

enum CloudSyncProvider {
  off,
  webdav,
  jianguoyun,
  nextcloud,
  customWebdav,
  manualFile,
}

String cloudSyncProviderLabel(CloudSyncProvider provider) {
  switch (provider) {
    case CloudSyncProvider.off:
      return '关闭';
    case CloudSyncProvider.webdav:
      return 'WebDAV';
    case CloudSyncProvider.jianguoyun:
      return '坚果云 WebDAV';
    case CloudSyncProvider.nextcloud:
      return 'Nextcloud';
    case CloudSyncProvider.customWebdav:
      return '自定义 WebDAV';
    case CloudSyncProvider.manualFile:
      return '手动文件备份';
  }
}

String defaultCloudServerUrl(CloudSyncProvider provider) {
  switch (provider) {
    case CloudSyncProvider.jianguoyun:
      return 'https://dav.jianguoyun.com/dav/';
    case CloudSyncProvider.nextcloud:
      return 'https://your-nextcloud.example.com/remote.php/dav/files/username/';
    case CloudSyncProvider.webdav:
    case CloudSyncProvider.customWebdav:
      return 'https://example.com/dav/';
    case CloudSyncProvider.off:
    case CloudSyncProvider.manualFile:
      return '';
  }
}

class CloudSyncSettings {
  final CloudSyncProvider provider;
  final String serverUrl;
  final String username;
  final String password;
  final String remotePath;
  final bool autoUploadOnSave;
  final bool syncOnLaunch;
  final DateTime? lastUploadAt;
  final DateTime? lastDownloadAt;

  const CloudSyncSettings({
    this.provider = CloudSyncProvider.off,
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.remotePath = 'valora/valora_backup.json',
    this.autoUploadOnSave = false,
    this.syncOnLaunch = false,
    this.lastUploadAt,
    this.lastDownloadAt,
  });

  bool get enabled =>
      provider != CloudSyncProvider.off &&
      provider != CloudSyncProvider.manualFile &&
      serverUrl.trim().isNotEmpty;
  String get providerLabel => cloudSyncProviderLabel(provider);

  CloudSyncSettings copyWith({
    CloudSyncProvider? provider,
    String? serverUrl,
    String? username,
    String? password,
    String? remotePath,
    bool? autoUploadOnSave,
    bool? syncOnLaunch,
    DateTime? lastUploadAt,
    DateTime? lastDownloadAt,
    bool clearLastUploadAt = false,
    bool clearLastDownloadAt = false,
  }) => CloudSyncSettings(
    provider: provider ?? this.provider,
    serverUrl: serverUrl ?? this.serverUrl,
    username: username ?? this.username,
    password: password ?? this.password,
    remotePath: remotePath ?? this.remotePath,
    autoUploadOnSave: autoUploadOnSave ?? this.autoUploadOnSave,
    syncOnLaunch: syncOnLaunch ?? this.syncOnLaunch,
    lastUploadAt: clearLastUploadAt
        ? null
        : (lastUploadAt ?? this.lastUploadAt),
    lastDownloadAt: clearLastDownloadAt
        ? null
        : (lastDownloadAt ?? this.lastDownloadAt),
  );

  Map<String, dynamic> toMap() => {
    'provider': provider.name,
    'serverUrl': serverUrl,
    'username': username,
    'password': password,
    'remotePath': remotePath,
    'autoUploadOnSave': autoUploadOnSave,
    'syncOnLaunch': syncOnLaunch,
    'lastUploadAt': lastUploadAt?.toIso8601String(),
    'lastDownloadAt': lastDownloadAt?.toIso8601String(),
  };

  factory CloudSyncSettings.fromMap(Map<String, dynamic>? map) {
    if (map == null) return const CloudSyncSettings();
    final provider = CloudSyncProvider.values.firstWhere(
      (e) => e.name == map['provider']?.toString(),
      orElse: () => CloudSyncProvider.off,
    );
    return CloudSyncSettings(
      provider: provider,
      serverUrl:
          map['serverUrl']?.toString() ?? defaultCloudServerUrl(provider),
      username: map['username']?.toString() ?? '',
      password: map['password']?.toString() ?? '',
      remotePath: map['remotePath']?.toString().trim().isNotEmpty == true
          ? map['remotePath'].toString()
          : 'valora/valora_backup.json',
      autoUploadOnSave: map['autoUploadOnSave'] == true,
      syncOnLaunch: map['syncOnLaunch'] == true,
      lastUploadAt: parseOptionalPersistedDate(map['lastUploadAt']),
      lastDownloadAt: parseOptionalPersistedDate(map['lastDownloadAt']),
    );
  }
}

class AppSettings {
  final String currencyUnit;
  final int decimalPlaces;
  final bool useThousandsSeparator;
  final DurationMode durationMode;
  final ThemeSetting theme;
  final bool includeRetiredInTotal;
  final bool reminderEnabled;
  final bool hapticsEnabled;
  final bool nativeHapticsEnabled;
  final bool compactSnackbars;
  final HomeViewMode defaultHomeViewMode;
  final StickerEngineMode stickerEngineMode;
  final bool keepStickerCandidates;
  final double homeMetaFontScale;
  final bool onboardingCompleted;
  final CloudSyncSettings cloudSync;

  const AppSettings({
    this.currencyUnit = '¥',
    this.decimalPlaces = 2,
    this.useThousandsSeparator = true,
    this.durationMode = DurationMode.days,
    this.theme = ThemeSetting.light,
    this.includeRetiredInTotal = true,
    this.reminderEnabled = false,
    this.hapticsEnabled = true,
    this.nativeHapticsEnabled = true,
    this.compactSnackbars = true,
    this.defaultHomeViewMode = HomeViewMode.grid,
    this.stickerEngineMode = StickerEngineMode.balanced,
    this.keepStickerCandidates = false,
    this.homeMetaFontScale = 1.0,
    this.onboardingCompleted = false,
    this.cloudSync = const CloudSyncSettings(),
  });

  AppSettings copyWith({
    String? currencyUnit,
    int? decimalPlaces,
    bool? useThousandsSeparator,
    DurationMode? durationMode,
    ThemeSetting? theme,
    bool? includeRetiredInTotal,
    bool? reminderEnabled,
    bool? hapticsEnabled,
    bool? nativeHapticsEnabled,
    bool? compactSnackbars,
    HomeViewMode? defaultHomeViewMode,
    StickerEngineMode? stickerEngineMode,
    bool? keepStickerCandidates,
    double? homeMetaFontScale,
    bool? onboardingCompleted,
    CloudSyncSettings? cloudSync,
  }) => AppSettings(
    currencyUnit: currencyUnit ?? this.currencyUnit,
    decimalPlaces: decimalPlaces ?? this.decimalPlaces,
    useThousandsSeparator: useThousandsSeparator ?? this.useThousandsSeparator,
    durationMode: durationMode ?? this.durationMode,
    theme: theme ?? this.theme,
    includeRetiredInTotal: includeRetiredInTotal ?? this.includeRetiredInTotal,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    nativeHapticsEnabled: nativeHapticsEnabled ?? this.nativeHapticsEnabled,
    compactSnackbars: compactSnackbars ?? this.compactSnackbars,
    defaultHomeViewMode: defaultHomeViewMode ?? this.defaultHomeViewMode,
    stickerEngineMode: stickerEngineMode ?? this.stickerEngineMode,
    keepStickerCandidates: keepStickerCandidates ?? this.keepStickerCandidates,
    homeMetaFontScale: homeMetaFontScale ?? this.homeMetaFontScale,
    onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    cloudSync: cloudSync ?? this.cloudSync,
  );

  Map<String, dynamic> toMap() => {
    'currencyUnit': currencyUnit,
    'decimalPlaces': decimalPlaces,
    'useThousandsSeparator': useThousandsSeparator,
    'durationMode': durationMode.name,
    'theme': theme.name,
    'includeRetiredInTotal': includeRetiredInTotal,
    'reminderEnabled': reminderEnabled,
    'hapticsEnabled': hapticsEnabled,
    'nativeHapticsEnabled': nativeHapticsEnabled,
    'compactSnackbars': compactSnackbars,
    'defaultHomeViewMode': defaultHomeViewMode.name,
    'stickerEngineMode': stickerEngineMode.name,
    'keepStickerCandidates': keepStickerCandidates,
    'homeMetaFontScale': homeMetaFontScale,
    'onboardingCompleted': onboardingCompleted,
    'cloudSync': cloudSync.toMap(),
  };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
    currencyUnit:
        map['currencyUnit']?.toString() ?? map['currency']?.toString() ?? '¥',
    decimalPlaces: asInt(map['decimalPlaces'], fallback: 2).clamp(0, 3).toInt(),
    useThousandsSeparator: map['useThousandsSeparator'] != false,
    durationMode: DurationMode.values.firstWhere(
      (e) => e.name == map['durationMode']?.toString(),
      orElse: () => DurationMode.days,
    ),
    theme: ThemeSetting.values.firstWhere(
      (e) => e.name == map['theme']?.toString(),
      orElse: () =>
          map['darkMode'] == true ? ThemeSetting.dark : ThemeSetting.light,
    ),
    includeRetiredInTotal: map['includeRetiredInTotal'] != false,
    reminderEnabled: map['reminderEnabled'] == true,
    hapticsEnabled: map['hapticsEnabled'] != false,
    nativeHapticsEnabled: map['nativeHapticsEnabled'] != false,
    compactSnackbars: map['compactSnackbars'] != false,
    defaultHomeViewMode: HomeViewModeX.fromValue(
      map['defaultHomeViewMode']?.toString(),
    ),
    stickerEngineMode: StickerEngineModeX.fromValue(
      map['stickerEngineMode']?.toString(),
    ),
    keepStickerCandidates: map['keepStickerCandidates'] == true,
    homeMetaFontScale: (asDouble(
      map['homeMetaFontScale'],
      fallback: 1.0,
    )).clamp(0.82, 1.12).toDouble(),
    onboardingCompleted: map['onboardingCompleted'] == true,
    cloudSync: CloudSyncSettings.fromMap(
      map['cloudSync'] is Map
          ? Map<String, dynamic>.from(map['cloudSync'])
          : null,
    ),
  );
}

class SnapshotRecord {
  final String id;
  final String label;
  final String payload;
  final DateTime createdAt;

  const SnapshotRecord({
    required this.id,
    required this.label,
    required this.payload,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'label': label,
    'payload': payload,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SnapshotRecord.fromMap(Map<String, dynamic> map) => SnapshotRecord(
    id: map['id']?.toString() ?? newId('snapshot'),
    label: map['label']?.toString() ?? '本机快照',
    payload: map['payload']?.toString() ?? '{}',
    createdAt: parsePersistedDate(map['createdAt'], fallback: DateTime.now()),
  );
}
