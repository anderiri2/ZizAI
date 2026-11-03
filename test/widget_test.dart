import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perretxikotan/core/localization/app_localizations.dart';
import 'package:perretxikotan/core/widgets/settings_drawer.dart';
import 'package:perretxikotan/features/map/presentation/map_screen.dart';
import 'package:perretxikotan/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
      'PerretxikotanApp renders Amanita caesarea SplashScreen and transitions to LoginScreen in Basque (EU) by default, and switches to ES and EN',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'perretxikotan_safety_accepted': true,
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: PerretxikotanApp(),
      ),
    );

    expect(find.text('Perretxikotan'), findsOneWidget);

    // Advance past the 2.0-second (2000ms) Amanita caesarea splash animation
    await tester.pump(const Duration(milliseconds: 2100));
    await tester.pumpAndSettle();

    // Default language is Basque (EU)
    expect(
      find.textContaining('Hasi saioa Google-rekin'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Jarraitu tokiko moduan (Offline)'),
      findsOneWidget,
    );

    // Switch language to Castellano (ES)
    await tester.tap(find.text('ES'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Iniciar sesión con Google'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Continuar en modo local (Offline)'),
      findsOneWidget,
    );

    // Switch language to English (EN)
    await tester.tap(find.text('EN'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Sign in with Google'),
      findsOneWidget,
    );
    expect(
      find.textContaining('Continue in local mode (Offline)'),
      findsOneWidget,
    );
  });

  testWidgets(
      'SettingsDrawer displays language options and switches language reactively',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('Home Content')),
            drawer: SettingsDrawer(),
          ),
        ),
      ),
    );

    final scaffoldState = tester.firstState<ScaffoldState>(find.byType(Scaffold));
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();

    // SettingsDrawer is displayed with language cards
    expect(find.text('Euskara'), findsOneWidget);
    expect(find.text('Castellano'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    expect(find.text('v1.5.1'), findsOneWidget);
    expect(find.textContaining('Euskal Herria'), findsNothing);

    // Tap Castellano in Drawer
    await tester.tap(find.text('Castellano'));
    await tester.pumpAndSettle();

    // Check that title is updated to Spanish
    expect(find.text('Idioma de la Aplicación'), findsOneWidget);

    // Tap English in Drawer
    await tester.tap(find.text('English'));
    await tester.pumpAndSettle();

    // Check that title is updated to English
    expect(find.text('App Language'), findsOneWidget);
  });

  testWidgets(
      'MapScreen displays horizontal title and single consolidated filter pill in EU, ES, and EN',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: Scaffold(
            body: MapScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Default: Basque (EU)
    expect(find.text('Perretxiko-lekuen Mapa'), findsOneWidget);
    expect(find.text('Filtroak eta Rutak'), findsOneWidget);

    // Switch to Spanish (ES)
    await container.read(appLanguageProvider.notifier).setLanguage(AppLanguage.es);
    await tester.pump();

    expect(find.text('Mapa de Setales'), findsOneWidget);
    expect(find.text('Filtros y Rutas'), findsOneWidget);

    // Switch to English (EN)
    await container.read(appLanguageProvider.notifier).setLanguage(AppLanguage.en);
    await tester.pump();

    expect(find.text('Foraging Map'), findsOneWidget);
    expect(find.text('Filters & Routes'), findsOneWidget);
  });
}
