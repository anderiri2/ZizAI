/**
 * ZizAI — Web Oficial de Presentación
 * Motor de Traducción Trilingüe (EU / ES / EN), Showcase Interactivo y GitHub Releases API
 */

const I18N = {
  eu: {
    metaTitle: "ZizAI — Mikologia Gida, Setalen Mapa Pribatua eta GPS Ibilbideak",
    navWhy: "Zergatik ZizAI?",
    navAdvantages: "Abantailak",
    navScreens: "Pantailak",
    navPrivacy: "Pribatutasuna",
    navDownload: "Deskargatu",

    // Hero
    heroBadge: "100% Standalone & Kode Irekia",
    heroTitle: "Zure <span class='highlight'>perretxiko-leku sekretuen</span> mapa pribatua eta mendiko gida",
    heroSubtitle: "Aplikazio micológico librea, %100 offline funtzionatzen duena basoan estaldurarik gabe. Zure setalak ez dira inoiz inongo zerbitzari zentraletara bidaltzen: zure telefonoan edo zure Google Drive pribatuan bakarrik gordetzen dira.",
    heroPill1: "📖 126 espezie eta 221 argazki erreal",
    heroPill2: "🗺️ Topo, Satelitea eta Offline Mapak",
    heroPill3: "🔒 %100 Pribatua · Zerbitzari gabe",
    heroPill4: "⚡ Salida Arinak (0% bateria xahutzea)",
    heroCtaDownload: "Deskargatu APK (Doan)",
    heroCtaGithub: "GitHub Kode Irekia",

    // Objetivo
    sectionObjectiveTag: "MISIOA ETA FILOSOFIA",
    sectionObjectiveTitle: "Zergatik sortu da ZizAI?",
    sectionObjectiveDesc: "Setazale gehienek arazo berak pairatzen dituzte: baso itxian ez dago estaldurarik, aplikazio arruntek zure datuak hodeira igotzen dituzte, eta GPSak bateria oso azkar agortzen du. ZizAI arazo horiek guztiak konpontzeko jaio da.",
    obj1Title: "Katalogo Micológico 100% Offline",
    obj1Text: "Basoan zaudenean estaldura galtzea ohikoa da. ZizAI-ren 126 espezieak, 221 argazki errealak, morfologia osoa eta nahasmen arriskutsuak zure telefonoan bertan daude, zerbitzarien menpe egon gabe.",
    obj2Title: "Zure Setalak 100% Sekretuak",
    obj2Text: "Perretxikozale orok daki lekurik onenak sekretuak direla. ZizAI-k ez du zerbitzari zentralik: zure koordenatuak, ibilbideak eta argazkiak zure telefonoan edo zure Google Drive pribatuan soilik gordetzen dira.",
    obj3Title: "Arkitektura Librea eta Segurua",
    obj3Text: "Iragarkirik gabe, harpidetza ezkuturik gabe eta jarraipenik gabe. Zuk erabakitzen duzu zure datuekin zer egin, babeskopia ZIP formatuan deskargatuz edo Smart Merge bidez sinkronizatuz.",

    // Ventajas
    sectionAdvTag: "KONPARAKETA",
    sectionAdvTitle: "Zerk egiten du ZizAI bakarra?",
    sectionAdvDesc: "Merkatuko beste aplikazioekin alderatuta, ZizAI eremu menditsuko errealitaterako eta erabiltzailearen pribatutasun absoluturako diseinatuta dago.",
    thFeature: "Ezaugarria",
    thZizai: "ZizAI (Kode Irekia)",
    thOthers: "Beste Aplikazio Batzuk",
    f1Title: "Pribatutasun Absolutua (Zero Zerbitzari)",
    f1Desc: "Koordenatu micológiak inorekin ez partekatzea",
    f1Zizai: "100% Tokikoa / Google Drive pertsonala",
    f1Others: "Zerbitzari komertzialetan gordeta",
    f2Title: "Konexiorik Gabe (0% Estaldura)",
    f2Desc: "Katalogo osoa, argazkiak eta mapak mendian",
    f2Zizai: "126 espezie + Offline Topo/Satelitea",
    f2Others: "Konexioa behar dute datuak kargatzeko",
    f3Title: "Hizkuntza Hirukoitza eta Zientifikoa",
    f3Desc: "Euskara, Gaztelania, Ingelesa eta Latina",
    f3Zizai: "A-Z ordena hizkuntzaren arabera",
    f3Others: "Itzulpen automatiko mugatuak",
    f4Title: "Salida Arina Bateria Aurrezteko",
    f4Desc: "Irteera erregistratzea GPS satelitalik gabe",
    f4Zizai: "Eskuzko Modua (%0 bateria xahutzea)",
    f4Others: "GPS jarraipen derrigortua",
    f5Title: "Kostua eta Publizitatea",
    f5Desc: "Kode irekia eta gardentasuna",
    f5Zizai: "Doakoa, iragarkirik eta mugarik gabe",
    f5Others: "Ordainpeko harpidetzak eta iragarkiak",

    // Pantallas
    sectionScreensTag: "IBILBIDE BISUALA",
    sectionScreensTitle: "Aplikazioaren 4 Pantaila Nagusiak",
    sectionScreensDesc: "Ezagutu beheko nabigazio-barra zeharrargiaren 4 moduak eta bakoitzak zure mendiko jardueran duen helburua.",
    tabCatalog: "Perretxikoak",
    tabMap: "Mapa",
    tabOutings: "Irteerak",
    tabBackup: "Babeskopia",

    screenCatalogTitle: "1. Perretxikoak (Katalogo Micológico Offline)",
    screenCatalogBadge: "126 ESPEZIE · 221 ARGAZKI ERREAL",
    screenCatalogMission: "Mendiko gida osoa, basoan inolako estaldurarik gabe espezieak azkar kontsultatzeko, identifikatzeko eta jangarritasun-maila egiaztatzeko prestatua.",
    screenCatalogF1: "Ordenazio alfabtikoa hautagarria: Euskara (A-Z), Izen Zientifikoa, Gaztelania edo Ingelesa.",
    screenCatalogF2: "Iragazki azkarrak: Bikainak, Jangarriak, Kontuz, Toxikoak eta hilgarriak, Udazkena, Udaberria eta Gogokoak.",
    screenCatalogF3: "Morfologia 4 ataletan (Txapela, Himenioa, Hanka, Haragia) eta espezie antzekoen arteko Nahasmen Arriskutsuen abisuak.",

    screenMapTitle: "2. Mapa (Perretxiko-lekuen Mapa Interaktiboa)",
    screenMapBadge: "TOPO · SATELITEA · OFFLINE ESKUALDEAK",
    screenMapMission: "Zure aurkikuntzak mapan zehaztasun osoz kokatzea eta bistaratzea, basoko orografia eta bidezidorrak ulertuz.",
    screenMapF1: "3 geruza kartografiko: Topografikoa (curvas de nivel), Esri Satelite Ortofotografikoa eta Estándarra.",
    screenMapF2: "Offline Mapen deskargatzailea: gorde zure eskualdea mendira igo aurretik (Gorbeia, Urbasa, Irati, Aralar, Urkiola, Izki).",
    screenMapF3: "Puntuak jangarritasun-kolorez bereizita eta GPS ibilbideak gainjarrita ikusteko aukera.",

    screenOutingsTitle: "3. Irteerak (GPS Ibilbideak eta Saskiaren Laburpena)",
    screenOutingsBadge: "ZUZENEKO GPSA EDO ESKUZKO MODUA (%0 BATERIA)",
    screenOutingsMission: "Mendira egindako irteerak erregistratzea: ibilitako bidea, iraupena, kilometroak eta bildutako perretxikoen kopurua eta pisua (gramotan).",
    screenOutingsF1: "Zuzeneko GPS grabagailua radar-zehaztasun neurgailuarekin (< 15 m) eta teletransportazio-iragazkiarekin.",
    screenOutingsF2: "Eskuzko Modua (%0 bateria): gorde aurkikuntzak GPS sentsorea piztu gabe mugikorraren karga zaintzeko.",
    screenOutingsF3: "Historialaren txartelak: ibilbidearen mini-mapa topografiko errealarekin eta saskiaren banaketa espezieka.",

    screenBackupTitle: "4. Babeskopia (Google Drive eta ZIP Tokikoa)",
    screenBackupBadge: "SMART MERGE · %100 PRIBATUA",
    screenBackupMission: "Zure datu guztien segurtasuna bermatzea. Aldatu telefonoz edo galdu gailua, zure setalak sekula ez dira galduko.",
    screenBackupF1: "Google Drive pertsonala: kopia enkriptatua zure kontuko carpeta ezkutuan (appDataFolder) gordetzen da.",
    screenBackupF2: "Smart Merge (Fuzio Adimenduna): hodeiko datuak eta gailukoak batzen ditu ID bidez, ezer gainidatzi gabe.",
    screenBackupF3: "Berehalako Instantánea ZIP: esportatu eta inportatu fitxategi bakar batean argazki eta ibilbide guztiak.",

    // Privacidad
    privacyTitle: "Zure datuak zureak dira. %100 Pribatua.",
    privacyDesc: "ZizAI ez da enpresa baten zerbitzari batera konektatzen. Zure kokapenak, oharrak eta argazkiak zureak bakarrik dira.",
    privacyB1: "🚫 Cero zerbitzari zentral eta zero telemetria.",
    privacyB2: "📱 Tokiko biltegiratze segurua SQLite bidez.",
    privacyB3: "☁️ Zure Google Drive pribatuan bakarrik (appDataFolder).",
    privacyPill1: "📱 Tokiko Modua",
    privacyPill2: "☁️ Zure Google Drive",
    privacyPill3: "🚫 Jarraipenik Gabe",

    // Descarga
    downloadTitle: "Deskargatu ZizAI Doan",
    downloadDesc: "Instalatu azken bertsioa zure Android gailuan eta gozatu mendiaz segurtasun eta pribatutasun osoz.",
    downloadVersionLabel: "Azken bertsioa:",
    downloadBtnApk: "Deskargatu APK Zuzenean",
    downloadBtnReleases: "Releases Ikusi GitHub-en",
    downloadRequirements: "Baldintzak: Android 7.0+ (Nougat) edo berriagoa · iOS 14.0+ (iturburu-kodetik eraikitzeko).",

    safetyDisclaimerTitle: "Segurtasun Mikologikoko Oharra",
    safetyDisclaimerText: "ZizAI informazio eta laguntza tresna bat da. Aplikazioko datuek ez dute inoiz aditu mikologiko baten azterketa fisikoa ordezkatzen. Zalantzarik izanez gero, ez bildu eta ez kontsumitu inoiz perretxikorik.",

    footerLicense: "Kode Irekia MIT Lizentziapean · Garatzailea: Ander Iriondo",
    footerSource: "GitHub Repositorioa",
    footerReleases: "Bertsio Oharrak (Releases)",
    footerSafety: "Segurtasuna"
  },

  es: {
    metaTitle: "ZizAI — Guía Micológica, Mapa Privado de Setales y Rutas GPS",
    navWhy: "¿Por qué ZizAI?",
    navAdvantages: "Ventajas",
    navScreens: "Pantallas",
    navPrivacy: "Privacidad",
    navDownload: "Descargar",

    // Hero
    heroBadge: "100% Standalone & Código Abierto",
    heroTitle: "Tu mapa privado de <span class='highlight'>setales secretos</span> y guía micológica",
    heroSubtitle: "La aplicación micológica libre que funciona al 100% en el monte sin cobertura. Tus puntos y rutas GPS jamás se envían a servidores ajenos: solo se guardan en tu móvil o en tu propio Google Drive privado.",
    heroPill1: "📖 126 especies y 221 fotos reales",
    heroPill2: "🗺️ Topo, Satélite y Mapas Offline",
    heroPill3: "🔒 100% Privado · Sin Servidores",
    heroPill4: "⚡ Salidas Ligeras (0% gasto de batería)",
    heroCtaDownload: "Descargar APK (Gratis)",
    heroCtaGithub: "Código en GitHub",

    // Objetivo
    sectionObjectiveTag: "MISIÓN Y FILOSOFÍA",
    sectionObjectiveTitle: "¿Por qué nace ZizAI?",
    sectionObjectiveDesc: "Cualquier aficionado a las setas conoce los tres grandes problemas de las apps comerciales: en el bosque profundo no hay cobertura, las aplicaciones suben tus coordenadas a sus bases de datos, y el GPS consume la batería en pocas horas. ZizAI nació para resolverlos.",
    obj1Title: "Catálogo Micológico 100% Offline",
    obj1Text: "En el hayedo o pinar no hay señal 4G/5G. ZizAI integra 126 fichas botánicas completas, 221 fotos reales, morfología en 4 bloques y alertas de confusiones directamente en la memoria del teléfono.",
    obj2Title: "Tus Setales son 100% Secretos",
    obj2Text: "El secreto mejor guardado de un recolector son sus setales. ZizAI tiene arquitectura serverless: no tenemos bases de datos centrales donde recopilar tus coordenadas. Tus datos te pertenecen solo a ti.",
    obj3Title: "Herramienta Libre, Limpia y Honesta",
    obj3Text: "Sin muros de pago, sin suscripciones mensuales y sin publicidad invasiva. Con libertad absoluta para exportar tus rutas y fotos en un archivo ZIP local o sincronizarlas con Fusión Inteligente en tu Google Drive.",

    // Ventajas
    sectionAdvTag: "COMPARATIVA",
    sectionAdvTitle: "¿En qué se diferencia del resto?",
    sectionAdvDesc: "Diseñada por y para recolectores de campo, combinando rigor botánico con el respeto sagrado a la privacidad del setero.",
    thFeature: "Funcionalidad",
    thZizai: "ZizAI (Open Source)",
    thOthers: "Otras Apps Comerciales",
    f1Title: "Privacidad de tus Setales",
    f1Desc: "Coordenadas GPS y fotos de tus zonas",
    f1Zizai: "100% Local / Google Drive privado",
    f1Others: "Subidas a servidores de la empresa",
    f2Title: "Uso 100% Offline sin Cobertura",
    f2Desc: "Catálogo, fotografías y cartografía",
    f2Zizai: "126 especies + Topo/Satélite Offline",
    f2Others: "Requieren conexión para cargar datos",
    f3Title: "Trilingüe Nativo y Taxonomía",
    f3Desc: "Castellano, Euskera, Inglés y Latín",
    f3Zizai: "Orden A-Z por idioma y búsqueda dual",
    f3Others: "Traducciones automáticas deficientes",
    f4Title: "Salida Manual sin Gasto de Batería",
    f4Desc: "Registrar hallazgos sin activar el chip satelital",
    f4Zizai: "Modo Manual (0% drenaje de batería)",
    f4Others: "Obligan a mantener el GPS encendido",
    f5Title: "Modelo y Transparencia",
    f5Desc: "Coste, licencias y anuncios",
    f5Zizai: "100% Gratis, Libre y Sin Anuncios",
    f5Others: "Suscripciones anuales de 20-40€",

    // Pantallas
    sectionScreensTag: "RECORRIDO VISUAL",
    sectionScreensTitle: "Las 4 Pantallas Principales",
    sectionScreensDesc: "Recorre las 4 modalidades de la barra inferior translúcida de ZizAI y la misión de cada una de ellas.",
    tabCatalog: "Setas",
    tabMap: "Mapa",
    tabOutings: "Salidas",
    tabBackup: "Backup",

    screenCatalogTitle: "1. Setas (Catálogo Micológico de Campo)",
    screenCatalogBadge: "126 ESPECIES · 221 FOTOS REALES",
    screenCatalogMission: "Guía de campo completa e instantánea para consultar especies, revisar claves morfológicas y verificar la comestibilidad en mitad del bosque.",
    screenCatalogF1: "Ordenación alfabética intercambiable en tiempo real: Castellano (A-Z), Euskera, Científico o Inglés.",
    screenCatalogF2: "Filtros rápidos por comestibilidad (Excelentes, Comestibles, Precaución, Tóxicas/Mortales) y temporadas (Otoño, Primavera).",
    screenCatalogF3: "Morfología botánica detallada en 4 bloques (Sombrero, Himenio, Pie, Carne) y comparativa de confusiones frecuentes.",

    screenMapTitle: "2. Mapa (Cuaderno Cartográfico de Setales)",
    screenMapBadge: "TOPO · SATÉLITE · REGIONES OFFLINE",
    screenMapMission: "Ubicar con precisión tus hallazgos sobre curvas de nivel o fotografía satelital, visualizando los accesos y masas arbóreas.",
    screenMapF1: "3 capas cartográficas: Topográfica con curvas de nivel, Esri Satélite de alta resolución y capa Estándar.",
    screenMapF2: "Gestor de Mapas Offline para descargar zonas antes de subir al monte (Gorbeia, Urbasa, Irati, Aralar, Urkiola, Izki).",
    screenMapF3: "Marcadores con color de comestibilidad y superposición simultánea de las rutas GPS de tus salidas.",

    screenOutingsTitle: "3. Salidas (Grabadora GPS e Historial)",
    screenOutingsBadge: "GPS EN VIVO O SALIDA MANUAL (0% BATERÍA)",
    screenOutingsMission: "Registrar tus jornadas de recolección: recorrido exacto, distancia, duración y desglose exhaustivo de la cesta con peso en gramos.",
    screenOutingsF1: "Grabadora GPS con radar de precisión (< 15 m) y filtro activo contra saltos erráticos bajo bosque espeso.",
    screenOutingsF2: "Modo Salida Manual (0% gasto de batería): apunta setas y ubicaciones sin necesidad de agotar la batería del teléfono.",
    screenOutingsF3: "Tarjetas de historial con mini-mapa topográfico real y resumen de la cesta agrupado por especie.",

    screenBackupTitle: "4. Backup (Google Drive y Snapshots ZIP)",
    screenBackupBadge: "SMART MERGE · 100% PRIVADO",
    screenBackupMission: "Garantizar que tus setales secretos te acompañen para siempre, incluso si cambias o renuevas de teléfono móvil.",
    screenBackupF1: "Copia en tu propio Google Drive: almacenada en la carpeta privada y oculta (appDataFolder) a la que solo tú tienes acceso.",
    screenBackupF2: "Fusión Inteligente (Smart Merge): combina tus salidas de la nube con las locales sin sobreescribir ni perder nada.",
    screenBackupF3: "Instantáneas ZIP locales: exporta un archivo .zip completo con todas tus fotos y bases de datos para guardarlo en tu PC.",

    // Privacidad
    privacyTitle: "Tus datos te pertenecen. 100% Privado.",
    privacyDesc: "ZizAI no tiene servidores centrales ni telemetría comercial. Tus setales son tu patrimonio personal y secreto.",
    privacyB1: "🚫 Cero servidores externos y cero rastreo publicitario.",
    privacyB2: "📱 Almacenamiento local seguro en base de datos SQLite.",
    privacyB3: "☁️ Solo en la carpeta oculta de tu propio Google Drive (appDataFolder).",
    privacyPill1: "📱 100% Local",
    privacyPill2: "☁️ Tu Google Drive",
    privacyPill3: "🚫 Cero Servidores",

    // Descarga
    downloadTitle: "Descarga ZizAI Gratis",
    downloadDesc: "Instala la última versión en tu dispositivo Android y sal al monte con tu guía micológica privada y offline.",
    downloadVersionLabel: "Última versión disponible:",
    downloadBtnApk: "Descargar APK Directo",
    downloadBtnReleases: "Ver Releases en GitHub",
    downloadRequirements: "Requisitos: Android 7.0+ (Nougat) o superior · iOS 14.0+ (compilación desde código fuente).",

    safetyDisclaimerTitle: "Aviso de Responsabilidad Micológica",
    safetyDisclaimerText: "ZizAI es una herramienta de apoyo y divulgación micológica. La información de la aplicación jamás sustituye la revisión presencial de un micólogo experto o asociación micológica. Ante la menor duda sobre un ejemplar, descártalo y nunca lo consumas.",

    footerLicense: "Proyecto Open Source bajo licencia MIT · Autor: Ander Iriondo",
    footerSource: "Repositorio GitHub",
    footerReleases: "Notas de la Versión",
    footerSafety: "Seguridad"
  },

  en: {
    metaTitle: "ZizAI — Mycological Guide, Secret Spots Map & GPS Outings",
    navWhy: "Why ZizAI?",
    navAdvantages: "Advantages",
    navScreens: "Screens",
    navPrivacy: "Privacy",
    navDownload: "Download",

    // Hero
    heroBadge: "100% Standalone & Open Source",
    heroTitle: "Your private map of <span class='highlight'>secret foraging spots</span> and field guide",
    heroSubtitle: "The open-source mushroom foraging app built to work 100% offline in deep forests. Your secret spots and GPS tracks are never uploaded to any remote server: stored solely on your device or in your personal Google Drive.",
    heroPill1: "📖 126 species and 221 real photos",
    heroPill2: "🗺️ Topo, Satellite & Offline Maps",
    heroPill3: "🔒 100% Private · Zero Servers",
    heroPill4: "⚡ Battery-Friendly Manual Mode (0% drain)",
    heroCtaDownload: "Download APK (Free)",
    heroCtaGithub: "View on GitHub",

    // Objetivo
    sectionObjectiveTag: "MISSION & PHILOSOPHY",
    sectionObjectiveTitle: "Why was ZizAI built?",
    sectionObjectiveDesc: "Mushroom foragers face three major obstacles with existing apps: dense forests have zero cell signal, commercial apps upload secret GPS spots to third-party databases, and live GPS drains the phone battery. ZizAI was engineered to solve all three.",
    obj1Title: "100% Offline Field Catalog",
    obj1Text: "Deep in the woods, cellular networks fail. ZizAI stores all 126 species, 221 high-res field photos, morphology blocks, and poisonous lookalikes right on your device.",
    obj2Title: "Your Secret Spots Remain 100% Secret",
    obj2Text: "A forager's best spot is sacred. ZizAI is 100% serverless: we operate no remote servers to aggregate coordinates. Your locations belong exclusively to you.",
    obj3Title: "Transparent, Free & Open Source",
    obj3Text: "No paywalls, no recurring subscriptions, and zero tracking. Back up your findings into an offline ZIP archive or sync privately with Smart Merge on your personal Google Drive.",

    // Ventajas
    sectionAdvTag: "COMPARISON",
    sectionAdvTitle: "What sets ZizAI apart?",
    sectionAdvDesc: "Built by field foragers for real mountain expeditions, pairing scientific botanical accuracy with absolute privacy.",
    thFeature: "Feature",
    thZizai: "ZizAI (Open Source)",
    thOthers: "Commercial Apps",
    f1Title: "Foraging Spots Privacy",
    f1Desc: "GPS coordinates and secret finding photos",
    f1Zizai: "100% Local / Personal Google Drive",
    f1Others: "Stored in proprietary cloud servers",
    f2Title: "Zero Cell Signal Operation",
    f2Desc: "Catalog, photos, and forest cartography",
    f2Zizai: "126 species + Offline Topo/Satellite",
    f2Others: "Require network connection to load",
    f3Title: "Native Trilingual Taxonomy",
    f3Desc: "Basque, Spanish, English & Scientific Latin",
    f3Zizai: "A-Z sorting per language and dual search",
    f3Others: "Limited automatic translations",
    f4Title: "Battery-Saving Manual Mode",
    f4Desc: "Record foraged spots without live GPS tracking",
    f4Zizai: "Manual Outing (0% extra battery drain)",
    f4Others: "Continuous GPS drain required",
    f5Title: "Pricing & Integrity",
    f5Desc: "Cost, licensing, and advertisements",
    f5Zizai: "100% Free, Open Source & Ad-Free",
    f5Others: "€20-€40 yearly subscription fees",

    // Pantallas
    sectionScreensTag: "VISUAL TOUR",
    sectionScreensTitle: "The 4 Core Screens",
    sectionScreensDesc: "Explore the 4 primary modes of ZizAI's translucent bottom bar and the dedicated purpose of each screen.",
    tabCatalog: "Mushrooms",
    tabMap: "Map",
    tabOutings: "Outings",
    tabBackup: "Backup",

    screenCatalogTitle: "1. Mushrooms (Offline Botanical Field Guide)",
    screenCatalogBadge: "126 SPECIES · 221 FIELD PHOTOS",
    screenCatalogMission: "A comprehensive in-pocket field guide to swiftly look up species, examine identification keys, and check edibility deep in the mountains.",
    screenCatalogF1: "Dynamic A-Z sorting: Latin Scientific, Basque, Spanish, or English taxonomy.",
    screenCatalogF2: "Instant edibility filters (Choice Edible, Edible, Caution, Toxic/Deadly) and seasonal badges.",
    screenCatalogF3: "4-tier morphology breakdown (Cap, Hymenium, Stem, Flesh) and dangerous confusion warnings.",

    screenMapTitle: "2. Map (Private Foraging Cartography)",
    screenMapBadge: "TOPO · SATELLITE · OFFLINE REGIONS",
    screenMapMission: "Accurately record your foraging findings on contour lines or high-res satellite orthophotos, understanding terrain elevation and forest trails.",
    screenMapF1: "3 cartographic layers: Topographic contour lines, Esri World Imagery Satellite, and Standard OpenStreetMap.",
    screenMapF2: "Offline Region Manager: pre-cache natural parks before venturing into remote valleys.",
    screenMapF3: "Edibility color-coded spot markers and simultaneous multi-route GPS track overlays.",

    screenOutingsTitle: "3. Outings (GPS Tracker & Basket Summary)",
    screenOutingsBadge: "LIVE GPS OR ZERO-DRAIN MANUAL MODE",
    screenOutingsMission: "Track your expeditions: route map, elapsed time, total distance, and itemized basket tally with weight in grams.",
    screenOutingsF1: "Live GPS recorder featuring a precision radar fix (< 15 m) and anti-drift satellite filters.",
    screenOutingsF2: "Manual Outing Mode (0% battery drain): save findings without burning precious phone battery in cold weather.",
    screenOutingsF3: "Outing history cards with real topographic mini-maps and species harvest breakdowns.",

    screenBackupTitle: "4. Backup (Google Drive & Local Snapshots)",
    screenBackupBadge: "SMART MERGE · 100% PRIVATE",
    screenBackupMission: "Ensure your secret foraging history follows you safely across device upgrades and phone replacements.",
    screenBackupF1: "Personal Google Drive sync: securely saved within your account's private hidden appDataFolder.",
    screenBackupF2: "Smart Merge: blends cloud backups with new local discoveries by unique ID without overwriting data.",
    screenBackupF3: "Local ZIP Snapshots: export a self-contained archive of all photos and databases directly to your PC.",

    // Privacidad
    privacyTitle: "Your data belongs to you. 100% Private.",
    privacyDesc: "ZizAI never connects to central proprietary servers. Your secret spots are your personal foraging heritage.",
    privacyB1: "🚫 Zero third-party servers and zero ad tracking.",
    privacyB2: "📱 Secure local device storage in SQLite.",
    privacyB3: "☁️ Stored solely in your personal Google Drive (appDataFolder).",
    privacyPill1: "📱 100% Local",
    privacyPill2: "☁️ Your Google Drive",
    privacyPill3: "🚫 Zero Servers",

    // Descarga
    downloadTitle: "Download ZizAI for Free",
    downloadDesc: "Install the latest version on your Android device and explore nature with your private offline field guide.",
    downloadVersionLabel: "Latest release:",
    downloadBtnApk: "Download Direct APK",
    downloadBtnReleases: "View GitHub Releases",
    downloadRequirements: "Requirements: Android 7.0+ (Nougat) or later · iOS 14.0+ (build from source code).",

    safetyDisclaimerTitle: "Mycological Safety Disclaimer",
    safetyDisclaimerText: "ZizAI is an informational field guide. App information never replaces physical inspection by an experienced mycologist or society. When in doubt, never consume any wild mushroom.",

    footerLicense: "Open Source Project under MIT License · Author: Ander Iriondo",
    footerSource: "GitHub Repository",
    footerReleases: "Release Notes",
    footerSafety: "Safety"
  }
};

