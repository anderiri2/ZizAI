# Changelog — Perretxikotan

Todos los cambios relevantes de **Perretxikotan** siguen el flujo Gitflow (`feature/*` → `develop` → `main`) con etiquetas de versión semántica.

## [1.5.1] - 2026-11-03 (`v1.5.1`)
### Cambiado
- **Icono Adaptativo Nativo a Pantalla Completa en Android e iOS**:
  - Creación de `mipmap-anydpi-v26/ic_launcher.xml` y `ic_launcher_round.xml` con fondo continuo verde bosque oscuro (`#1C281A`) y capa frontal `ic_launcher_foreground.png` escalada a la zona segura completa sin bordes dobles ni esquinas blancas, evitando que el launcher de Android reduzca el icono dentro de un círculo blanco.
  - Regeneración de `assets/images/logo_perretxikotan.png`, `ic_launcher.png`, `ic_launcher_round.png` y `AppIcon.appiconset` sin marcos exteriores.
- **Eliminación de Referencias Geográficas en Textos y Catálogo**:
  - Eliminada toda referencia a *Euskal Herria*, *Península Ibérica*, *Euskadi* o *España* en cabeceras, subtítulos, panel lateral de ajustes (`SettingsDrawer`), servicio de IA y en las 126 fichas trilingües de `assets/data/mushrooms_catalog.json`.

## [1.5.0] - 2026-11-02 (`v1.5.0`)
### Añadido
- **Ubicación Interactiva de Setas en Mapa desde Catálogo**:
  - Al pulsar *"Guardar ubicación de esta seta en el Mapa"* desde la ficha de una especie en el catálogo, la app navega al Mapa Global con un banner superior flotante interactivo (*"Ukitu mapan perretxikoa kokatzeko" / "Toca en el mapa para ubicar [Seta]"*).
  - Tocar en cualquier punto del mapa ubica el marcador inmediatamente y despliega el formulario con las coordenadas ya asignadas, eliminando la necesidad de escribir coordenadas GPS a mano.
  - Botón *"Ajustar en el mapa"* dentro del formulario de setal para reubicar marcadores tocando en el mapa.
- **Panel Modal Unificado de Filtros y Rutas GPS y Cabecera Horizontal en Mapa Global**:
  - Cabecera flotante rediseñada en dos filas: primera fila con el título completo horizontal (`Perretxiko-lekuen Mapa` / `Mapa de Setales` / `Foraging Map`) y contador de setales; segunda fila con barra de herramientas horizontal (`Filtroak eta Rutak`, `Topo`, `Offline` y píldoras activas).
  - Unificación en un único punto de entrada `Filtroak eta Rutak` (`Icons.tune_rounded`) con insignia numérica de filtros activos, eliminando botones flotantes duplicados.
  - Filtro por especie concreta del catálogo (126 especies con foto y buscador rápido) y por comestibilidad (Guztiak / Jangarriak / Toxikoak).
  - Filtro por pertenencia a salidas y selector multilínea de rutas GPS con *checkboxes* para superponer las rutas deseadas simultáneamente con paleta cromática otoñal.
- **Localización 100% Pura por Idioma Activo (`EU` / `ES` / `EN`)**:
  - Eliminación de todas las cadenas bilingües concatenadas con barra (`A / B`) en Mapa, Salidas, Catálogo, Asistente IA y Panel de Ajustes, respetando íntegramente el idioma seleccionado (con Euskera como idioma por defecto).
- **Grabación Limpia de Rutas GPS en Cualquier Ubicación**:
  - Eliminación de la coordenada forzada en el Parque Natural de Gorbeia (`LatLng(43.0340, -2.7270)`).
  - La ruta GPS arranca limpia con la posición real del dispositivo satelital (o vacía hasta la primera señal), permitiendo guardar rutas en cualquier parque natural o municipio sin polilíneas anómalas.
- **Vista de Mapa Ampliada para Salidas GPS Activas (`LiveOutingMapScreen`)**:
  - Modo inmersivo a pantalla completa con el track en vivo, marcadores y posición actual.
  - Barra flotante superior con cronómetro parpadeante, distancia recorrida y recuento de setas.
  - Botonera flotante inferior con pausa/reanudar, *"Anotar en mi GPS actual"*, *"Ubicar en el mapa"* con un toque, y *"Terminar salida"*.

## [1.4.0] - 2026-11-01 (`v1.4.0`)
### Añadido
- **Panel Deslizable Izquierdo de Configuración (`SettingsDrawer`)**:
  - Gesto deslizable desde el borde izquierdo en todas las pantallas principales de `HomeShellScreen`.
  - Botón de menú hamburguesa (`☰`) en la cabecera del Catálogo principal.
  - Traslado y ocultación del selector de idioma fuera de las cabeceras públicas, ahora con tarjetas táctiles trilingües (**Euskara**, **Castellano**, **English**) en el panel lateral.
  - Atajos directos a gestión de cuenta, Instantáneas ZIP locales, guía de diagnóstico OAuth y decálogo de seguridad micológica.
- **Salidas Manuales al Monte sin GPS (`isManual`)**:
  - Selector de modalidad al pulsar *Nueva Salida*: **Ruta GPS en Vivo**, **Salida Manual en Directo (Sin GPS)** (0% gasto de batería satelital) o **Salida Pasada Retrospectiva** (con selección de fecha y duración).
  - Selección de setas a pantalla completa con aviso interactivo (`MapSpotPickerScreen`): permite tocar directamente sobre cualquier punto del mapa para ubicar y registrar especies, fotos, cantidad y peso en la salida.
  - Etiqueta distintiva *"Salida Manual (Sin GPS)"* en las tarjetas de salida y ficha técnica.
- **Transparencia en Modo IA y Gating Fotográfico con Google**:
  - Bloqueo explicativo previo para el análisis de fotos con visión artificial multimodal de Gemini en caso de no haber iniciado sesión con Google.
  - Banner permanente de *Modo Local Offline* (asistente morfológico de 126 especies) para consultas de texto en monte sin cobertura.
- **Diagnóstico y Corrección de Google Sign-In y Google Drive**:
  - Limpieza de scopes en `GoogleSignIn` a `drive.appdata` y `email`, evitando excepciones por scopes no autorizados en Google Play Services.
  - Corrección de `GOOGLE_SETUP.md` con el applicationId exacto `com.perretxikotan.perretxikotan`.
  - Diálogo modal de diagnóstico en caso de fallo de Google OAuth con instrucciones para la huella SHA-1 y alternativa inmediata de Snapshot Local (ZIP).


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
