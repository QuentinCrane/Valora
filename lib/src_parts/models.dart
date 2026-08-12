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
      purchaseDate == null ? tl('未设置购买时间') : dateText(purchaseDate!);
  DateTime? effectivePurchaseDate(DateTime parentPurchaseDate) =>
      followParentPurchaseDate ? parentPurchaseDate : purchaseDate;
  String effectivePurchaseDateLabel(DateTime parentPurchaseDate) =>
      followParentPurchaseDate
          ? tlf('跟随父资产：{date}', {'date': dateText(parentPurchaseDate)})
          : purchaseDateLabel;

  AddonItem copyWith(
          {String? id,
          String? name,
          double? price,
          DateTime? purchaseDate,
          bool? clearPurchaseDate,
          bool? followParentPurchaseDate,
          bool? includeInTotal,
          bool? includeInDailyCost}) =>
      AddonItem(
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
        'purchaseDate':
            purchaseDate == null ? null : dateStorageText(purchaseDate!),
        'purchaseDateYmd':
            purchaseDate == null ? null : dateStorageText(purchaseDate!),
        'purchaseDateEpochDay':
            purchaseDate == null ? null : dateEpochDay(purchaseDate!),
        'followParentPurchaseDate': followParentPurchaseDate,
        'includeInTotal': includeInTotal,
        'includeInDailyCost': includeInDailyCost,
      };

  factory AddonItem.fromMap(Map<String, dynamic> map) => AddonItem(
        id: map['id']?.toString() ?? newId('addon'),
        name: map['name']?.toString() ?? tr('model.addonItem'),
        price: asDouble(map['price']),
        purchaseDate: parseOptionalPersistedDate(
                map['purchaseDateYmd'] ?? map['purchaseDate']) ??
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

  ValueRecoveryRecord copyWith(
          {String? title,
          List<String>? assetIds,
          double? amount,
          DateTime? date,
          String? note}) =>
      ValueRecoveryRecord(
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
        'createdAt': dateTimeStorageText(createdAt),
        'updatedAt': dateTimeStorageText(updatedAt),
      };

  factory ValueRecoveryRecord.fromMap(Map<String, dynamic> map) =>
      ValueRecoveryRecord(
        id: map['id']?.toString() ?? newId('recovery'),
        title: map['title']?.toString() ?? tr('model.valueRecovery'),
        assetIds: ((map['assetIds'] as List?) ?? [])
            .map((e) => e.toString())
            .where((e) => e.trim().isNotEmpty)
            .toList(),
        amount: asDouble(map['amount']),
        date: parsePersistedRequiredDate(map['date'],
            fallback:
                parseOptionalPersistedDate(map['createdAt']) ?? DateTime.now()),
        note: map['note']?.toString() ?? '',
        createdAt:
            parsePersistedDateTime(map['createdAt'], fallback: DateTime.now()),
        updatedAt:
            parsePersistedDateTime(map['updatedAt'], fallback: DateTime.now()),
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

  const Category(
      {required this.id,
      required this.name,
      required this.icon,
      required this.color,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});

  Category copyWith(
          {String? name, String? icon, String? color, int? sortOrder}) =>
      Category(
        id: id,
        name: name ?? this.name,
        icon: icon ?? this.icon,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
        updatedAt: dateTimeStorageText(DateTime.now()),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'sortOrder': sortOrder,
        'createdAt': createdAt,
        'updatedAt': updatedAt
      };

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id']?.toString() ?? newId('cat'),
        name: map['name']?.toString() ?? tr('model.uncategorized'),
        icon: map['icon']?.toString() ?? '📦',
        color: map['color']?.toString() ?? '#7cc6f2',
        sortOrder: asInt(map['sortOrder']),
        createdAt: persistedDateTimeTextOrNow(map['createdAt']),
        updatedAt: persistedDateTimeTextOrNow(map['updatedAt']),
      );
}

class Tag {
  final String id;
  final String name;
  final String color;
  final int sortOrder;
  final String createdAt;
  final String updatedAt;

  const Tag(
      {required this.id,
      required this.name,
      required this.color,
      required this.sortOrder,
      required this.createdAt,
      required this.updatedAt});

