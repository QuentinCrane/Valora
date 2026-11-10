import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('derives unique expiry reminders and persists their trigger time', () {
    // 触发时间必须落在未来，否则 store 会把提醒标记为已过期（enabled=false）。
    final today = DateTime.now();
    final expiry = DateTime(today.year, today.month, today.day)
        .add(const Duration(days: 30));
    final triggerDay = DateTime(expiry.year, expiry.month, expiry.day)
        .subtract(const Duration(days: 7));
    final store = AppStore()
      ..settings = const AppSettings(reminderEnabled: true)
      ..assets.addAll([
        _asset('asset-a', 'Camera A', expiry),
        _asset('asset-b', 'Camera B', expiry),
      ]);

    final reminders =
        (store.exportMap()['reminders'] as List).cast<Map<String, dynamic>>();

    expect(reminders, hasLength(2));
    expect(reminders.map((item) => item['id']).toSet(),
        {'asset:asset-a:expiry', 'asset:asset-b:expiry'});
    expect(reminders.every((item) => item['enabled'] == true), isTrue);
    expect(
        reminders
            .every((item) => item['triggerDate'] == isoDateText(triggerDay)),
        isTrue);
    final expectedTrigger = dateTimeStorageText(
        DateTime(triggerDay.year, triggerDay.month, triggerDay.day, 9));
    expect(reminders.every((item) => item['triggerAt'] == expectedTrigger),
        isTrue);
  });

  test('disabling reminders keeps records but prevents scheduling', () {
    final store = AppStore()
      ..settings = const AppSettings(reminderEnabled: false)
      ..assets.add(_asset('asset-a', 'Camera A', DateTime(2026, 9, 10)));

    final reminders =
        (store.exportMap()['reminders'] as List).cast<Map<String, dynamic>>();

    expect(reminders, hasLength(1));
    expect(reminders.single['enabled'], isFalse);
  });

  test('reminder records round-trip and disappear with the source asset', () {
    final original = AppStore()
      ..settings = const AppSettings(reminderEnabled: true)
      ..assets.add(_asset('asset-a', 'Camera A', DateTime(2026, 9, 10)));
    final exported = original.exportMap();

    final restored = AppStore()..importMap(exported);
    expect(restored.reminders, hasLength(1));
    expect(restored.exportMap()['reminders'], hasLength(1));

    restored.assets.clear();
    expect(restored.exportMap()['reminders'], isEmpty);
  });
}

String isoDateText(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

Asset _asset(String id, String name, DateTime expiresAt) {
  final now = DateTime(2026, 8, 13);
  return Asset(
    id: id,
    name: name,
    iconValue: '📦',
    price: 100,
    purchaseDate: now,
    categoryId: null,
    tagIds: const [],
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
    expiresAt: expiresAt,
    remindBeforeDays: 7,
    createdAt: now,
    updatedAt: now,
  );
}
