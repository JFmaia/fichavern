import 'package:flutter_test/flutter_test.dart';

import 'package:fichavern/main.dart';

void main() {
  testWidgets('FichavApp renderiza sem erros', (WidgetTester tester) async {
    await tester.pumpWidget(const FichavApp());
    expect(find.text('Fichavern — M4 pronto'), findsOneWidget);
  });
}