  Tag copyWith({String? name, String? color, int? sortOrder}) => Tag(
        id: id,
        name: name ?? this.name,
        color: color ?? this.color,
        sortOrder: sortOrder ?? this.sortOrder,
        createdAt: createdAt,
        updatedAt: dateTimeStorageText(DateTime.now()),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'color': color,
        'sortOrder': sortOrder,
        'createdAt': createdAt,
        'updatedAt': updatedAt
      };

  factory Tag.fromMap(Map<String, dynamic> map) => Tag(
        id: map['id']?.toString() ?? newId('tag'),
        name: map['name']?.toString() ?? tr('model.tag'),
        color: map['color']?.toString() ?? '#7cc6f2',
        sortOrder: asInt(map['sortOrder']),
        createdAt: persistedDateTimeTextOrNow(map['createdAt']),
        updatedAt: persistedDateTimeTextOrNow(map['updatedAt']),
      );
}

class Asset {
  final String id;
  final String name;
  final String iconValue;
  final AssetValueMode valueMode;
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
    this.valueMode = AssetValueMode.priced,
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

  DateTime serviceEndDateAt(DateTime asOf) {
    final cursor = dateOnly(asOf);
    final lifecycleDate = status == AssetStatus.sold
        ? soldAt
        : status == AssetStatus.retired
            ? retiredAt
            : null;
    if (lifecycleDate == null) return cursor;
    final end = dateOnly(lifecycleDate);
    return end.isBefore(cursor) ? end : cursor;
  }

  DateTime get serviceEndDate => serviceEndDateAt(DateTime.now());

  int serviceDaysAt(DateTime asOf) {
    final cursor = dateOnly(asOf);
    if (dateOnly(purchaseDate).isAfter(cursor)) return 0;
    return diffDaysInclusive(purchaseDate, serviceEndDateAt(cursor));
  }

  int get serviceDays => serviceDaysAt(DateTime.now());
  bool get isPriceless => valueMode == AssetValueMode.priceless;
  double get addonTotal => addons.fold(
      0.0, (sum, item) => sum + (item.includeInTotal ? item.price : 0));
  double get dailyAddonTotal => addons.fold(
      0.0, (sum, item) => sum + (item.includeInDailyCost ? item.price : 0));
  double get acquisitionCost => isPriceless ? 0 : price + addonTotal;

  double addonCostAt(DateTime asOf, {required bool forDailyCost}) {
    final cursor = dateOnly(asOf);
    final parentDate = dateOnly(purchaseDate);
    return addons.fold(0.0, (sum, addon) {
      final include =
          forDailyCost ? addon.includeInDailyCost : addon.includeInTotal;
      if (!include) return sum;
      final addonDate =
          dateOnly(addon.effectivePurchaseDate(parentDate) ?? parentDate);
      return addonDate.isAfter(cursor) ? sum : sum + addon.price;
    });
  }

  double soldRecoveryAt(DateTime asOf) {
    if (status != AssetStatus.sold || soldAt == null) return 0;
    return dateOnly(soldAt!).isAfter(dateOnly(asOf)) ? 0 : (soldPrice ?? 0);
  }

  double acquisitionCostAt(DateTime asOf, {required bool forDailyCost}) {
    if (isPriceless || dateOnly(purchaseDate).isAfter(dateOnly(asOf))) return 0;
    return price + addonCostAt(asOf, forDailyCost: forDailyCost);
  }

  double netCostAt(DateTime asOf) =>
      acquisitionCostAt(asOf, forDailyCost: false) - soldRecoveryAt(asOf);

  double get totalDisplayValue => acquisitionCost;
  double get netCost => netCostAt(DateTime.now());

  double dailyCostAt(DateTime asOf, {double recovered = 0}) {
    if (isPriceless || !includeInDailyCost) return 0;
    final days = serviceDaysAt(asOf);
    if (days <= 0) return 0;
    final cost = acquisitionCostAt(asOf, forDailyCost: true) -
        soldRecoveryAt(asOf) -
        recovered;
    return cost / days;
  }

  double get dailyCost => dailyCostAt(DateTime.now());
  double get assetValue {
    if (isPriceless) return 0;
    if (!includeInTotal) return 0;
    if (status == AssetStatus.sold) return 0;
    return acquisitionCost;
  }

