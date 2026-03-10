import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spider_solitaire/app.dart';

void main() {
  testWidgets('App loads without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: SpiderSolitaireApp(),
      ),
    );
    expect(find.byType(SpiderSolitaireApp), findsOneWidget);
  });
}
