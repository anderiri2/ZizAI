# 🍄 Perretxikotan — Guía Micológica, Rutas GPS, Mapas Offline e IA para Euskadi y España

**Perretxikotan** es una aplicación multiplataforma desarrollada en **Flutter** (Android e iOS) para aficionados a la recolección de setas en el País Vasco y España. Funciona con arquitectura **100% standalone (sin servidor propio)**, utilizando la cuenta personal de Google del usuario tanto para las copias de seguridad privadas en **Google Drive (`appDataFolder`)** como para la identificación micológica mediante **IA Gemini**, sin necesidad de configurar Google AI Studio.

---

## ✨ Funcionalidades Principales (5 Modos en Barra Translúcida)

1. **📖 Setas (Catálogo Micológico 100% Offline — 126 Especies y 221 Fotos Reales)**
   - Ordenación alfabética **A–Z** seleccionable por **Castellano**, **Euskera** o **Nombre Científico**.
   - Buscador trilingüe en tiempo real y filtros rápidos (*Excelentes*, *Comestibles*, *Precaución*, *Tóxicas/Mortales*, *Otoño*, *Primavera*, *Favoritas*).
   - Ficha detallada con carrusel de fotos reales, morfología en 4 bloques (*Sombrero / Txapela*, *Himenio*, *Pie / Hanka*, *Carne, Olor y Sabor*), hábitat, temporada, nivel de comestibilidad en 6 grados y **Confusiones Habituales interactivas** enlazadas entre fichas.

2. **🗺️ Mapa Global Topográfico y Descarga de Regiones Offline**
   - Capas **Topográfica con curvas de nivel (`OpenTopoMap`)** y **Estándar (`OpenStreetMap`)**.
   - **Caché automática de teselas (`OfflineCachingTileProvider`)** y gestor de **Mapas Offline (`OfflineMapsSheet`)** para descargar el área en pantalla o 6 zonas micológicas de Euskadi y Navarra (*Gorbeia*, *Urbasa y Andia*, *Selva de Irati*, *Sierra de Aralar*, *Urkiola* e *Izki*) antes de subir al monte sin cobertura.
   - Marcadores diferenciados visualmente para **puntos registrados durante una Salida** vs **puntos sueltos**, con barra de filtro superior (*Todos*, *Puntos sueltos* o *Salida concreta*).

3. **🥾 Salidas al Monte y Rutas GPS**
   - Grabadora de rutas GPS en vivo (`ActiveOutingRecorder`) con cronómetro, distancia en km, trazado de polilínea y registro de hallazgos con **número de ejemplares (`quantityCount`)** y **peso opcional (`weightGrams`)**.
   - **Tarjetas Resumen de Salida** con mini-mapa vectorial de la ruta y puntos, distancia, duración y resumen total de la cesta agrupado por especie.
   - Al eliminar una salida, permite elegir entre **conservar las setas en el Mapa Global** o **borrar la salida y sus puntos**.

4. **✨ IA Foto (Identificador Micológico con Gemini sin Google AI Studio)**
   - Permite sacar una foto con la cámara o subirla de la galería y chatear con **Gemini** reutilizando directamente la sesión OAuth de Google del usuario (sin claves API manuales ni Google AI Studio).
   - **Modo Sin Cobertura con Cola Pendiente**: si estás en el bosque sin cobertura móvil, guarda tu consulta con foto como *"Pendiente de conexión"* para reintentar con Gemini al volver a tener red y responde al instante con el **Asistente Morfológico Local** sobre las 126 especies del catálogo.
   - Botón directo en las tarjetas de especies sugeridas: **"Guardar este hallazgo en Mapa / Salida activa"** reutilizando la foto recién tomada.

5. **☁️ Backup Integral en Google Drive (`appDataFolder`) con Fusión Inteligente**
   - Empaqueta toda la actividad del usuario (`spots.json`, `outings.json`, `favorites.json`, `ai_chats.json`, `offline_regions.json` y carpeta `photos/`) dentro de `perretxikotan_backup.zip`.
   - **Fusión Inteligente (Smart Merge por ID)** activada por defecto al restaurar: combina los datos de la nube con los locales sin perder nada (con opción de *Reemplazar todo*).

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

---

## 🚀 Cómo Ejecutar el Proyecto

```bash
flutter pub get
flutter test
flutter run
```

Para configurar el OAuth de tu proyecto de Google Cloud (Android SHA-1 / iOS `REVERSED_CLIENT_ID`), consulta [`GOOGLE_SETUP.md`](GOOGLE_SETUP.md).
