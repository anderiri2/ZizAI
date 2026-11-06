import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:zizai/core/localization/app_localizations.dart';
import 'package:zizai/features/catalog/models/mushroom.dart';

void main() {
  group('Integridad del Catálogo Micológico de ZizAI', () {
    late List<Mushroom> catalog;

    setUpAll(() {
      final file = File('assets/data/mushrooms_catalog.json');
      expect(
        file.existsSync(),
        isTrue,
        reason: 'El archivo assets/data/mushrooms_catalog.json debe existir',
      );
      final raw = file.readAsStringSync();
      final decoded = json.decode(raw) as List<dynamic>;
      catalog = decoded
          .map((e) => Mushroom.fromJson(e as Map<String, dynamic>))
          .toList();
    });

    test('Contiene un catálogo extenso de más de 80 especies', () {
      expect(catalog.length, greaterThanOrEqualTo(80));
    });

    test('Todas las fichas tienen nombres en castellano, euskera, científico y morfología completa', () {
      final ids = <String>{};
      for (final m in catalog) {
        expect(m.id, isNotEmpty);
        expect(ids.add(m.id), isTrue, reason: 'ID duplicado: ${m.id}');
        expect(m.scientificName, isNotEmpty);
        expect(m.spanishName, isNotEmpty);
        expect(m.basqueName, isNotEmpty);
        expect(m.habitat, isNotEmpty);
        expect(m.season, isNotEmpty);
        expect(m.morphology.cap, isNotEmpty);
        expect(m.morphology.hymenium, isNotEmpty);
        expect(m.morphology.stem, isNotEmpty);
        expect(m.morphology.flesh, isNotEmpty);
        expect(m.images, isNotEmpty);

        for (final imgPath in m.images) {
          expect(
            File(imgPath).existsSync(),
            isTrue,
            reason: 'Falta archivo de imagen local $imgPath para ${m.id}',
          );
        }
      }
    });

    test('Todas las referencias cruzadas de confusiones apuntan a especies válidas del catálogo', () {
      final validIds = catalog.map((m) => m.id).toSet();
      for (final m in catalog) {
        for (final conf in m.confusions) {
          expect(
            validIds.contains(conf.mushroomId),
            isTrue,
            reason:
                'La especie ${m.id} referencia una confusión inexistente: ${conf.mushroomId}',
          );
          expect(conf.difference, isNotEmpty);
        }
      }
    });

    test('Todas las especies cuentan con traducciones morfológicas y de confusiones en Euskara e Inglés', () {
      for (final m in catalog) {
        // Morfología EU
        final morphEu = m.morphologyFor(AppLanguage.eu);
        expect(morphEu.cap, isNotEmpty, reason: '${m.id} morphologyEu.cap vacía');
        expect(morphEu.cap.toLowerCase().startsWith('txapela:'), isFalse, reason: '${m.id} tiene prefijo redundante Txapela:');
        expect(morphEu.hymenium, isNotEmpty);
        expect(morphEu.stem, isNotEmpty);
        expect(morphEu.flesh, isNotEmpty);

        // Morfología EN
        final morphEn = m.morphologyFor(AppLanguage.en);
        expect(morphEn.cap, isNotEmpty, reason: '${m.id} morphologyEn.cap vacía');
        expect(morphEn.cap.toLowerCase().startsWith('cap:'), isFalse, reason: '${m.id} tiene prefijo redundante Cap:');
        expect(morphEn.hymenium, isNotEmpty);
        expect(morphEn.stem, isNotEmpty);
        expect(morphEn.flesh, isNotEmpty);

        // Calidades y etiquetas en los 3 idiomas
        expect(m.edibilityLabelFor(AppLanguage.es), isNotEmpty);
        expect(m.edibilityLabelFor(AppLanguage.eu), isNotEmpty);
        expect(m.edibilityLabelFor(AppLanguage.en), isNotEmpty);

        // Confusiones traducidas
        for (final conf in m.confusions) {
          expect(conf.differenceFor(AppLanguage.es), isNotEmpty);
          expect(conf.differenceFor(AppLanguage.eu), isNotEmpty);
          expect(conf.differenceFor(AppLanguage.en), isNotEmpty);
        }
      }
    });
  });
}
