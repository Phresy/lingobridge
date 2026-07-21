import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lingobridge/app.dart';

void main() {
  testWidgets('LingoBridge app test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: LingoBridgeApp(),
      ),
    );
    expect(find.text('LingoBridge'), findsWidgets);
  });
}