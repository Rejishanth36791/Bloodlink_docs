import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bloodlink_mobile/main.dart';

void main() {
  testWidgets('BloodLink App initializes smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: BloodLinkApp()));
    expect(find.byType(BloodLinkApp), findsOneWidget);
  });
}
