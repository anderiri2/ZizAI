import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perretxikotan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('PerretxikotanApp renders SplashScreen and transitions to LoginScreen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(
        child: PerretxikotanApp(),
      ),
    );

    expect(find.text('Perretxikotan'), findsOneWidget);

    // Advance past the splash screen timer (2600ms) and animations
    await tester.pump(const Duration(milliseconds: 2800));
    await tester.pumpAndSettle();

    expect(find.textContaining('Iniciar sesión con Google'), findsOneWidget);
    expect(find.textContaining('Continuar en modo local (Offline)'), findsOneWidget);
  });
}
