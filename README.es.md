<div align="center">

🌐 **Language / Hizkuntza / Idioma**: [**English**](README.md) | [**Euskara**](README.eu.md) | **Español**

</div>

---

# 🍄 ZizAI — Guía Micológica Offline, Mapa Privado de Setales y Rutas GPS

**ZizAI** es una aplicación multiplataforma desarrollada en **Flutter** (Android e iOS) para aficionados a la recolección de setas. Funciona con arquitectura **100% standalone (sin servidor propio y 100% privada)**, almacenando todos los datos localmente en el dispositivo (`SQLite`) y permitiendo utilizar la cuenta personal de Google del usuario para realizar copias de seguridad privadas en **Google Drive (`appDataFolder`)**.

🌐 **Web Oficial (GitHub Pages)**: [https://anderiri2.github.io/ZizAI/](https://anderiri2.github.io/ZizAI/)

---

## 🧪 ¡Buscamos Beta Testers para Google Play! (Prueba de 14 días)

> [!IMPORTANT]
> **¿Quieres ayudarnos a publicar ZizAI en Google Play Store?**
> Para que Google Play permita publicar aplicaciones de desarrolladores independientes en producción, exige superar una **prueba cerrada con al menos 12 usuarios probando la app de forma continua durante 14 días consecutivos**.

### 🤝 ¿En qué consiste tu ayuda?
1. **Apuntarte a la prueba cerrada** con tu cuenta de Google Play (Android).
2. **Instalar ZizAI** cuando activemos tu acceso.
3. **Mantener la app instalada durante 14 días seguidos** y abrirla periódicamente para probar sus funciones (catálogo offline, mapas satelitales/topo, rutas GPS y copias de seguridad).

👉 **¿Te apuntas?** [**Abre un Issue aquí en GitHub**](https://github.com/AnderIri2/ZizAI/issues/new?title=Beta+Tester+Google+Play&body=Hola,+quiero+participar+en+la+prueba+de+14+d%C3%ADas+de+ZizAI.) para unirte a la lista de beta testers. ¡Mil gracias por apoyar el proyecto! 🍄

---

## ✨ Funcionalidades Principales

### 1. 📖 Setas (Catálogo Micológico 100% Offline — 126 Especies y 252 Fotos Reales)
- **Localización Trilingüe Completa**: textos y fichas en **Euskara**, **Castellano** e **English** (detecta automáticamente el idioma del sistema con respaldo en inglés).
- Ordenación alfabética **A–Z** seleccionable por **Euskara**, **Castellano**, **English** o **Nombre Científico (Latín)**.
- Buscador en tiempo real insensible a tildes y filtros rápidos (*Excelentes*, *Comestibles*, *Precaución*, *Tóxicas/Mortales*, *Otoño*, *Primavera*, *Favoritas*).
- Ficha detallada con carrusel de fotos reales, morfología en 4 bloques (*Sombrero / Txapela*, *Himenio*, *Pie / Hanka*, *Carne, Olor y Sabor*), hábitat, temporada, nivel de comestibilidad en 6 grados y **Confusiones Habituales interactivas** enlazadas entre fichas.
- **Ubicación Interactiva Directa en Mapa**: botón *"Guardar ubicación de esta seta en el Mapa"* que abre el mapa con un banner interactivo para ubicar el marcador con un simple toque.

### 2. 🗺️ Mapa Global: Capas Satelital, Topográfica y Descarga Offline
- **3 Capas Cartográficas Conmutables**:
  - **Satelital de Alta Resolución (`Esri World Imagery`)**: ortofoto pura libre de etiquetas artificiales para identificar con nitidez masas boscosas (pinares, hayedos, robledales, calveros y pistas forestales).
  - **Topográfica con curvas de nivel (`OpenTopoMap`)**: relieve e hipsometría para planificar pendientes y desniveles.
  - **Estándar (`OpenStreetMap`)**: red de pistas, caminos y carreteras de acceso.
- **Marcadores con Orientación Vertical Fija (`rotate: true`)**: el número de ejemplares y el icono de la especie se contra-rotan automáticamente para mantenerse siempre legibles y nunca al revés al girar el mapa.
- **Guardado de Setales Multimodal**:
  - **Ubicación GPS Satelital**: radar modal (`GpsAcquisitionSheet`) que asegura fijación satelital precisa (< 15 m) antes de guardar.
  - **Marcar con el Dedo en el Mapa (con Diana Interactiva)**: retícula central de alta precisión con cruz de mira, halos de contraste y pin flotante; permite tocar con el dedo en cualquier punto del mapa para centrar la diana al instante o desplazar el mapa con el dedo para microajustes milimétricos.
  - **Introducción Manual de Coordenadas**: entrada directa de latitud y longitud para registrar ubicaciones conocidas.
- **Caché Automática y Descargas Offline (`OfflineCachingTileProvider` & `OfflineMapsSheet`)**: almacena en disco las teselas consultadas y permite descargar regiones personalizadas o 6 parques naturales micológicos (*Gorbeia*, *Urbasa y Andia*, *Irati*, *Aralar*, *Urkiola*, *Izki*) tanto en modo topográfico como satelital para usarse en zonas sin cobertura.
- **Panel Unificado de Filtros y Rutas**: filtra marcadores por especie concreta (con buscador y fotos), nivel de comestibilidad, puntos sueltos vs salidas, y superposición simultánea de rutas GPS con paleta cromática otoñal.

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
  - **Ruta GPS en Vivo**: seguimiento en tiempo real con polilínea de trazado, cronómetro sin deriva, distancia, servicio en segundo plano con notificación en Android y recuento de cesta.
  - **Salida Manual en Directo (Modo Cesta)**: 0% consumo de batería satelital, ubicando hallazgos en el mapa mediante la **Diana Interactiva (`MapCrosshairTarget`)** y barra de confirmación (`MapSpotPickerScreen`).
  - **Salida Pasada Retrospectiva**: registro a posteriori con fecha, duración y selección de setales en mapa con diana.
- **Vista de Mapa Ampliada (`LiveOutingMapScreen`)**: modo inmersivo a pantalla completa con conmutador satelital/topo/estándar, cronómetro flotante, y registro rápido *"Anotar aquí"* (GPS actual) o *"Ubicar en Mapa"* con la diana interactiva.
- **Historial y Tarjetas Resumen**: mini-mapa cartográfico real (`_OutingRouteMiniMap`) con la polilínea GPS de la ruta, duración, distancia y desglose de la cesta con número de ejemplares y peso en gramos.

### 4. ☁️ Backup Integral en Google Drive (`appDataFolder`) con Fusión Inteligente
- Empaqueta toda la actividad del usuario (`spots.json`, `outings.json`, `favorites.json`, `offline_regions.json` y carpeta de fotos `photos/`) dentro de `zizai_backup.zip`.
- **Fusión Inteligente (Smart Merge por ID)**: combina los datos remotos de la nube con los locales sin sobreescribir ni duplicar salidas ni setales existentes (con opción de reemplazo completo).
- **Copia Automática Opcional**: permite sincronizar automáticamente la actividad en Google Drive al finalizar una salida.
- Soporte para **Instantánea ZIP Local** exportable e importable en el teléfono sin necesidad de cuenta de Google.

### 5. ⚙️ Panel Deslizable Lateral (`SettingsDrawer`)
- Menú lateral deslizable accesible pulsando sobre el icono/logo superior izquierdo de **ZizAI**.
- Selector de idioma dinámico (**Euskara**, **Castellano**, **English**).
- Gestión de cuenta de Google (`appDataFolder`), acceso directo a instantáneas ZIP locales, tarjeta de **Garantía de Privacidad 100%** y **Decálogo de Seguridad Micológica**.

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
- `v1.0.0` (`feature/full-activity-drive-backup`): Backup integral en Google Drive (`appDataFolder`) con Fusión Inteligente e instantáneas ZIP locales.
- `v1.1.0` (`feature/amanita-caesarea-branding`): Logo e iconos nativos con *Amanita caesarea* y splash animado de apertura en 3 fases.
- `v1.2.0` (`feature/trilingual-eu-es-en`): Soporte trilingüe completo (`EU` / `ES` / `EN`).
- `v1.3.0` (`feature/custom-caesarea-logo-and-2s-splash`): Logo ilustrado de *Amanita caesarea* sobre fondo bosque oscuro y splash animado botánico de 2.0 segundos.
- `v1.4.0` (`feature/settings-drawer-manual-outings`): Panel deslizable izquierdo (`SettingsDrawer`), salidas manuales y retrospectivas sin GPS.
- `v1.5.0` (`feature/catalog-map-picker-filters-redesign`): Ubicación interactiva de setas desde el catálogo, panel modal unificado de filtros y rutas en mapa, pantalla completa de salida (`LiveOutingMapScreen`) y cadenas 100% en el idioma activo.
- `v1.5.1` (`feature/icon-and-minimap-fixes`): Icono adaptativo nativo a pantalla completa en Android/iOS sin bordes blancos, mini-mapa cartográfico real en tarjetas de salida y navegación inferior en 4 pestañas (`Setas`, `Mapa`, `Salidas`, `Backup`).
- `v1.6.0` (`feature/gps-satellite-mushroom-search`): Capa de mapa satelital puro (Esri World Imagery), adquisición de señal y precisión GPS (`GpsAcquisitionSheet`), buscador reactivo de setas (`MushroomSearchPicker`), orientación vertical fija de marcadores (`rotate: true`) y rebranding integral a ZizAI.
- `v1.7.0` (`feature/map-gps-accuracy-manual-basket-background`): Selector de fijación GPS con radar al guardar setas en mapa, salidas manuales rediseñadas como Cestas micológicas puras (sin trazado manual a mano), Foreground Service en segundo plano con notificación estable y cronómetro sin drift.
- `v1.7.1`: Diana interactiva con cruz de mira y modo de colocación de puntos tocando con el dedo en el mapa.
- `v1.7.2`: Selector de capas de mapa en salidas, seguimiento GPS puro, mejoras de notificación en segundo plano en Android, alcance `appDataFolder` de Drive al iniciar sesión y deduplicación de fotos del catálogo (252 fotografías reales únicas).

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

---

## 📄 Licencia

Este proyecto está licenciado bajo la **GNU General Public License v3.0 (GPLv3)** con permisos adicionales según la Sección 7 para distribución en tiendas móviles (Google Play / App Store).

- **Código Fuente**: Licencia libre [GNU GPLv3](LICENSE).
- **Marca y Logotipos**: El nombre **ZizAI**, la tipografía de marca y el logotipo oficial son propiedad exclusiva de Ander Iriondo y están reservados (cualquier fork debe utilizar un nombre y marca distintos).
- **Contenido Fotográfico y Catálogo**: Las fotografías originales en `assets/images/mushrooms/` y fichas descriptivas están protegidas por derechos de autor (C) 2026 Ander Iriondo para uso exclusivo en la aplicación.