  double get targetRatio {
    if (isPriceless && targetMode == TargetMode.daily) return 0;
    if (targetMode == TargetMode.daily && (targetDailyCost ?? 0) > 0) {
      return ((targetDailyCost ?? 0) / math.max(dailyCost, 0.01))
          .clamp(0, 1)
          .toDouble();
    }
    if (targetMode == TargetMode.date && targetDate != null) {
      final totalDays = diffDaysInclusive(purchaseDate, targetDate!);
      final passedDays = diffDaysInclusive(purchaseDate,
          DateTime.now().isAfter(targetDate!) ? targetDate! : DateTime.now());
      return (passedDays / math.max(totalDays, 1)).clamp(0, 1).toDouble();
    }
    if (targetMode == TargetMode.custom && (targetCustomDays ?? 0) > 0) {
      return (serviceDays / targetCustomDays!).clamp(0, 1).toDouble();
    }
    return 0;
  }

  int? get targetDays {
    if (isPriceless && targetMode == TargetMode.daily) return null;
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
    AssetValueMode? valueMode,
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
  }) =>
      Asset(
        id: id,
        name: name ?? this.name,
        iconValue: iconValue ?? this.iconValue,
        valueMode: valueMode ?? this.valueMode,
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
        'valueMode': valueMode.name,
        'isPriceless': isPriceless,
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
        'createdAt': dateTimeStorageText(createdAt),
        'updatedAt': dateTimeStorageText(updatedAt),
      };

  factory Asset.fromMap(Map<String, dynamic> map) {
    final valueMode =
        map['isPriceless'] == true || map['price']?.toString().trim() == '∞'
            ? AssetValueMode.priceless
            : AssetValueModeX.fromValue(map['valueMode']?.toString());
    final priceless = valueMode == AssetValueMode.priceless;
    final status = AssetStatusX.fromValue(map['status']?.toString());
    final targetMode = TargetModeX.fromValue(map['targetMode']?.toString());
    return Asset(
      id: map['id']?.toString() ?? newId('asset'),
      name: map['name']?.toString() ?? tr('model.unnamedAsset'),
      iconValue:
          map['iconValue']?.toString() ?? map['emoji']?.toString() ?? '📦',
      valueMode: valueMode,
      price: priceless ? 0 : asDouble(map['price']),
      purchaseDate: parsePersistedRequiredDate(
          map['purchaseDateYmd'] ?? map['purchaseDate'],
          fallback: dateFromEpochDay(map['purchaseDateEpochDay']) ??
              parseOptionalPersistedDate(map['createdAt']) ??
              parseOptionalPersistedDate(map['updatedAt'])),
      categoryId: map['categoryId']?.toString(),
      tagIds: ((map['tagIds'] as List?) ?? (map['tags'] as List?) ?? [])
          .map((e) => e.toString())
          .toList(),
      addons: priceless
          ? []
          : ((map['addons'] as List?) ?? [])
              .map((e) => AddonItem.fromMap(Map<String, dynamic>.from(e)))
              .toList(),
      note: map['note']?.toString() ?? '',
      status: priceless && status == AssetStatus.sold
          ? AssetStatus.serving
          : status,
      includeInTotal: priceless ? false : map['includeInTotal'] != false,
      includeInDailyCost:
          priceless ? false : map['includeInDailyCost'] != false,
      retiredAt: parseOptionalPersistedDate(map['retiredAt']),
      soldAt: priceless ? null : parseOptionalPersistedDate(map['soldAt']),
      soldPrice: priceless || map['soldPrice'] == null
          ? null
          : asDouble(map['soldPrice']),
      targetMode: priceless && targetMode == TargetMode.daily
          ? TargetMode.none
          : targetMode,
      targetDailyCost: priceless || map['targetDailyCost'] == null
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
      createdAt:
          parsePersistedDateTime(map['createdAt'], fallback: DateTime.now()),
      updatedAt:
          parsePersistedDateTime(map['updatedAt'], fallback: DateTime.now()),
    );
  }
}

class ReminderRecord {
  final String id;
  final String sourceId;
  final String type;
  final DateTime triggerDate;
  final DateTime triggerAt;
  final String title;
  final String body;
  final bool enabled;
  final String lastScheduleResult;
  final DateTime? lastScheduledAt;

  const ReminderRecord({
    required this.id,
    required this.sourceId,
    required this.type,
    required this.triggerDate,
    required this.triggerAt,
    required this.title,
    required this.body,
    required this.enabled,
    this.lastScheduleResult = 'pending',
    this.lastScheduledAt,
  });