class ZizAIApp {
  constructor() {
    this.currentLang = this.detectLanguage();
    this.currentScreenTab = 'catalog';
    this.latestReleaseTag = 'v1.6.0';
    this.latestApkUrl = 'https://github.com/anderiri2/perretxikotan/releases/latest';

    this.initElements();
    this.bindEvents();
    this.setLanguage(this.currentLang);
    this.fetchLatestRelease();
  }

  detectLanguage() {
    const saved = localStorage.getItem('zizai_lang');
    if (saved && I18N[saved]) return saved;

    const navLang = (navigator.language || navigator.userLanguage || '').toLowerCase();
    if (navLang.startsWith('eu')) return 'eu';
    if (navLang.startsWith('es')) return 'es';
    return 'en';
  }

  initElements() {
    this.langButtons = document.querySelectorAll('.lang-btn');
    this.screenTabButtons = document.querySelectorAll('.screen-tab-btn');
    this.screenPanels = document.querySelectorAll('.screen-panel');
    this.lightbox = document.getElementById('lightboxModal');
    this.lightboxImg = document.getElementById('lightboxImg');
    this.lightboxClose = document.getElementById('lightboxClose');
    this.heroMockupImg = document.getElementById('heroMockupImg');
  }

  bindEvents() {
    // Selector de idiomas
    this.langButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const lang = btn.dataset.lang;
        this.setLanguage(lang);
      });
    });

    // Pestañas de pantallas
    this.screenTabButtons.forEach(btn => {
      btn.addEventListener('click', () => {
        const tabKey = btn.dataset.screen;
        this.setScreenTab(tabKey);
      });
    });

    // Lightbox para imágenes
    document.querySelectorAll('.zoomable-screen').forEach(img => {
      img.addEventListener('click', () => {
        this.openLightbox(img.src);
      });
    });

    if (this.lightboxClose) {
      this.lightboxClose.addEventListener('click', () => this.closeLightbox());
    }
    if (this.lightbox) {
      this.lightbox.addEventListener('click', (e) => {
        if (e.target === this.lightbox) this.closeLightbox();
      });
    }
  }

  setLanguage(lang) {
    if (!I18N[lang]) return;
    this.currentLang = lang;
    localStorage.setItem('zizai_lang', lang);

    // Actualizar botones de idioma activos
    this.langButtons.forEach(b => {
      b.classList.toggle('active', b.dataset.lang === lang);
    });

    const t = I18N[lang];
    document.documentElement.lang = lang;
    document.title = t.metaTitle;

    // Actualizar todos los elementos con data-i18n
    document.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.dataset.i18n;
      if (t[key]) {
        el.innerHTML = t[key];
      }
    });

    // Actualizar rutas de capturas de pantalla según el idioma
    this.updateScreenshots();
  }

  setScreenTab(tabKey) {
    this.currentScreenTab = tabKey;
    this.screenTabButtons.forEach(b => {
      b.classList.toggle('active', b.dataset.screen === tabKey);
    });
    this.screenPanels.forEach(panel => {
      panel.classList.toggle('active', panel.id === `screen-${tabKey}`);
    });
  }

  updateScreenshots() {
    const lang = this.currentLang;
    const screens = {
      hero: `screenshots/${lang}/01_catalog.png`,
      catalog: `screenshots/${lang}/01_catalog.png`,
      map: `screenshots/${lang}/02_map.png`,
      outings: `screenshots/${lang}/03_outings.png`,
      backup: `screenshots/${lang}/04_backup.png`
    };

    const applyImage = (img, newSrc, fallbackSrc) => {
      if (!img) return;
      if (img.getAttribute('src') === newSrc) return;
      img.style.opacity = '0.5';
      const onDone = () => {
        img.style.opacity = '1';
      };
      img.onload = onDone;
      img.onerror = () => {
        if (fallbackSrc && img.src !== fallbackSrc) {
          img.src = fallbackSrc;
        }
        onDone();
      };
      img.src = newSrc;
    };

    if (this.heroMockupImg) {
      applyImage(this.heroMockupImg, screens.hero, 'screenshots/eu/01_catalog.png');
    }

    const screenFallbacks = {
      catalog: 'screenshots/eu/01_catalog.png',
      map: 'screenshots/eu/02_map.png',
      outings: 'screenshots/eu/03_outings.png',
      backup: 'screenshots/eu/04_backup.png'
    };

    Object.keys(screenFallbacks).forEach(key => {
      const img = document.getElementById(`img-screen-${key}`);
      if (img) {
        applyImage(img, screens[key], screenFallbacks[key]);
      }
    });
  }

  openLightbox(src) {
    if (!this.lightbox || !this.lightboxImg) return;
    this.lightboxImg.src = src;
    this.lightbox.showModal();
  }

  closeLightbox() {
    if (!this.lightbox) return;
    this.lightbox.close();
  }

  async fetchLatestRelease() {
    try {
      const res = await fetch('https://api.github.com/repos/anderiri2/perretxikotan/releases/latest');
      if (!res.ok) return;
      const data = await res.json();
      if (data.tag_name) {
        this.latestReleaseTag = data.tag_name;
        document.querySelectorAll('.release-tag-text').forEach(el => {
          el.textContent = data.tag_name;
        });
      }

      // Buscar si hay un archivo .apk en los assets
      if (Array.isArray(data.assets)) {
        const apkAsset = data.assets.find(a => a.name && a.name.endsWith('.apk'));
        if (apkAsset && apkAsset.browser_download_url) {
          this.latestApkUrl = apkAsset.browser_download_url;
          document.querySelectorAll('.apk-download-link').forEach(el => {
            el.href = this.latestApkUrl;
          });
        }
      }
    } catch (_) {
      // Si la API falla o excede rate-limit, los enlaces apuntan de forma segura a releases/latest
    }
  }
}

document.addEventListener('DOMContentLoaded', () => {
  new ZizAIApp();
});
