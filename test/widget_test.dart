import 'package:flutter_test/flutter_test.dart';

import 'package:wired/main.dart';

void main() {
  testWidgets('app boots and shows the placeholder screen', (tester) async {
    await tester.pumpWidget(const WiredApp());
    expect(find.text('WIRED'), findsOneWidget);
  });
}