  ReminderRecord copyWith({
    DateTime? triggerDate,
    DateTime? triggerAt,
    String? title,
    String? body,
    bool? enabled,
    String? lastScheduleResult,
    DateTime? lastScheduledAt,
  }) =>
      ReminderRecord(
        id: id,
        sourceId: sourceId,
        type: type,
        triggerDate: triggerDate ?? this.triggerDate,
        triggerAt: triggerAt ?? this.triggerAt,
        title: title ?? this.title,
        body: body ?? this.body,
        enabled: enabled ?? this.enabled,
        lastScheduleResult: lastScheduleResult ?? this.lastScheduleResult,
        lastScheduledAt: lastScheduledAt ?? this.lastScheduledAt,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'sourceId': sourceId,
        'type': type,
        'triggerDate': dateStorageText(triggerDate),
        'triggerAt': dateTimeStorageText(triggerAt),
        'title': title,
        'body': body,
        'enabled': enabled,
        'lastScheduleResult': lastScheduleResult,
        'lastScheduledAt': lastScheduledAt == null
            ? null
            : dateTimeStorageText(lastScheduledAt!),
      };

  factory ReminderRecord.fromMap(Map<String, dynamic> map) {
    final triggerAt =
        parsePersistedDateTime(map['triggerAt'], fallback: DateTime.now());
    final triggerDate =
        parseOptionalPersistedDate(map['triggerDate']) ?? dateOnly(triggerAt);
    return ReminderRecord(
      id: map['id']?.toString() ?? newId('reminder'),
      sourceId: map['sourceId']?.toString() ?? '',
      type: map['type']?.toString() ?? 'asset_expiry',
      triggerDate: triggerDate,
      triggerAt: triggerAt,
      title: map['title']?.toString() ?? tr('notification.title'),
      body: map['body']?.toString() ?? '',
      enabled: map['enabled'] != false,
      lastScheduleResult: map['lastScheduleResult']?.toString() ?? 'pending',
      lastScheduledAt: parseOptionalPersistedDateTime(map['lastScheduledAt']),
    );
  }
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

  Wish copyWith(
          {String? name,
          String? iconValue,
          double? expectedPrice,
          String? note,
          String? categoryId,
          bool clearCategoryId = false,
          List<String>? tagIds,
          bool? archived,
          DateTime? convertedAt,
          bool clearConvertedAt = false,
          String? convertedAssetId,
          bool clearConvertedAssetId = false,
          List<AddonItem>? addons}) =>
      Wish(
        id: id,
        name: name ?? this.name,
        iconValue: iconValue ?? this.iconValue,
        expectedPrice: expectedPrice ?? this.expectedPrice,
        note: note ?? this.note,
        categoryId: clearCategoryId ? null : (categoryId ?? this.categoryId),
        tagIds: tagIds ?? this.tagIds,
        archived: archived ?? this.archived,
        convertedAt:
            clearConvertedAt ? null : (convertedAt ?? this.convertedAt),
        convertedAssetId: clearConvertedAssetId
            ? null
            : (convertedAssetId ?? this.convertedAssetId),
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
        'convertedAt':
            convertedAt == null ? null : dateStorageText(convertedAt!),
        'convertedAssetId': convertedAssetId,
        'addons': addons.map((e) => e.toMap()).toList(),
        'createdAt': dateTimeStorageText(createdAt),
        'updatedAt': dateTimeStorageText(updatedAt),
      };

