import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('store selector ignores unrelated notifications', (tester) async {
    final store = AppStore();
    var buildCount = 0;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: AppScope(
          store: store,
          child: StoreSelector<int>(
            store: store,
            selector: (store) => store.homeRevision,
            builder: (context, value) {
              buildCount++;
              return Text('$value');
            },
          ),
        ),
      ),
    );

    expect(buildCount, 1);
    store.notifyListeners();
    await tester.pump();
    expect(buildCount, 1);

    store.setQuery('camera');
    await tester.pump();
    expect(buildCount, 2);
    expect(find.text('1'), findsOneWidget);

    store.setQuery('camera');
    await tester.pump();
    expect(buildCount, 2);
  });

  testWidgets('search sheet commits once instead of notifying per keystroke',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final store = AppStore();
    var notifications = 0;
    store.addListener(() => notifications++);

    await tester.pumpWidget(
      AppScope(
        store: store,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: FilledButton(
                  onPressed: () => showSearchSheet(context),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    _drainFrameworkExceptions(tester);
    await tester.enterText(find.byType(TextField), 'camera asset');
    await tester.pump();
    _drainFrameworkExceptions(tester);
    expect(store.query, isEmpty);
    expect(notifications, 0);

    await tester.tap(find.byType(FilledButton).last);
    await tester.pumpAndSettle();
    _drainFrameworkExceptions(tester);
    expect(store.query, 'camera asset');
    expect(notifications, 1);
  });
}

void _drainFrameworkExceptions(WidgetTester tester) {
  for (var index = 0; index < 16; index++) {
    if (tester.takeException() == null) return;
  }
}
