import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:valora_assets/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sliver page builds only visible sections', (tester) async {
    final builtSections = <int>{};
    final sections = List<WidgetBuilder>.generate(
      100,
      (index) => (context) {
        builtSections.add(index);
        return SizedBox(
          height: 80,
          child: Text('section $index'),
        );
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: SliverPageFrame(
          scrollKey: const PageStorageKey<String>('sliver-test'),
          sections: sections,
        ),
      ),
    );

    expect(builtSections.length, lessThan(100));

    await tester.drag(
      find.byType(Scrollable),
      const Offset(0, -800),
    );
    await tester.pump();

    expect(builtSections.length, lessThan(100));
    expect(find.text('section 99'), findsNothing);
  });
}