  factory Wish.fromMap(Map<String, dynamic> map) => Wish(
        id: map['id']?.toString() ?? newId('wish'),
        name: map['name']?.toString() ?? tr('model.unnamedWish'),
        iconValue:
            map['iconValue']?.toString() ?? map['emoji']?.toString() ?? '✨',
        expectedPrice: asDouble(map['expectedPrice']),
        note: map['note']?.toString() ?? map['reason']?.toString() ?? '',
        categoryId: map['categoryId']?.toString(),
        tagIds:
            ((map['tagIds'] as List?) ?? []).map((e) => e.toString()).toList(),
        archived: map['archived'] == true || map['done'] == true,
        convertedAt: parseOptionalPersistedDate(map['convertedAt']),
        convertedAssetId: map['convertedAssetId']?.toString(),
        addons: ((map['addons'] as List?) ?? [])
            .map((e) => AddonItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt:
            parsePersistedDateTime(map['createdAt'], fallback: DateTime.now()),
        updatedAt:
            parsePersistedDateTime(map['updatedAt'], fallback: DateTime.now()),
      );
}

enum CloudSyncProvider {
  off,
  webdav,
  jianguoyun,
  nextcloud,
  customWebdav,
  manualFile
}

String cloudSyncProviderLabel(CloudSyncProvider provider) {
  switch (provider) {
    case CloudSyncProvider.off:
      return tr('cloud.off');
    case CloudSyncProvider.webdav:
      return 'WebDAV';
    case CloudSyncProvider.jianguoyun:
      return tr('cloud.jianguoyun');
    case CloudSyncProvider.nextcloud:
      return 'Nextcloud';
    case CloudSyncProvider.customWebdav:
      return tr('cloud.customWebdav');
    case CloudSyncProvider.manualFile:
      return tr('cloud.manualFile');
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
  final String? remoteEtag;
  final String? remoteContentHash;
  final int? remoteAssetCount;
  final int? remoteWishCount;
  final DateTime? remoteLastModifiedAt;

  const CloudSyncSettings({
    this.provider = CloudSyncProvider.off,
    this.serverUrl = '',
    this.username = '',
    this.password = '',
    this.remotePath = 'zhipu/zhipu_backup.json',
    this.autoUploadOnSave = false,
    this.syncOnLaunch = false,
    this.lastUploadAt,
    this.lastDownloadAt,
    this.remoteEtag,
    this.remoteContentHash,
    this.remoteAssetCount,
    this.remoteWishCount,
    this.remoteLastModifiedAt,
  });

  bool get enabled =>
      provider != CloudSyncProvider.off &&
      provider != CloudSyncProvider.manualFile &&
      serverUrl.trim().isNotEmpty;
  bool get hasCredentials =>
      username.trim().isNotEmpty || password.trim().isNotEmpty;
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
    String? remoteEtag,
    String? remoteContentHash,
    int? remoteAssetCount,
    int? remoteWishCount,
    DateTime? remoteLastModifiedAt,
    bool clearCredentials = false,
    bool clearLastUploadAt = false,
    bool clearLastDownloadAt = false,
    bool clearRemoteMetadata = false,
  }) =>
      CloudSyncSettings(
        provider: provider ?? this.provider,
        serverUrl: serverUrl ?? this.serverUrl,
        username: clearCredentials ? '' : (username ?? this.username),
        password: clearCredentials ? '' : (password ?? this.password),
        remotePath: remotePath ?? this.remotePath,
        autoUploadOnSave: autoUploadOnSave ?? this.autoUploadOnSave,
        syncOnLaunch: syncOnLaunch ?? this.syncOnLaunch,
        lastUploadAt:
            clearLastUploadAt ? null : (lastUploadAt ?? this.lastUploadAt),
        lastDownloadAt: clearLastDownloadAt
            ? null
            : (lastDownloadAt ?? this.lastDownloadAt),
        remoteEtag:
            clearRemoteMetadata ? null : (remoteEtag ?? this.remoteEtag),
        remoteContentHash: clearRemoteMetadata
            ? null
            : (remoteContentHash ?? this.remoteContentHash),
        remoteAssetCount: clearRemoteMetadata
            ? null
            : (remoteAssetCount ?? this.remoteAssetCount),
        remoteWishCount: clearRemoteMetadata
            ? null
            : (remoteWishCount ?? this.remoteWishCount),
        remoteLastModifiedAt: clearRemoteMetadata
            ? null
            : (remoteLastModifiedAt ?? this.remoteLastModifiedAt),
      );

