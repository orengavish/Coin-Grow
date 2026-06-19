import 'package:flutter_test/flutter_test.dart';
import 'package:coin_grow/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CoinGrowApp());
    expect(find.text('Coin Grow'), findsOneWidget);
  });
}
