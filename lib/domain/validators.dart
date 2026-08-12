// Pure Dart validation rules shared by asset, wish, and quick-create flows.
//
// This file intentionally has no Flutter or persistence dependencies. UI
// layers translate DomainIssue.key into localized copy, while repositories
// can reject the same invalid values before they are persisted.

class DomainIssue {
  final String key;
  final String field;

  const DomainIssue(this.key, this.field);
}

class DomainValidationResult {
  final List<DomainIssue> issues;

  const DomainValidationResult(this.issues);

  bool get isValid => issues.isEmpty;
  DomainIssue? get firstIssue => issues.isEmpty ? null : issues.first;
}

class DomainValidationException implements Exception {
  final List<DomainIssue> issues;

  const DomainValidationException(this.issues);

  DomainIssue get firstIssue => issues.first;

  @override
  String toString() => 'DomainValidationException(${firstIssue.key})';
}

class AddonInput {
  final String name;
  final double price;
  final DateTime? purchaseDate;
  final bool followsParentPurchaseDate;

  const AddonInput({
    required this.name,
    required this.price,
    this.purchaseDate,
    this.followsParentPurchaseDate = false,
  });
}

class AssetValidationInput {
  final String name;
  final bool priceless;
  final double price;
  final DateTime purchaseDate;
  final bool isRetired;
  final DateTime? retiredAt;
  final bool isSold;
  final DateTime? soldAt;
  final double? soldPrice;
  final DateTime? expiresAt;
  final List<AddonInput> addons;

  const AssetValidationInput({
    required this.name,
    required this.priceless,
    required this.price,
    required this.purchaseDate,
    required this.isRetired,
    required this.retiredAt,
    required this.isSold,
    required this.soldAt,
    required this.soldPrice,
    required this.expiresAt,
    required this.addons,
  });
}

class WishValidationInput {
  final String name;
  final double expectedPrice;
  final List<AddonInput> addons;

  const WishValidationInput({
    required this.name,
    required this.expectedPrice,
    required this.addons,
  });
}

class RecoveryValidationInput {
  final double amount;
  final DateTime date;
  final DateTime purchaseDate;
  final DateTime? lifecycleEnd;
  final List<String> assetIds;

  const RecoveryValidationInput({
    required this.amount,
    required this.date,
    required this.purchaseDate,
    required this.lifecycleEnd,
    required this.assetIds,
  });
}

class DomainValidators {
  const DomainValidators._();

  static DomainValidationResult asset(
    AssetValidationInput input, {
    DateTime? today,
  }) {
    final issues = <DomainIssue>[];
    _name(input.name, issues);
    if (!input.priceless) _money(input.price, 'price', issues);
    _purchaseDate(input.purchaseDate, issues, today: today);
    _lifecycle(
      purchaseDate: input.purchaseDate,
      isRetired: input.isRetired,
      retiredAt: input.retiredAt,
      isSold: input.isSold,
      soldAt: input.soldAt,
      soldPrice: input.soldPrice,
      issues: issues,
      today: today,
    );
    if (input.expiresAt != null &&
        _day(input.expiresAt!).isBefore(_day(input.purchaseDate))) {
      issues
          .add(const DomainIssue('validation.dateBeforePurchase', 'expiresAt'));
    }
    _addons(input.addons, input.purchaseDate, issues, today: today);
    return DomainValidationResult(List.unmodifiable(issues));
  }

  static DomainValidationResult wish(
    WishValidationInput input, {
    DateTime? today,
  }) {
    final issues = <DomainIssue>[];
    _name(input.name, issues);
    _money(input.expectedPrice, 'expectedPrice', issues);
    _addons(input.addons, null, issues, today: today);
    return DomainValidationResult(List.unmodifiable(issues));
  }

