import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/autumn_theme.dart';

/// Primary language is Basque (Euskera - `eu`), followed by Spanish (`es`) and English (`en`).
enum AppLanguage {
  eu('eu', 'EU', 'Euskara'),
  es('es', 'ES', 'Castellano'),
  en('en', 'EN', 'English');

  final String code;
  final String shortLabel;
  final String nativeName;
  const AppLanguage(this.code, this.shortLabel, this.nativeName);

  static AppLanguage fromCode(String? code) {
    switch (code) {
      case 'es':
        return AppLanguage.es;
      case 'en':
        return AppLanguage.en;
      case 'eu':
      default:
        return AppLanguage.eu;
    }
  }
}

final appLanguageProvider =
    StateNotifierProvider<AppLanguageNotifier, AppLanguage>((ref) {
  return AppLanguageNotifier();
});

class AppLanguageNotifier extends StateNotifier<AppLanguage> {
  static const _prefsKey = 'perretxikotan_app_language';

  /// Defaults to Basque (`AppLanguage.eu`) as the primary language of the app.
  AppLanguageNotifier() : super(AppLanguage.eu) {
    _loadSavedLanguage();
  }

  Future<void> _loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved != null && mounted) {
      state = AppLanguage.fromCode(saved);
    }
  }

  Future<void> setLanguage(AppLanguage lang) async {
    state = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, lang.code);
  }
}

class AppStrings {
  final AppLanguage lang;
  const AppStrings(this.lang);

  String tr({
    required String eu,
    required String es,
    required String en,
  }) {
    switch (lang) {
      case AppLanguage.eu:
        return eu;
      case AppLanguage.es:
        return es;
      case AppLanguage.en:
        return en;
    }
  }

  // Splash & Auth
  String get appSubtitle => tr(
        eu: 'Mikologia · Perretxiko-lekuak · Irteerak',
        es: 'Micología · Setales · Salidas',
        en: 'Mycology · Foraging Spots · Outings',
      );

  List<String> get splashStages => [
        tr(
          eu: 'Bolba zuritik jaiotzen...',
          es: 'Naciendo de la volva blanca...',
          en: 'Emerging from the white volva...',
        ),
        tr(
          eu: 'Belardian hazten...',
          es: 'Creciendo en la campa...',
          en: 'Rising in the meadow...',
        ),
        tr(
          eu: 'Amanita caesarea (Gorringo) txapela irekitzen...',
          es: 'Amanita caesarea (Oronja) abriendo el sombrero...',
          en: 'Amanita caesarea (Caesar\'s mushroom) opening cap...',
        ),
      ];

  String get loginTagline => tr(
        eu: 'Mikologia gida eta zure perretxiko-leku sekretuen mapa pribatua',
        es: 'Guía micológica y mapa privado de tus setales secretos',
        en: 'Mycological guide & private map of your secret mushroom spots',
      );

  String get loginFeatureCatalogTitle => tr(
        eu: 'Katalogoa Offline (126 espezie)',
        es: 'Catálogo Offline (126 especies)',
        en: 'Offline Catalog (126 species)',
      );

  String get loginFeatureCatalogSub => tr(
        eu: 'Euskara (A-Z), izen zientifikoa eta jangarritasuna estaldurarik gabe.',
        es: 'Nombres en euskera, castellano e inglés sin necesidad de cobertura.',
        en: 'Basque, Spanish, and English names & field guide with zero cell coverage.',
      );

  String get loginFeatureMapTitle => tr(
        eu: 'Perretxiko-lekuak, GPS Ibilbideak eta Offline Mapak',
        es: 'Setales, Rutas GPS y Mapas Offline',
        en: 'Foraging Spots, GPS Routes & Offline Maps',
      );

  String get loginFeatureMapSub => tr(
        eu: 'Gorde zure lekuak, grabatu irteerak eta deskargatu mendiko mapak.',
        es: 'Guarda tus puntos, graba salidas y descarga mapas de monte.',
        en: 'Save private spots, record GPS outings, and download forest maps.',
      );

  String get loginFeatureDriveTitle => tr(
        eu: 'Google Drive Babeskopia eta Gemini IA',
        es: 'Backup en Google Drive e IA Gemini',
        en: 'Google Drive Backup & Gemini AI',
      );

  String get loginFeatureDriveSub => tr(
        eu: 'Jarduera osoaren ZIP babeskopia pribatua eta argazki bidezko identifikazioa.',
        es: 'Copia ZIP privada de toda tu actividad e identificación por foto.',
        en: 'Private full-activity ZIP backup and photo mushroom identification.',
      );

  String get signInWithGoogle => tr(
        eu: 'Hasi saioa Google-rekin (Hodeiko Babeskopia)',
        es: 'Iniciar sesión con Google (Backup Cloud)',
        en: 'Sign in with Google (Cloud Backup)',
      );