  Map<String, dynamic> toMap() => {
        'provider': provider.name,
        'serverUrl': serverUrl,
        'credentialsStored': hasCredentials,
        'remotePath': remotePath,
        'autoUploadOnSave': autoUploadOnSave,
        'syncOnLaunch': syncOnLaunch,
        'lastUploadAt':
            lastUploadAt == null ? null : dateTimeStorageText(lastUploadAt!),
        'lastDownloadAt': lastDownloadAt == null
            ? null
            : dateTimeStorageText(lastDownloadAt!),
        'remoteEtag': remoteEtag,
        'remoteContentHash': remoteContentHash,
        'remoteAssetCount': remoteAssetCount,
        'remoteWishCount': remoteWishCount,
        'remoteLastModifiedAt': remoteLastModifiedAt == null
            ? null
            : dateTimeStorageText(remoteLastModifiedAt!),
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
          : 'zhipu/zhipu_backup.json',
      autoUploadOnSave: map['autoUploadOnSave'] == true,
      syncOnLaunch: map['syncOnLaunch'] == true,
      lastUploadAt: parseOptionalPersistedDateTime(map['lastUploadAt']),
      lastDownloadAt: parseOptionalPersistedDateTime(map['lastDownloadAt']),
      remoteEtag: map['remoteEtag']?.toString().trim().isNotEmpty == true
          ? map['remoteEtag'].toString()
          : null,
      remoteContentHash:
          map['remoteContentHash']?.toString().trim().isNotEmpty == true
              ? map['remoteContentHash'].toString()
              : null,
      remoteAssetCount: map['remoteAssetCount'] is num
          ? (map['remoteAssetCount'] as num).toInt()
          : int.tryParse(map['remoteAssetCount']?.toString() ?? ''),
      remoteWishCount: map['remoteWishCount'] is num
          ? (map['remoteWishCount'] as num).toInt()
          : int.tryParse(map['remoteWishCount']?.toString() ?? ''),
      remoteLastModifiedAt:
          parseOptionalPersistedDateTime(map['remoteLastModifiedAt']),
    );
  }
}

