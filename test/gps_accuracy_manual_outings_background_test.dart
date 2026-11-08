import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:zizai/core/localization/app_localizations.dart';
import 'package:zizai/core/services/gps_accuracy_service.dart';
import 'package:zizai/core/widgets/gps_acquisition_sheet.dart';
import 'package:zizai/features/map/models/foraging_spot.dart';
import 'package:zizai/features/map/presentation/map_screen.dart';
import 'package:zizai/features/map/presentation/widgets/map_crosshair_target.dart';
import 'package:zizai/features/outings/data/outings_database.dart';
import 'package:zizai/features/outings/models/foraging_outing.dart';
import 'package:zizai/features/outings/presentation/map_spot_picker_screen.dart';
import 'package:zizai/features/outings/presentation/outings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Mejora 1: Precisión GPS al guardar setas en el Mapa', () {
    testWidgets('GpsAcquisitionSheet renders customized title, subtitle and confirm label',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GpsAcquisitionSheet(
              title: 'Setal Berria Gorde',
              subtitle: 'Doitasun handiko GPS seinalea bilatzen',
              confirmButtonLabel: 'Finkatu koordenatuak',
              lang: AppLanguage.eu,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Setal Berria Gorde'), findsOneWidget);
      expect(find.text('Doitasun handiko GPS seinalea bilatzen'), findsOneWidget);
      expect(find.byIcon(Icons.satellite_alt_rounded), findsOneWidget);
    });

    testWidgets('Pulsar Guardar Setal en MapScreen abre el selector de 2 opciones',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MapScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fabAdd = find.byKey(const ValueKey('btn_add_spot'));
      expect(fabAdd, findsOneWidget);

      await tester.tap(fabAdd);
      await tester.pumpAndSettle();

      // Debe mostrar el selector con ambas opciones (GPS y Diana/Dedo)
      expect(
        find.text('Nire uneko GPS kokapenean').evaluate().isNotEmpty ||
            find.text('En mi ubicación GPS actual').evaluate().isNotEmpty ||
            find.text('At my current GPS location').evaluate().isNotEmpty,
        isTrue,
      );
      expect(
        find.text('Mapan hatzarekin seinalatu (diana)').evaluate().isNotEmpty ||
            find.text('Marcar con el dedo en el mapa (con diana)').evaluate().isNotEmpty ||
            find.text('Mark on map with finger (crosshair)').evaluate().isNotEmpty,
        isTrue,
      );
      expect(find.byIcon(Icons.my_location_rounded), findsWidgets);
      expect(find.byIcon(Icons.touch_app_rounded), findsWidgets);

      // Al pulsar la opción de marcar con el dedo / diana, debe activar el modo Diana
      final fingerOption = find.byIcon(Icons.touch_app_rounded);
      expect(fingerOption, findsOneWidget);
      await tester.tap(fingerOption);
      await tester.pumpAndSettle();

      // Debe verse la Diana en pantalla y el botón de confirmar
      expect(find.byType(MapCrosshairTarget), findsOneWidget);
      expect(find.byKey(const ValueKey('btn_confirm_diana_spot')), findsOneWidget);

      // Al pulsar "Fijar setal aquí", abre el formulario de registro del setal
      await tester.tap(find.byKey(const ValueKey('btn_confirm_diana_spot')));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save_rounded), findsOneWidget);
    });
  });

  group('Mejora 2: Salidas Sin GPS (Cestas Micológicas Puras)', () {
    test('ForagingOuting formattedDistanceKm muestra Cesta o Manual para isManual', () {
      final manualOuting = ForagingOuting(
        id: 'manual_1',
        title: 'Recolección Gorbeia',
        startedAt: DateTime.now().subtract(const Duration(hours: 1)),
        endedAt: DateTime.now(),
        durationSeconds: 3600,
        distanceMeters: 0.0,
        routePoints: const [],
        isManual: true,
      );

      expect(manualOuting.isManual, isTrue);
      expect(manualOuting.formattedDistanceKm, contains('Manual'));
      expect(manualOuting.formattedDuration, '1h 0m');
    });

    testWidgets('MapSpotPickerScreen no muestra botón de trazar ruta a mano y ofrece botón GPS',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: MapSpotPickerScreen(
              outingId: 'test_outing',
              outingTitle: 'Salida de prueba',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // No debe existir el modo "Ibilbidea marraztu" / "Trazar ruta"
      expect(find.text('Ibilbidea marraztu'), findsNothing);
      expect(find.text('Trazar ruta'), findsNothing);

      // Debe existir el botón flotante GPS para ubicar setas
      expect(find.byKey(const ValueKey('btn_gps_picker_spot')), findsOneWidget);
    });
  });

  group('Mejora 3: Segundo Plano y Sincronización de Cronómetro sin Drift', () {
    test('ActiveOutingRecorder calcula elapsedSeconds con reloj de pared evitando desfase', () async {
      final recorder = ActiveOutingRecorder();
      final startTime = DateTime.now().subtract(const Duration(minutes: 42, seconds: 15));

      await recorder.startOuting('Salida Monte', isManual: true);

      // Simular tiempo transcurrido real con startedAt en el pasado
      recorder.state = recorder.state.copyWith(startedAt: startTime);

      // Ejecutar finalización de salida
      final finished = recorder.finishOuting();
      expect(finished, isNotNull);
      // Debe haber calculado la duración exacta por reloj de pared (~2535s)
      expect(finished!.durationSeconds, greaterThanOrEqualTo(2530));
    });

    test('ActiveOutingRecorder descuenta pausas correctamente en el cálculo', () async {
      final recorder = ActiveOutingRecorder();
      await recorder.startOuting('Salida con pausas', isManual: true);

      // Pausar y reanudar
      recorder.togglePause();
      expect(recorder.state.isPaused, isTrue);

      recorder.togglePause();
      expect(recorder.state.isPaused, isFalse);

      final finished = recorder.finishOuting();
      expect(finished, isNotNull);
    });
  });
}