  String get continueOfflineMode => tr(
        eu: 'Jarraitu tokiko moduan (Offline)',
        es: 'Continuar en modo local (Offline)',
        en: 'Continue in local mode (Offline)',
      );

  // Privacy & Data Ownership
  String get loginPrivacyBadge => tr(
        eu: 'Datuak zureak dira · %100 Pribatua',
        es: 'Tus datos te pertenecen · 100% Privado',
        en: 'Your data belongs to you · 100% Private',
      );

  String get loginPrivacySubtitle => tr(
        eu: 'Aplikazioak ez ditu zure datuak inorekin partekatzen. Zuk aukeratzen duzu non gorde: gailu honetan bakarrik edo zure Google Drive pertsonalean.',
        es: 'No compartimos tus datos con nadie. Tú decides dónde guardarlos: solo en este teléfono o en tu cuenta personal de Google Drive.',
        en: 'We never share your data with anyone. You decide where to store it: solely on this device or in your personal Google Drive.',
      );

  String get loginPrivacyBullet => tr(
        eu: 'Kanpoko zerbitzaririk gabe · Jarraipenik gabe · Zure perretxiko-leku sekretuak salbu',
        es: 'Sin servidores externos · Sin rastreo · Tus setales secretos a salvo',
        en: 'No external servers · No tracking · Your secret foraging spots are safe',
      );

  String get privacyDrawerSectionTitle => tr(
        eu: 'Pribatutasuna eta Zure Datuak',
        es: 'Privacidad y Tus Datos',
        en: 'Privacy & Your Data',
      );

  String get privacyGuaranteeTitle => tr(
        eu: 'Zure perretxiko-lekuak sekretuak dira',
        es: 'Tus setales son 100% secretos',
        en: 'Your spots are 100% secret',
      );

  String get privacyGuaranteeDescription => tr(
        eu: 'Perretxikotan-ek ez du zure kokapenik, ibilbiderik edo argazkirik inorekin partekatzen. Zure telefonoan edo zure Google Drive pribatuan bakarrik gordetzen dira, zuk nahi duzun bezala.',
        es: 'Perretxikotan no comparte tus ubicaciones, rutas o fotos con nadie. Se guardan únicamente en tu móvil o en tu propio Google Drive, como tú elijas.',
        en: 'Perretxikotan never shares your spots, routes, or photos with anyone. Stored solely on your device or in your personal Google Drive, as you choose.',
      );

  String get privacyBadgeLocal => tr(
        eu: '📱 Tokiko Modua',
        es: '📱 100% Local',
        en: '📱 100% Local',
      );

  String get privacyBadgeDrive => tr(
        eu: '☁️ Zure Google Drive-a',
        es: '☁️ Tu Google Drive',
        en: '☁️ Your Google Drive',
      );

  String get privacyBadgeNoServers => tr(
        eu: '🚫 Zerbitzari gabe',
        es: '🚫 Cero servidores ajenos',
        en: '🚫 Zero third-party servers',
      );

  String get privacyLearnMore => tr(
        eu: 'Nola babesten ditugu zure datuak?',
        es: '¿Cómo protegemos tus datos?',
        en: 'How do we protect your data?',
      );

  String get privacyDialogTitle => tr(
        eu: 'Datuen Pribatutasuna eta Jabetza',
        es: 'Privacidad y Propiedad de tus Datos',
        en: 'Privacy & Data Ownership',
      );

  String get privacyDialogBody => tr(
        eu: '• Zerbitzari propiorik ez: Perretxikotan-ek ez du datu-base zentralik ezta kanpoko zerbitzaririk. Inork ez du zure lekuen berririk.\n\n• Tokiko biltegiratzea: Zure aurkikuntza, ohar, ibilbide eta argazkiak telefonoaren barne memorian gordetzen dira segurtasun osoz.\n\n• Google Drive pertsonala (hautazkoa): Hodeiko kopia aktibatzen baduzu, zure Google kontuko eremu pribatu eta ezkutuan (appDataFolder) bakarrik gordetzen da. Zuk bakarrik duzu sarbidea.',
        es: '• Sin servidores centrales: Perretxikotan no dispone de bases de datos externas ni servidores donde recopilar tus ubicaciones. Nadie más tiene acceso a tus sitios secretos.\n\n• Almacenamiento local: Todos tus puntos, notas, rutas y fotos se guardan de forma segura en la memoria interna de tu móvil.\n\n• Google Drive personal (opcional): Si activas el respaldo en la nube, se almacena únicamente en la carpeta privada y oculta de tu propia cuenta de Google (appDataFolder). Es 100% tuyo y privado.',
        en: '• No central servers: Perretxikotan has no external database or server to collect your spots. Nobody else can ever see your secret locations.\n\n• Local storage: All your spots, notes, routes, and photos are securely stored in your phone\'s internal memory.\n\n• Personal Google Drive (optional): If you enable cloud backup, it is saved solely in the private hidden folder of your own Google account (appDataFolder). It remains 100% yours and private.',
      );