class AppSettings {
  final String currencyUnit;
  final int decimalPlaces;
  final bool useThousandsSeparator;
  final DurationMode durationMode;
  final ThemeSetting theme;
  final AppLanguageSetting language;
  final bool includeRetiredInTotal;
  final bool reminderEnabled;
  final bool hapticsEnabled;
  final bool nativeHapticsEnabled;
  final bool compactSnackbars;
  final HomeViewMode defaultHomeViewMode;
  final StickerEngineMode stickerEngineMode;
  final GlassEffectMode glassEffectMode;
  final double liquidGlassSoftness;
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
    this.language = AppLanguageSetting.system,
    this.includeRetiredInTotal = true,
    this.reminderEnabled = false,
    this.hapticsEnabled = true,
    this.nativeHapticsEnabled = true,
    this.compactSnackbars = true,
    this.defaultHomeViewMode = HomeViewMode.grid,
    this.stickerEngineMode = StickerEngineMode.balanced,
    this.glassEffectMode = GlassEffectMode.liquid,
    this.liquidGlassSoftness = .5,
    this.keepStickerCandidates = false,
    this.homeMetaFontScale = 1.0,
    this.onboardingCompleted = false,
    this.cloudSync = const CloudSyncSettings(),
  });

  AppSettings copyWith(
          {String? currencyUnit,
          int? decimalPlaces,
          bool? useThousandsSeparator,
          DurationMode? durationMode,
          ThemeSetting? theme,
          AppLanguageSetting? language,
          bool? includeRetiredInTotal,
          bool? reminderEnabled,
          bool? hapticsEnabled,
          bool? nativeHapticsEnabled,
          bool? compactSnackbars,
          HomeViewMode? defaultHomeViewMode,
          StickerEngineMode? stickerEngineMode,
          GlassEffectMode? glassEffectMode,
          double? liquidGlassSoftness,
          bool? keepStickerCandidates,
          double? homeMetaFontScale,
          bool? onboardingCompleted,
          CloudSyncSettings? cloudSync}) =>
      AppSettings(
        currencyUnit: currencyUnit ?? this.currencyUnit,
        decimalPlaces: decimalPlaces ?? this.decimalPlaces,
        useThousandsSeparator:
            useThousandsSeparator ?? this.useThousandsSeparator,
        durationMode: durationMode ?? this.durationMode,
        theme: theme ?? this.theme,
        language: language ?? this.language,
        includeRetiredInTotal:
            includeRetiredInTotal ?? this.includeRetiredInTotal,
        reminderEnabled: reminderEnabled ?? this.reminderEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        nativeHapticsEnabled: nativeHapticsEnabled ?? this.nativeHapticsEnabled,
        compactSnackbars: compactSnackbars ?? this.compactSnackbars,
        defaultHomeViewMode: defaultHomeViewMode ?? this.defaultHomeViewMode,
        stickerEngineMode: stickerEngineMode ?? this.stickerEngineMode,
        glassEffectMode: glassEffectMode ?? this.glassEffectMode,
        liquidGlassSoftness: liquidGlassSoftness ?? this.liquidGlassSoftness,
        keepStickerCandidates:
            keepStickerCandidates ?? this.keepStickerCandidates,
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
        'language': language.name,
        'includeRetiredInTotal': includeRetiredInTotal,
        'reminderEnabled': reminderEnabled,
        'hapticsEnabled': hapticsEnabled,
        'nativeHapticsEnabled': nativeHapticsEnabled,
        'compactSnackbars': compactSnackbars,
        'defaultHomeViewMode': defaultHomeViewMode.name,
        'stickerEngineMode': stickerEngineMode.name,
        'glassEffectMode': glassEffectMode.name,
        'liquidGlassSoftness': liquidGlassSoftness,
        'keepStickerCandidates': keepStickerCandidates,
        'homeMetaFontScale': homeMetaFontScale,
        'onboardingCompleted': onboardingCompleted,
        'cloudSync': cloudSync.toMap(),
      };

  factory AppSettings.fromMap(Map<String, dynamic> map) => AppSettings(
        currencyUnit: map['currencyUnit']?.toString() ??
            map['currency']?.toString() ??
            '¥',
        decimalPlaces:
            asInt(map['decimalPlaces'], fallback: 2).clamp(0, 3).toInt(),
        useThousandsSeparator: map['useThousandsSeparator'] != false,
        durationMode: DurationMode.values.firstWhere(
            (e) => e.name == map['durationMode']?.toString(),
            orElse: () => DurationMode.days),
        theme: ThemeSetting.values.firstWhere(
            (e) => e.name == map['theme']?.toString(),
            orElse: () => map['darkMode'] == true
                ? ThemeSetting.dark
                : ThemeSetting.light),
        language: AppLanguageSettingX.fromValue(map['language']?.toString()),
        includeRetiredInTotal: map['includeRetiredInTotal'] != false,
        reminderEnabled: map['reminderEnabled'] == true,
        hapticsEnabled: map['hapticsEnabled'] != false,
        nativeHapticsEnabled: map['nativeHapticsEnabled'] != false,
        compactSnackbars: map['compactSnackbars'] != false,
        defaultHomeViewMode:
            HomeViewModeX.fromValue(map['defaultHomeViewMode']?.toString()),
        stickerEngineMode:
            StickerEngineModeX.fromValue(map['stickerEngineMode']?.toString()),
        glassEffectMode:
            GlassEffectModeX.fromValue(map['glassEffectMode']?.toString()),
        liquidGlassSoftness: asDouble(map['liquidGlassSoftness'], fallback: .5)
            .clamp(0.0, 1.0)
            .toDouble(),
        keepStickerCandidates: map['keepStickerCandidates'] == true,
        homeMetaFontScale: (asDouble(map['homeMetaFontScale'], fallback: 1.0))
            .clamp(0.82, 1.12)
            .toDouble(),
        onboardingCompleted: map['onboardingCompleted'] == true,
        cloudSync: CloudSyncSettings.fromMap(map['cloudSync'] is Map
            ? Map<String, dynamic>.from(map['cloudSync'])
            : null),
      );
}

class SnapshotRecord {
  final String id;
  final String label;
  final String payload;
  final DateTime createdAt;

  const SnapshotRecord(
      {required this.id,
      required this.label,
      required this.payload,
      required this.createdAt});

  Map<String, dynamic> toMap() => {
        'id': id,
        'label': label,
        'payload': payload,
        'createdAt': dateTimeStorageText(createdAt),
        'createdAtIso': dateTimeStorageText(createdAt),
        'createdAtEpochMillis': createdAt.millisecondsSinceEpoch,
      };

  factory SnapshotRecord.fromMap(Map<String, dynamic> map) => SnapshotRecord(
        id: map['id']?.toString() ?? newId('snapshot'),
        label: map['label']?.toString() ?? tr('model.localSnapshot'),
        payload: map['payload']?.toString() ?? '{}',
        createdAt: parsePersistedDateTime(
          map['createdAtIso'] ??
              map['createdAt'] ??
              map['createdAtEpochMillis'],
          fallback: DateTime.now(),
        ),
      );
}
