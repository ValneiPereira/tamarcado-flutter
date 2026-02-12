import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tamarcado_flutter/app.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: TamarcadoApp()),
    );

    expect(find.text('Tá Marcado!'), findsAtLeast(1));
  });
}
