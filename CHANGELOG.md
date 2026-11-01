# Changelog — Perretxikotan

Todos los cambios relevantes de **Perretxikotan** siguen el flujo Gitflow (`feature/*` → `develop` → `main`) con etiquetas de versión semántica.

## [1.3.0] - 2026-11-01 (`v1.3.0`)
### Cambiado
- **Nuevo Logo Ilustrado de *Amanita caesarea* y Splash Animado de 2.0 Segundos (`feature/custom-caesarea-logo-and-2s-splash`)**:
  - Sustitución de `assets/images/logo_perretxikotan.png` y de todos los iconos nativos de Android (`mipmap-*`) e iOS (`AppIcon.appiconset`) por la ilustración vectorial de *Amanita caesarea* con su huevo blanco (*volva*) sobre fondo verde bosque oscuro (`#192718`).
  - Nuevo `SplashScreen` animado de **exactamente 2.0 segundos (`2000 ms`)** con los 24 fotogramas de eclosión de la volva blanca, emergencia del pie amarillo con anillo y apertura del sombrero naranja intenso de la *Amanita caesarea*.
  - Configuración de `launch_background.xml` en Android con el color `#192718` para transición nativa sin pantallazo blanco.

## [1.2.0] - 2026-11-01 (`v1.2.0`)
### Añadido
- **Soporte Trilingüe Completo (`EU` / `ES` / `EN`) con Euskera (`eu`) como idioma principal por defecto (`feature/trilingual-eu-es-en`)**:
  - Sistema de localización reactivo (`appLanguageProvider`, `AppStrings`, `LanguageSelectorPill`) persistido en `SharedPreferences`, iniciando por defecto en **Euskera (`AppLanguage.eu`)**.
  - Selector rápido `EU | ES | EN` integrado en `LoginScreen`, `CatalogScreen`, `MushroomDetailScreen`, `OutingsScreen`, `AiIdentifierScreen` y `BackupScreen`.
  - Catálogo de **126 especies** enriquecido con nombres, hábitats, temporadas, resúmenes y morfologías en **Euskera, Castellano e Inglés**, ordenado por defecto alfabéticamente en **Euskara (A–Z)**.

## [1.1.0] - 2026-11-01 (`v1.1.0`)
### Añadido
- **Nuevo Logo e Iconos Nativos con *Amanita caesarea* (`feature/amanita-caesarea-branding`)**:
  - Nuevo emblema principal (`assets/images/logo_perretxikotan.png`) e iconos nativos de Android (`mipmap-*`) e iOS (`AppIcon.appiconset`) basados en un primer plano de *Amanita caesarea* (*Gorringo / Oronja*) en una campa.
  - **Splash Screen Animado del Nacimiento y Apertura de la *Amanita caesarea***: animación en 3 fases botánicas (ruptura de la volva blanca en la hierba → emergencia del pie amarillo oro → apertura del sombrero naranja intenso y esporas doradas).

## [1.0.0] - 2026-11-01 (`v1.0.0`)
### Añadido
- **Backup Integral de toda la actividad en Google Drive (`appDataFolder`)**: empaquetado de `spots.json`, `outings.json`, `favorites.json`, `ai_chats.json`, `offline_regions.json` y carpeta `photos/` dentro de `perretxikotan_backup.zip`.
- **Fusión Inteligente (Smart Merge por ID)**: al restaurar desde Google Drive o desde el Snapshot ZIP local, combina por defecto los registros en la nube con los locales sin perder ninguna salida ni ubicación.
- **Barra de navegación inferior translúcida con 5 modos**: *Setas*, *Mapa*, *Salidas*, *IA Foto* y *Backup*.
- **Integración transversal entre pestañas**: envío directo de especies identificadas con IA (y su fotografía) al Mapa Global o Salida activa, y filtrado del Mapa Global por una Salida concreta desde su tarjeta resumen.

## [0.4.0] - 2026-11-01 (`v0.4.0`)
### Añadido
- **Identificador Micológico con IA Gemini (`feature/gemini-ai-identifier`)**:
  - Conexión multimodal directa usando la sesión OAuth de Google del usuario (`authenticatedClient()`), sin necesidad de configurar Google AI Studio ni claves API manuales.
  - **Modo Sin Cobertura con Cola Pendiente**: si el recolector fotografía una seta en el monte sin cobertura móvil, la consulta queda marcada como *"Pendiente de conexión"* para reintentar con Gemini al regresar, ofreciendo al instante una orientación morfológica sobre las 126 especies del catálogo local.
  - Botón directo en las tarjetas de especies sugeridas: *"Guardar este hallazgo en Mapa / Salida activa"* reutilizando la foto recién tomada.

## [0.3.0] - 2026-11-01 (`v0.3.0`)
### Añadido
- **Mapas Offline por Regiones y Caché Automática (`feature/offline-map-regions`)**:
  - `OfflineCachingTileProvider` que guarda automáticamente en disco cada tesela topográfica o estándar visualizada.
  - Descargador de regiones sin conexión (`OfflineMapsSheet`) para guardar el área visible en pantalla o 6 zonas micológicas predefinidas de Euskadi y Navarra (*Parque Natural del Gorbeia*, *Urbasa y Andia*, *Selva de Irati*, *Sierra de Aralar*, *Parque Natural de Urkiola* y *Parque Natural de Izki*).

## [0.2.0] - 2026-11-01 (`v0.2.0`)
### Añadido
- **Salidas al Monte y Rutas GPS (`feature/outings-gps-routes`)**:
  - Grabadora de rutas GPS en vivo (`ActiveOutingRecorder`) con cronómetro, distancia en km y trazado de polilínea.
  - Registro de hallazgos vinculados a una salida con **cantidad de ejemplares (`quantityCount`)** y **peso opcional en gramos (`weightGrams`)**.
  - Tarjetas resumen de salida con **mini-mapa vectorial de la ruta**, duración, distancia y desglose total de la cesta por especie.
  - Diferenciación visual de marcadores en el Mapa Global y barra de filtro superior (*Todos*, *Puntos sueltos* o *Salida concreta*).
  - Diálogo al borrar una salida con dos opciones: *"Conservar setas en Mapa Global"* o *"Borrar salida y sus puntos"*.

## [0.1.0] - 2026-11-01 (`v0.1.0`)
### Añadido
- **Base de la app, Tema Otoñal, Splash, Login Google y Catálogo Micológico Offline**:
  - Catálogo 100% offline con **126 especies** de Euskadi y España y **221 fotografías reales** en `assets/images/mushrooms/`.
  - Ordenación alfabética A–Z seleccionable (*Castellano*, *Euskera*, *Científico*), morfología en 4 bloques y confusiones habituales interactivas.
  - Compatibilidad nativa configurada para **Android 7.0+ (`minSdk = 24`, `targetSdk = 35`)** e **iOS 14.0+**.
