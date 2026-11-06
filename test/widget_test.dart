import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zizai/core/localization/app_localizations.dart';
import 'package:zizai/core/widgets/settings_drawer.dart';
import 'package:zizai/core/widgets/translucent_bottom_nav.dart';
import 'package:zizai/features/map/data/spots_database.dart';
import 'package:zizai/features/map/models/foraging_spot.dart';
import 'package:zizai/features/map/presentation/map_screen.dart';
import 'package:zizai/features/outings/data/outings_database.dart';
import 'package:zizai/features/outings/models/foraging_outing.dart';
import 'package:zizai/features/outings/presentation/live_outing_map_screen.dart';
import 'package:zizai/features/outings/presentation/outings_screen.dart';
import 'package:zizai/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.localeTestValue = const Locale('eu');
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.localesTestValue = const [Locale('eu')];
  });

  tearDown(() {
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.clearLocaleTestValue();
    TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.clearLocalesTestValue();
  });

  testWidgets(
      'ZizAiApp renders Amanita caesarea SplashScreen and transitions to LoginScreen in Basque (EU) when system is EU, and switches to ES and EN',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'zizai_safety_accepted': true,
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: ZizAiApp(),
      ),
    );

    expect(find.text('ZizAI'), findsOneWidget);

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
    expect(find.text('v1.5.1'), findsNothing);
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
    expect(find.text('Filtroak eta Ibilbideak'), findsOneWidget);

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

  testWidgets(
      'OutingsScreen opens LiveOutingMapScreen without MapController conflict and renders map thumbnails',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    await container
        .read(activeOutingRecorderProvider.notifier)
        .startOuting('Ruta de prueba', isManual: true);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: OutingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify the active outing recorder card is visible and history cards render FlutterMap thumbnails
    expect(find.textContaining('Ruta de prueba'), findsOneWidget);
    expect(find.byType(FlutterMap), findsWidgets);

    // Tap the top-right expand button ('Handitu') to open LiveOutingMapScreen
    await tester.tap(find.text('Handitu'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    // Verify no ErrorWidget (red screen) and LiveOutingMapScreen is mounted
    expect(find.byType(ErrorWidget), findsNothing);
    expect(find.byType(LiveOutingMapScreen), findsOneWidget);

    // Stop the active outing timer before test teardown
    container.read(activeOutingRecorderProvider.notifier).cancelOuting();
    await tester.pump();
  });

  testWidgets(
      'Bottom navigation bar hides AI tab and OutingsScreen centers no-route thumbnail on largest collection',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});

    final container = ProviderContainer();
    addTearDown(container.dispose);

    // 1. Verify bottom nav has 4 tabs and no AI tab
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          home: Scaffold(
            bottomNavigationBar: TranslucentBottomNavBar(
              currentIndex: 0,
              onTabSelected: (_) {},
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Perretxikoak'), findsOneWidget);
    expect(find.text('Mapa'), findsOneWidget);
    expect(find.text('Irteerak'), findsOneWidget);
    expect(find.text('Babeskopia'), findsOneWidget);
    expect(find.text('IA Argazkia'), findsNothing);

    // 2. Create a manual outing without route points and two mushroom collections (2x vs 12x)
    final noRouteOuting = ForagingOuting(
      id: 'outing_no_route_test',
      title: 'Salida sin ruta',
      startedAt: DateTime(2026, 10, 29, 9, 0),
      endedAt: DateTime(2026, 10, 29, 11, 0),
      durationSeconds: 7200,
      distanceMeters: 0,
      routePoints: const [],
      notes: '',
      isManual: true,
    );
    await container.read(outingsProvider.notifier).saveOuting(noRouteOuting);

    await container.read(foragingSpotsProvider.notifier).saveSpot(
          ForagingSpot(
            id: 'spot_small',
            title: 'Pequeño',
            latitude: 42.9000,
            longitude: -2.5000,
            notes: '',
            foundAt: DateTime(2026, 10, 29, 9, 30),
            outingId: 'outing_no_route_test',
            quantityCount: 2,
          ),
        );
    await container.read(foragingSpotsProvider.notifier).saveSpot(
          ForagingSpot(
            id: 'spot_largest',
            title: 'Recolección grande',
            latitude: 43.1234,
            longitude: -2.3456,
            notes: '',
            foundAt: DateTime(2026, 10, 29, 10, 0),
            outingId: 'outing_no_route_test',
            quantityCount: 12,
            weightGrams: 850,
          ),
        );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          home: OutingsScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Verify the largest collection badge '12' is rendered inside the no-route thumbnail
    expect(find.text('12'), findsOneWidget);
  });

  group('AppLanguage System Locale & Fallback Tests', () {
    test('fromLocale correctly maps locales and falls back to en for unsupported languages', () {
      expect(AppLanguage.fromLocale(const Locale('eu')), AppLanguage.eu);
      expect(AppLanguage.fromLocale(const Locale('eu', 'ES')), AppLanguage.eu);
      expect(AppLanguage.fromLocale(const Locale('es')), AppLanguage.es);
      expect(AppLanguage.fromLocale(const Locale('es', 'ES')), AppLanguage.es);
      expect(AppLanguage.fromLocale(const Locale('en')), AppLanguage.en);
      expect(AppLanguage.fromLocale(const Locale('en', 'US')), AppLanguage.en);

      // Unsupported languages must fallback to English
      expect(AppLanguage.fromLocale(const Locale('fr', 'FR')), AppLanguage.en);
      expect(AppLanguage.fromLocale(const Locale('de', 'DE')), AppLanguage.en);
      expect(AppLanguage.fromLocale(const Locale('ja', 'JP')), AppLanguage.en);
      expect(AppLanguage.fromLocale(null), AppLanguage.en);
    });

    testWidgets('systemDefault detects system locale and falls back to en when unsupported', (tester) async {
      // 1. French -> English fallback
      tester.platformDispatcher.localeTestValue = const Locale('fr', 'FR');
      tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];
      expect(AppLanguage.systemDefault, AppLanguage.en);
      expect(AppLanguage.fromCode(null), AppLanguage.en);
      expect(AppLanguage.fromCode('fr'), AppLanguage.en);

      // 2. Spanish
      tester.platformDispatcher.localeTestValue = const Locale('es', 'ES');
      tester.platformDispatcher.localesTestValue = const [Locale('es', 'ES')];
      expect(AppLanguage.systemDefault, AppLanguage.es);
      expect(AppLanguage.fromCode(null), AppLanguage.es);

      // 3. Basque
      tester.platformDispatcher.localeTestValue = const Locale('eu', 'ES');
      tester.platformDispatcher.localesTestValue = const [Locale('eu', 'ES')];
      expect(AppLanguage.systemDefault, AppLanguage.eu);
      expect(AppLanguage.fromCode(null), AppLanguage.eu);

      // 4. English
      tester.platformDispatcher.localeTestValue = const Locale('en', 'US');
      tester.platformDispatcher.localesTestValue = const [Locale('en', 'US')];
      expect(AppLanguage.systemDefault, AppLanguage.en);
      expect(AppLanguage.fromCode(null), AppLanguage.en);
    });

    testWidgets('respects saved user choice in SharedPreferences over system locale', (tester) async {
      // System is French, but user previously selected Spanish in app settings
      tester.platformDispatcher.localeTestValue = const Locale('fr', 'FR');
      tester.platformDispatcher.localesTestValue = const [Locale('fr', 'FR')];

      SharedPreferences.setMockInitialValues(<String, Object>{
        'zizai_app_language': 'es',
      });

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Trigger provider initialization
      container.read(appLanguageProvider);
      // Wait for async _loadSavedLanguage
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(appLanguageProvider), AppLanguage.es);
    });
  });
}
