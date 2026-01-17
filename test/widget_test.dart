import 'package:flutter_test/flutter_test.dart';
import 'package:totsparis2/src/app.dart';

void main() {
  testWidgets('WebView Smoke Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(App());

    // Basic check to see if the app starts.
    expect(find.byType(App), findsOneWidget);
  });
}
