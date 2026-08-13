import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('analytics snapshot is stable until the store revision changes', () {
    final store = AppStore();
    final first = store.analyticsSnapshot;
    final revision = store.analyticsRevision;

    expect(identical(first, store.analyticsSnapshot), isTrue);
    expect(store.analyticsRevision, revision);

    final asset = _asset(
      id: 'asset-camera',
      categoryId: 'category-photo',
      tagIds: const ['tag-favorite'],
      price: 1200,
    );
    final payload = store.exportMap(includeSnapshots: false)
      ..['categories'] = [
        Category(
          id: 'category-photo',
          name: 'Photo',
          icon: '📷',
          color: '#7cc6f2',
          sortOrder: 0,
          createdAt: dateTimeStorageText(DateTime(2026, 1, 1)),
          updatedAt: dateTimeStorageText(DateTime(2026, 1, 1)),
        ).toMap(),
      ]
      ..['tags'] = [
        Tag(
          id: 'tag-favorite',
          name: 'Favorite',
          color: '#7cc6f2',
          sortOrder: 0,
          createdAt: dateTimeStorageText(DateTime(2026, 1, 1)),
          updatedAt: dateTimeStorageText(DateTime(2026, 1, 1)),
        ).toMap(),
      ]
      ..['assets'] = [asset.toMap()];
    store.importMap(payload);

    final second = store.analyticsSnapshot;
    expect(store.analyticsRevision, greaterThan(revision));
    expect(identical(first, second), isFalse);
    expect(second.categoryDistribution.keys, contains('category-photo'));
    expect(second.tagDistribution.keys, contains('tag-favorite'));
    expect(identical(second, store.analyticsSnapshot), isTrue);
  });
}

Asset _asset({
  required String id,
  required String categoryId,
  required List<String> tagIds,
  required double price,
}) {
  final now = DateTime.now();
  return Asset(
    id: id,
    name: 'Camera',
    iconValue: '📷',
    price: price,
    purchaseDate: now.subtract(const Duration(days: 20)),
    categoryId: categoryId,
    tagIds: tagIds,
    addons: const [],
    note: '',
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
    createdAt: now,
    updatedAt: now,
  );
}