  String get spotFormPrivacyNotice => tr(
        eu: '%100 Pribatua: Zure gailuan bakarrik gordetzen da',
        es: '100% Privado: Solo se guarda en tu dispositivo',
        en: '100% Private: Saved on your device only',
      );

  // Bottom Navigation Bar (5 tabs)
  String get navMushrooms => tr(eu: 'Perretxikoak', es: 'Setas', en: 'Mushrooms');
  String get navMap => tr(eu: 'Mapa', es: 'Mapa', en: 'Map');
  String get navOutings => tr(eu: 'Irteerak', es: 'Salidas', en: 'Outings');
  String get navAiPhoto => tr(eu: 'IA Argazkia', es: 'IA Foto', en: 'AI Photo');
  String get navBackup => tr(eu: 'Babeskopia', es: 'Backup', en: 'Backup');

  // Safety Disclaimer Banner
  String get safetyDisclaimerShort => tr(
        eu: 'Kontuz: Gida informatiboa da. Ez jan inoiz %100ean ziur ez zauden perretxikorik.',
        es: 'Aviso: Guía orientativa. Nunca consumas una seta sin 100% de certeza experta.',
        en: 'Warning: Field guide only. Never consume a mushroom without 100% expert certainty.',
      );

  String get safetyDialogTitle => tr(
        eu: 'Segurtasun Mikologikoko Oharra',
        es: 'Aviso de Seguridad Micológica',
        en: 'Mycological Safety Disclaimer',
      );

  String get safetyDialogBody => tr(
        eu: 'Perretxikotan informazio-aplikazio bat da. Argazki bidezko IA identifikazioak eta katalogoak ez dute inoiz aditu mikologiko baten azterketa fisikoa ordezkatzen. Zalantzarik izanez gero, ez bildu eta ez jan alea.',
        es: 'Perretxikotan es una herramienta de apoyo divulgativo. La identificación por IA o catálogo nunca sustituye la revisión presencial de un micólogo experto o sociedad micológica. Ante la menor duda, descarta el ejemplar.',
        en: 'Perretxikotan is an informational field tool. AI photo analysis and catalog entries never replace physical inspection by a certified mycologist. When in doubt, never consume any specimen.',
      );

  String get understood => tr(eu: 'Ulertuta', es: 'Entendido', en: 'Understood');

  // Catalog Screen
  String get catalogHeaderSubtitle => tr(
        eu: 'Mendiko Gida Mikologikoa',
        es: 'Guía Micológica de Campo',
        en: 'Mycological Field Guide',
      );

  String get searchHint => tr(
        eu: 'Bilatu latinez (Boletus, Amanita...), euskaraz edo gaztelaniaz...',
        es: 'Buscar por nombre científico (Boletus, Amanita...), castellano o euskera...',
        en: 'Search by scientific name (Boletus, Amanita...), Basque or Spanish...',
      );

  String get filterAll => tr(eu: 'Guztiak', es: 'Todas', en: 'All');
  String get filterExcellent =>
      tr(eu: 'Bikainak', es: 'Excelentes', en: 'Choice Edible');
  String get filterEdible =>
      tr(eu: 'Jangarriak', es: 'Comestibles', en: 'Edible');
  String get filterToxic =>
      tr(eu: 'Toxikoak eta hilgarriak', es: 'Tóxicas y mortales', en: 'Toxic & deadly');

  String get sortLabel => tr(eu: 'Ordena:', es: 'Orden:', en: 'Sort:');
}

/// Compact trilingual selector pill (`EU | ES | EN`) for headers and login screen.
class LanguageSelectorPill extends ConsumerWidget {
  final bool darkSurface;

  const LanguageSelectorPill({
    super.key,
    this.darkSurface = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(appLanguageProvider);
    final bgColor = darkSurface
        ? Colors.black.withValues(alpha: 0.28)
        : AutumnColors.barkDark.withValues(alpha: 0.08);
    final borderColor = darkSurface
        ? AutumnColors.amberLeaf.withValues(alpha: 0.55)
        : AutumnColors.boletusBrown.withValues(alpha: 0.25);

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((lang) {
          final isSelected = lang == current;
          return GestureDetector(
            onTap: () {
              ref.read(appLanguageProvider.notifier).setLanguage(lang);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isSelected ? AutumnColors.amberLeaf : Colors.transparent,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                lang.shortLabel,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: isSelected
                      ? Colors.white
                      : (darkSurface
                          ? AutumnColors.parchmentBg
                          : AutumnColors.barkDark),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
