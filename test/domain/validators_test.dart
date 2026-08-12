import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/domain/validators.dart';

void main() {
  final today = DateTime(2026, 8, 12);
  final purchaseDate = DateTime(2026, 8, 1);

  test('accepts a normal asset and wish payload', () {
    final asset = DomainValidators.asset(
      AssetValidationInput(
        name: 'Camera',
        priceless: false,
        price: 1200,
        purchaseDate: purchaseDate,
        isRetired: false,
        retiredAt: null,
        isSold: false,
        soldAt: null,
        soldPrice: null,
        expiresAt: DateTime(2027, 8, 1),
        addons: [
          AddonInput(
            name: 'Strap',
            price: 30,
            purchaseDate: DateTime(2026, 8, 2),
          ),
        ],
      ),
      today: today,
    );
    final wish = DomainValidators.wish(
      const WishValidationInput(
        name: 'Desk lamp',
        expectedPrice: 90,
        addons: [AddonInput(name: 'Bulb', price: 10)],
      ),
      today: today,
    );

    expect(asset.isValid, isTrue);
    expect(wish.isValid, isTrue);
  });

  test('rejects invalid money and future dates', () {
    final result = DomainValidators.asset(
      AssetValidationInput(
        name: 'Camera',
        priceless: false,
        price: double.infinity,
        purchaseDate: DateTime(2026, 8, 13),
        isRetired: false,
        retiredAt: null,
        isSold: false,
        soldAt: null,
        soldPrice: -1,
        expiresAt: DateTime(2026, 7, 31),
        addons: const [AddonInput(name: '', price: -1)],
      ),
      today: today,
    );

    expect(
      result.issues.map((issue) => issue.key),
      containsAll(<String>[
        'validation.moneyInvalid',
        'validation.purchaseDateFuture',
        'validation.moneyNegative',
        'validation.dateBeforePurchase',
        'validation.addonNameRequired',
      ]),
    );
  });

  test('requires lifecycle dates for retired and sold assets', () {
    final result = DomainValidators.asset(
      AssetValidationInput(
        name: 'Phone',
        priceless: false,
        price: 500,
        purchaseDate: purchaseDate,
        isRetired: true,
        retiredAt: null,
        isSold: true,
        soldAt: null,
        soldPrice: 300,
        expiresAt: null,
        addons: const [],
      ),
      today: today,
    );

    expect(
      result.issues.map((issue) => issue.key),
      containsAll(<String>[
        'validation.retiredDateRequired',
        'validation.soldDateRequired',
      ]),
    );
  });

  test('keeps recovery records inside the referenced asset lifecycle', () {
    final beforePurchase = DomainValidators.recovery(
      RecoveryValidationInput(
        amount: 20,
        date: DateTime(2026, 7, 31),
        purchaseDate: purchaseDate,
        lifecycleEnd: DateTime(2026, 8, 10),
        assetIds: const ['asset-1'],
      ),
      today: today,
    );
    final afterLifecycle = DomainValidators.recovery(
      RecoveryValidationInput(
        amount: -1,
        date: DateTime(2026, 8, 11),
        purchaseDate: purchaseDate,
        lifecycleEnd: DateTime(2026, 8, 10),
        assetIds: const [],
      ),
      today: today,
    );

    expect(
      beforePurchase.issues.map((issue) => issue.key),
      contains('validation.recoveryDateOutsideLifecycle'),
    );
    expect(
      afterLifecycle.issues.map((issue) => issue.key),
      containsAll(<String>[
        'validation.moneyNegative',
        'validation.recoveryAssetRequired',
        'validation.recoveryDateOutsideLifecycle',
      ]),
    );
  });

  test('throws a structured exception for repository callers', () {
    expect(
      () => throw DomainValidationException(
        DomainValidators.label('').issues,
      ),
      throwsA(
        isA<DomainValidationException>().having(
          (error) => error.firstIssue.key,
          'firstIssue.key',
          'validation.nameRequired',
        ),
      ),
    );
  });
}