  static DomainValidationResult recovery(
    RecoveryValidationInput input, {
    DateTime? today,
  }) {
    final issues = <DomainIssue>[];
    _money(input.amount, 'amount', issues);
    if (input.assetIds.isEmpty) {
      issues.add(
          const DomainIssue('validation.recoveryAssetRequired', 'assetIds'));
    }
    final date = _day(input.date);
    final purchase = _day(input.purchaseDate);
    if (date.isBefore(purchase)) {
      issues.add(
          const DomainIssue('validation.recoveryDateOutsideLifecycle', 'date'));
    }
    if (input.lifecycleEnd != null && date.isAfter(_day(input.lifecycleEnd!))) {
      issues.add(
          const DomainIssue('validation.recoveryDateOutsideLifecycle', 'date'));
    }
    if (date.isAfter(_day(today ?? DateTime.now()))) {
      issues.add(const DomainIssue('validation.lifecycleDateFuture', 'date'));
    }
    return DomainValidationResult(List.unmodifiable(issues));
  }

  static DomainValidationResult addon(
    AddonInput input, {
    DateTime? parentPurchaseDate,
    DateTime? today,
  }) {
    final issues = <DomainIssue>[];
    if (input.name.trim().isEmpty) {
      issues.add(const DomainIssue('validation.addonNameRequired', 'name'));
    }
    _money(input.price, 'price', issues);
    if (input.purchaseDate != null) {
      if (parentPurchaseDate != null &&
          _day(input.purchaseDate!).isBefore(_day(parentPurchaseDate))) {
        issues.add(
            const DomainIssue('validation.dateBeforePurchase', 'purchaseDate'));
      }
      if (_day(input.purchaseDate!).isAfter(_day(today ?? DateTime.now()))) {
        issues.add(
            const DomainIssue('validation.purchaseDateFuture', 'purchaseDate'));
      }
    }
    return DomainValidationResult(List.unmodifiable(issues));
  }

  static DomainValidationResult label(String value, {String field = 'name'}) {
    if (value.trim().isEmpty) {
      return DomainValidationResult(<DomainIssue>[
        DomainIssue('validation.nameRequired', field),
      ]);
    }
    return const DomainValidationResult(<DomainIssue>[]);
  }

  static void _name(String value, List<DomainIssue> issues) {
    if (value.trim().isEmpty) {
      issues.add(const DomainIssue('validation.nameRequired', 'name'));
    }
  }

  static void _money(double value, String field, List<DomainIssue> issues) {
    if (!value.isFinite) {
      issues.add(DomainIssue('validation.moneyInvalid', field));
    } else if (value < 0) {
      issues.add(DomainIssue('validation.moneyNegative', field));
    }
  }

  static void _purchaseDate(
    DateTime value,
    List<DomainIssue> issues, {
    DateTime? today,
  }) {
    if (_day(value).isAfter(_day(today ?? DateTime.now()))) {
      issues.add(
          const DomainIssue('validation.purchaseDateFuture', 'purchaseDate'));
    }
  }

  static void _lifecycle({
    required DateTime purchaseDate,
    required bool isRetired,
    required DateTime? retiredAt,
    required bool isSold,
    required DateTime? soldAt,
    required double? soldPrice,
    required List<DomainIssue> issues,
    DateTime? today,
  }) {
    if (isRetired && retiredAt == null) {
      issues.add(
          const DomainIssue('validation.retiredDateRequired', 'retiredAt'));
    }
    if (isSold && soldAt == null) {
      issues.add(const DomainIssue('validation.soldDateRequired', 'soldAt'));
    }
    if (soldPrice != null) _money(soldPrice, 'soldPrice', issues);
    for (final entry in <String, DateTime?>{
      'retiredAt': retiredAt,
      'soldAt': soldAt,
    }.entries) {
      final date = entry.value;
      if (date == null) continue;
      if (_day(date).isBefore(_day(purchaseDate))) {
        issues.add(const DomainIssue(
            'validation.dateBeforePurchase', 'lifecycleDate'));
      }
      if (_day(date).isAfter(_day(today ?? DateTime.now()))) {
        issues.add(const DomainIssue(
            'validation.lifecycleDateFuture', 'lifecycleDate'));
      }
    }
  }

  static void _addons(
    List<AddonInput> addons,
    DateTime? parentPurchaseDate,
    List<DomainIssue> issues, {
    DateTime? today,
  }) {
    for (var index = 0; index < addons.length; index++) {
      final result = addon(
        addons[index],
        parentPurchaseDate: parentPurchaseDate,
        today: today,
      );
      for (final issue in result.issues) {
        issues.add(DomainIssue(issue.key, 'addons[$index].${issue.field}'));
      }
    }
  }

  static DateTime _day(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
