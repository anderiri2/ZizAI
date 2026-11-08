# 🍄 ZizAI — Guía Micológica, Rutas GPS, Mapas Satelitales/Topo Offline e IA

**ZizAI** es una aplicación multiplataforma desarrollada en **Flutter** (Android e iOS) para aficionados a la recolección de setas. Funciona con arquitectura **100% standalone (sin servidor propio)**, utilizando la cuenta personal de Google del usuario tanto para las copias de seguridad privadas en **Google Drive (`appDataFolder`)** como para la identificación micológica mediante **IA Gemini**, sin necesidad de configurar Google AI Studio.

🌐 **Web Oficial (GitHub Pages)**: [https://anderiri2.github.io/ZizAI/](https://anderiri2.github.io/ZizAI/)

---

## ✨ Funcionalidades Principales

### 1. 📖 Setas (Catálogo Micológico 100% Offline — 126 Especies y 221 Fotos Reales)
- **Localización Trilingüe Completa**: textos y fichas en **Euskara** (por defecto), **Castellano** e **English**.
- Ordenación alfabética **A–Z** seleccionable por **Euskara**, **Castellano** o **Nombre Científico**.
- Buscador en tiempo real insensible a tildes y filtros rápidos (*Excelentes*, *Comestibles*, *Precaución*, *Tóxicas/Mortales*, *Otoño*, *Primavera*, *Favoritas*).
- Ficha detallada con carrusel de fotos reales, morfología en 4 bloques (*Sombrero / Txapela*, *Himenio*, *Pie / Hanka*, *Carne, Olor y Sabor*), hábitat, temporada, nivel de comestibilidad en 6 grados y **Confusiones Habituales interactivas** enlazadas entre fichas.
- **Ubicación Interactiva Directa en Mapa**: botón *"Guardar ubicación de esta seta en el Mapa"* que abre el mapa con un banner interactivo para ubicar el marcador con un simple toque.

### 2. 🗺️ Mapa Global: Capas Satelital, Topográfica y Descarga Offline
- **3 Capas Cartográficas Conmutables**:
  - **Satelital de Alta Resolución (`Esri World Imagery`)**: ortofoto pura libre de etiquetas artificiales para identificar con nitidez masas boscosas (pinares, hayedos, robledales, calveros y pistas forestales).
  - **Topográfica con curvas de nivel (`OpenTopoMap`)**: relieve e hipsometría para planificar pendientes y desniveles.
  - **Estándar (`OpenStreetMap`)**: red de pistas, caminos y carreteras de acceso.
- **Marcadores con Orientación Vertical Fija (`rotate: true`)**: el número de ejemplares y el icono de la especie se contra-rotan automáticamente para mantenerse siempre legibles y nunca al revés al girar el mapa.
- **Caché Automática y Descargas Offline (`OfflineCachingTileProvider` & `OfflineMapsSheet`)**: almacena en disco las teselas consultadas y permite descargar regiones personalizadas o 6 parques naturales micológicos (*Gorbeia*, *Urbasa y Andia*, *Irati*, *Aralar*, *Urkiola*, *Izki*) tanto en modo topográfico como satelital para usarse en zonas sin cobertura.
- **Panel Unificado de Filtros y Rutas (`Filtroak eta Rutak`)**: filtra marcadores por especie concreta (con buscador y fotos), nivel de comestibilidad, puntos sueltos vs salidas, y superposición simultánea de rutas GPS con paleta cromática otoñal.

### 3. 🥾 Salidas al Monte y Rutas GPS
- **Mecanismo de Adquisición y Fijación GPS (`GPS Fix Acquisition`)**:
  - Pantalla modal (`GpsAcquisitionSheet`) con animación de radar y lectura continua de precisión en metros al pulsar *Iniciar salida*.
  - **Autoarranque inteligente**: al alcanzar precisión óptima ($< 15\text{ m}$) inicia la grabación automáticamente tras una cuenta atrás de 2 segundos y confirmación háptica.
  - Botón para forzar inicio inmediato y píldora de precisión flotante no intrusiva (`GpsStatusPill`) para centrado en mapa y marcado de coordenadas.
  - **Filtro activo de ruido**: descarte automático de lecturas erráticas ($> 35\text{ m}$) y bloqueo de saltos de teletransporte ($> 400\text{ m}$).
- **Buscador Reactivo de Setas (`MushroomSearchPicker`)**:
  - Selector táctil integrado al registrar un hallazgo, con tarjeta visual de la especie (miniatura, nombre científico, nombres populares y badge de comestibilidad).
  - Barra de accesos rápidos (*quick chips*) para especies habituales de otoño (*Boletus*, *Cantharellus*, *Lactarius*, *Amanita caesarea*, etc.).
  - Búsqueda a pantalla completa con teclado enfocado y filtrado instantáneo por cualquier denominación trilingüe o científica.
- **Grabación y Modos de Salida Flexibles**:
  - **Ruta GPS en Vivo**: seguimiento en tiempo real con polilínea de trazado, cronómetro, distancia y recuento de cesta.
  - **Salida Manual en Directo**: 0% consumo de batería satelital, registrando hallazgos tocando en el mapa interactivo (`MapSpotPickerScreen`).
  - **Salida Pasada Retrospectiva**: registro a posteriori con fecha, duración y selección de setales en mapa.
- **Vista de Mapa Ampliada (`LiveOutingMapScreen`)**: modo inmersivo a pantalla completa con conmutador satelital/topo, cronómetro flotante, y registro rápido *"Anotar en mi GPS actual"* o *"Ubicar en el mapa"*.
- **Historial y Tarjetas Resumen**: mini-mapa cartográfico real (`_OutingRouteMiniMap`) con la polilínea GPS de la ruta, duración, distancia y desglose de la cesta con número de ejemplares y peso en gramos.

### 4. ✨ IA Foto (Identificador Micológico con Gemini sin Google AI Studio)
- Identificación visual con **Gemini Multimodal** utilizando directamente la sesión OAuth de Google del usuario (sin necesidad de crear claves API en Google AI Studio).
- **Modo Sin Cobertura con Cola Pendiente**: guarda las fotos tomadas en el monte como *"Pendiente de conexión"* para procesarlas automáticamente al recuperar señal, respondiendo de inmediato con el **Asistente Morfológico Local** sobre las 126 especies del catálogo.
- Guardado en un toque: botón en la tarjeta de sugerencias de la IA para registrar la especie y su foto directamente en el Mapa Global o en la Salida activa.

### 5. ☁️ Backup Integral en Google Drive (`appDataFolder`) con Fusión Inteligente
- Empaqueta toda la actividad del usuario (`spots.json`, `outings.json`, `favorites.json`, `ai_chats.json`, `offline_regions.json` y carpeta de fotos `photos/`) dentro de `zizai_backup.zip`.
- **Fusión Inteligente (Smart Merge por ID)**: combina los datos remotos de la nube con los locales sin sobreescribir ni duplicar salidas ni setales existentes (con opción de reemplazo completo).
- Soporte para **Instantánea ZIP Local** exportable e importable sin conexión a Google.

### 6. ⚙️ Panel Deslizable Lateral (`SettingsDrawer`)
- Menú lateral deslizable accesible desde cualquier pantalla principal (`☰`).
- Selector de idioma dinámico (**Euskara**, **Castellano**, **English**).
- Diagnóstico de estado OAuth de Google, guía de configuración SHA-1, gestión de snapshots ZIP y decálogo de recolección responsable y seguridad micológica.

---

## 📱 Versiones de Android e iOS Soportadas

| Plataforma | Versión Mínima | Versión Objetivo | Cobertura de Dispositivos |
| :--- | :--- | :--- | :--- |
| **Android** | **Android 7.0 Nougat (`minSdk = 24`)** | **Android 15 (`targetSdk = 35`)** | ~99% de móviles activos |
| **iOS** | **iOS 14.0 (`platform :ios, '14.0'`)** | **iOS 18 SDK** | iPhone 6s / SE en adelante (~98%) |

---

## 🌿 Flujo de Control de Versiones (Gitflow)

El repositorio gestiona el ciclo de vida del código mediante ramas `feature/*`, integración en `develop` y entregas etiquetadas en `main`:

- `v0.1.0`: Base de la app, tema otoñal, splash, login y catálogo offline de 126 especies.
- `v0.2.0` (`feature/outings-gps-routes`): Grabadora de Salidas al Monte con GPS, tarjetas resumen y filtro en Mapa Global.
- `v0.3.0` (`feature/offline-map-regions`): Caché offline de mapas y descarga de zonas micológicas sin cobertura.
- `v0.4.0` (`feature/gemini-ai-identifier`): Identificador micológico con IA Gemini (OAuth único) y cola pendiente sin cobertura.
- `v1.0.0` (`feature/full-activity-drive-backup`): Backup integral en Google Drive con Fusión Inteligente y navegación de 5 pestañas.
- `v1.1.0` (`feature/amanita-caesarea-branding`): Nuevo logo e iconos nativos con *Amanita caesarea* y splash animado de apertura en 3 fases.
- `v1.2.0` (`feature/trilingual-eu-es-en`): Soporte trilingüe completo (`EU` / `ES` / `EN`) con Euskera como idioma principal por defecto.
- `v1.3.0` (`feature/custom-caesarea-logo-and-2s-splash`): Logo ilustrado de *Amanita caesarea* sobre fondo bosque oscuro y splash animado botánico de 2.0 segundos.
- `v1.4.0` (`feature/settings-drawer-manual-outings`): Panel deslizable izquierdo (`SettingsDrawer`), salidas manuales y retrospectivas sin GPS, y diagnóstico OAuth.
- `v1.5.0` (`feature/catalog-map-picker-filters-redesign`): Ubicación interactiva de setas desde el catálogo, panel modal unificado de filtros y rutas en mapa, pantalla completa de salida (`LiveOutingMapScreen`) y cadenas 100% en el idioma activo.
- `v1.5.1` (`feature/icon-and-minimap-fixes`): Icono adaptativo nativo a pantalla completa en Android/iOS sin bordes blancos, mini-mapa cartográfico real en tarjetas de salida y limpieza de referencias geográficas en catálogo.
- `v1.6.0` (`feature/gps-satellite-mushroom-search`): Capa de mapa satelital puro (Esri World Imagery), adquisición de señal y precisión GPS (`GpsAcquisitionSheet`), buscador reactivo de setas (`MushroomSearchPicker`), orientación vertical fija de marcadores (`rotate: true`) y rebranding integral a ZizAI.
- `v1.7.0` (`feature/map-gps-accuracy-manual-basket-background`): Selector de fijación GPS con radar al guardar setas en mapa, salidas manuales rediseñadas como Cestas micológicas puras (sin trazado manual a mano), Foreground Service en segundo plano con notificación estable y cronómetro sin drift.

---

## 🚀 Cómo Ejecutar el Proyecto

```bash
flutter pub get
flutter test
flutter run
```

Para compilar el binario release optimizado:
```bash
flutter build apk --release
```

Para configurar el OAuth de tu proyecto de Google Cloud (Android SHA-1 / iOS `REVERSED_CLIENT_ID`), consulta [`GOOGLE_SETUP.md`](GOOGLE_SETUP.md).
