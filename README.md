<div align="center">

🌐 **Language / Hizkuntza / Idioma**: **English** | [**Euskara**](README.eu.md) | [**Español**](README.es.md)

</div>

---

# 🍄 ZizAI — Offline Mycological Field Guide, Private Spots Map & GPS Routes

**ZizAI** is a cross-platform mobile application built with **Flutter** (Android & iOS) for mushroom foraging enthusiasts. It operates on a **100% standalone architecture (serverless & 100% private)**, storing all data locally on the device (`SQLite`) and optionally using the user's personal Google account for encrypted cloud backups in **Google Drive (`appDataFolder`)**.

🌐 **Official Website (GitHub Pages)**: [https://anderiri2.github.io/ZizAI/](https://anderiri2.github.io/ZizAI/)

---

## 🧪 Looking for Google Play Beta Testers! (14-Day Closed Test)

> [!IMPORTANT]
> **Want to help us launch ZizAI on the Google Play Store?**
> To unlock production access on Google Play for independent developers, Google requires a **closed test with at least 12 testers continuously opted-in and testing the app for 14 consecutive days**.

### 🤝 How can you help?
1. **Join the closed test** with your Google Play (Android) account.
2. **Install ZizAI** and test it once your access is enabled.
3. **Keep the app installed for 14 consecutive days** and open it regularly to test its features (offline catalog, satellite/topo maps, GPS routes, and backups).

👉 **Want to join?** [**Open an Issue here on GitHub**](https://github.com/AnderIri2/ZizAI/issues/new?title=Google+Play+Beta+Tester&body=Hi,+I+would+like+to+join+the+14-day+closed+test+for+ZizAI.) to sign up for the 14-day closed beta track. Thank you for supporting the project! 🍄

---

## ✨ Key Features

### 1. 📖 Mushrooms (100% Offline Mycological Catalog — 126 Species & 252 Real Photos)
- **Complete Trilingual Localization**: all descriptions and species cards in **Basque / Euskara**, **Spanish** and **English** (automatically detects device system language with English fallback).
- **A–Z** alphabetical sorting selectable by **Basque**, **Spanish**, **English** or **Scientific Name (Latin)**.
- Real-time accent-insensitive search bar and quick filters (*Choice Edible*, *Edible*, *Caution*, *Toxic/Deadly*, *Autumn*, *Spring*, *Favorites*).
- Detailed species profile with real photo carousel, 4-block morphology (*Cap / Txapela*, *Hymenium*, *Stem / Hanka*, *Flesh, Odor & Taste*), habitat, season, 6-tier edibility rating and **Interactive Common Lookalikes** cross-linked between profiles.
- **Direct Interactive Map Placement**: *"Save location of this mushroom on the Map"* button that opens the map with an interactive banner to drop a pin with a single tap.

### 2. 🗺️ Global Map: Satellite, Topographic & Offline Downloads
- **3 Switchable Base Map Layers**:
  - **High-Resolution Satellite (`Esri World Imagery`)**: pure orthophoto free of artificial labels to clearly identify forest types (pinewoods, beech forests, oak groves, clearings and forest tracks).
  - **Topographic with Contour Lines (`OpenTopoMap`)**: terrain relief and elevation contours to plan slopes and altitude changes.
  - **Standard (`OpenStreetMap`)**: network of forest tracks, trails and access roads.
- **Fixed Upright Marker Orientation (`rotate: true`)**: specimen counts and species icons counter-rotate automatically so they always remain upright and readable when rotating the map.
- **Multi-Mode Spot Saving**:
  - **Satellite GPS Location**: modal radar (`GpsAcquisitionSheet`) ensuring accurate satellite lock (< 15 m) before saving.
  - **Finger Tap on Map (with Interactive Crosshair Reticle)**: high-precision central reticle with crosshair, contrast halos and floating pin; tap anywhere on the map to instantly center the reticle or pan the map for millimeter adjustments.
  - **Manual Coordinates Entry**: direct latitude/longitude input when logging known coordinates.
- **Automatic Cache & Offline Downloads (`OfflineCachingTileProvider` & `OfflineMapsSheet`)**: caches viewed tiles on disk and allows downloading custom bounding boxes or 6 natural parks (*Gorbeia*, *Urbasa & Andia*, *Irati*, *Aralar*, *Urkiola*, *Izki*) in both topographic and satellite modes for zero-coverage areas.
- **Unified Filters & Routes Panel**: filter markers by specific species (with search and thumbnails), edibility level, standalone spots vs outings, and simultaneous GPS route overlays with an autumn color palette.

### 3. 🥾 Forest Outings & GPS Routes
- **GPS Fix Acquisition Mechanism (`GPS Fix Acquisition`)**:
  - Modal radar sheet (`GpsAcquisitionSheet`) with live accuracy readout in meters when tapping *Start Outing*.
  - **Smart Auto-Start**: automatically starts recording upon reaching optimal accuracy ($< 15\text{ m}$) after a 2-second countdown and haptic feedback.
  - Immediate start override button and non-intrusive floating accuracy pill (`GpsStatusPill`) for map centering and coordinate marking.
  - **Active Noise Filter**: automatic rejection of erratic readings ($> 35\text{ m}$) and teleport jump blocking ($> 400\text{ m}$).
- **Reactive Mushroom Search Picker (`MushroomSearchPicker`)**:
  - Touch-friendly selector integrated into finding registration, featuring visual species cards (thumbnail, scientific name, common names and edibility badge).
  - Quick chips bar for common autumn species (*Boletus*, *Cantharellus*, *Lactarius*, *Amanita caesarea*, etc.).
  - Full-screen search with focused keyboard and instant filtering by any trilingual or scientific name.
- **Flexible Outing Modes**:
  - **Live GPS Route**: real-time tracking with route polyline, drift-free stopwatch, distance, Android Foreground Service background notification and basket counter.
  - **Live Manual Outing (Basket Mode)**: 0% satellite battery drain, logging finds on the interactive map using the high-precision central **Crosshair Reticle (`MapCrosshairTarget`)** and confirmation bar (`MapSpotPickerScreen`).
  - **Past Retrospective Outing**: post-outing registration with date, duration and crosshair map spot selection.
- **Expanded Map View (`LiveOutingMapScreen`)**: full-screen immersive mode with satellite/topo/standard layer switcher, floating stopwatch, and quick logging (*"Spot here"* at current GPS or *"Place on Map"* with the interactive crosshair reticle).
- **History & Summary Cards**: real cartographic mini-map (`_OutingRouteMiniMap`) displaying the GPS route polyline, duration, distance and basket breakdown with specimen count and weight in grams.
- **Continuous Fail-Safe Auto-Save & Recovery**: active outings and recorded spots are saved continuously in real time from the moment an outing starts, automatically recovering interrupted sessions or reconstructing orphaned outings from saved spots even if the app closes unexpectedly.
- **Continue Finished Outings**: any completed outing can be resumed at any time from its summary card or detail screen, preserving its ID, route, recorded spots, distance, and accumulated duration.

### 4. ☁️ Full Google Drive Backup (`appDataFolder`) with Smart Merge
- Packages all user activity (`spots.json`, `outings.json`, `favorites.json`, `offline_regions.json` and `photos/` folder) into `zizai_backup.zip`.
- **Smart Merge by ID**: merges remote cloud data with local records without overwriting or duplicating existing outings or mushroom spots (with a full replace option also available).
- **Automatic Backup Option**: optionally syncs activity to Google Drive automatically after saving an outing.
- Supports exportable and importable **Local ZIP Snapshots** on the phone without a Google connection.

### 5. ⚙️ Slide-Out Settings Drawer (`SettingsDrawer`)
- Accessible by tapping the top-left **ZizAI** logo on the main screen.
- Dynamic language switcher (**Euskara**, **Castellano**, **English**).
- Google account connection status (`appDataFolder`), quick access to local ZIP snapshots, **100% Data Privacy Guarantee** details, and the **Mycological Safety Decalogue**.

---

## 📱 Supported Android & iOS Versions

| Platform | Minimum Version | Target Version | Device Coverage |
| :--- | :--- | :--- | :--- |
| **Android** | **Android 7.0 Nougat (`minSdk = 24`)** | **Android 15 (`targetSdk = 35`)** | ~99% of active devices |
| **iOS** | **iOS 14.0 (`platform :ios, '14.0'`)** | **iOS 18 SDK** | iPhone 6s / SE and newer (~98%) |

---

## 🌿 Version Control Workflow (Gitflow)

The repository manages the code lifecycle through `feature/*` branches, integration in `develop`, and tagged releases in `main`:

- `v0.1.0`: Core app foundation, autumn theme, splash, login and 126-species offline catalog.
- `v0.2.0` (`feature/outings-gps-routes`): Forest Outings GPS recorder, summary cards and Global Map filtering.
- `v0.3.0` (`feature/offline-map-regions`): Offline map tile cache and zero-coverage mycological region downloads.
- `v1.0.0` (`feature/full-activity-drive-backup`): Full Google Drive backup (`appDataFolder`) with Smart Merge and local ZIP snapshots.
- `v1.1.0` (`feature/amanita-caesarea-branding`): *Amanita caesarea* logo & native icons and 3-stage animated opening splash.
- `v1.2.0` (`feature/trilingual-eu-es-en`): Full trilingual support (`EU` / `ES` / `EN`).
- `v1.3.0` (`feature/custom-caesarea-logo-and-2s-splash`): Illustrated *Amanita caesarea* logo on dark forest background and 2.0-second botanical animated splash.
- `v1.4.0` (`feature/settings-drawer-manual-outings`): Left slide-out drawer (`SettingsDrawer`), GPS-free manual and retrospective outings.
- `v1.5.0` (`feature/catalog-map-picker-filters-redesign`): Interactive mushroom placement from catalog, unified modal map filters & routes sheet, full-screen outing map (`LiveOutingMapScreen`) and 100% localized strings.
- `v1.5.1` (`feature/icon-and-minimap-fixes`): Full-bleed adaptive native icon on Android/iOS without white borders, real cartographic mini-map on outing cards and 4-tab bottom navigation (`Mushrooms`, `Map`, `Outings`, `Backup`).
- `v1.6.0` (`feature/gps-satellite-mushroom-search`): Pure satellite map layer (Esri World Imagery), GPS signal & accuracy acquisition (`GpsAcquisitionSheet`), reactive mushroom search (`MushroomSearchPicker`), upright marker rotation (`rotate: true`) and full rebranding to ZizAI.
- `v1.7.0` (`feature/map-gps-accuracy-manual-basket-background`): Radar GPS fix selector when saving spots on the map, manual outings redesigned as pure mycological baskets, background Foreground Service with persistent notification and drift-free stopwatch.
- `v1.7.1`: Interactive crosshair reticle (*diana*) and finger-tap spot placement mode on the map.
- `v1.7.2`: Map layer selector in outings, pure GPS route tracking, Android background GPS notification improvements, Drive `appDataFolder` scope at sign-in and catalog photo deduplication (252 unique real photos).

---

## 🚀 How to Run the Project

```bash
flutter pub get
flutter test
flutter run
```

To build an optimized release APK:
```bash
flutter build apk --release
```

To configure Google Cloud OAuth for your project (Android SHA-1 / iOS `REVERSED_CLIENT_ID`), see [`GOOGLE_SETUP.md`](GOOGLE_SETUP.md).

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPLv3)** with additional permissions under Section 7 for mobile app store distribution (Google Play / App Store).

- **Source Code**: Free software under [GNU GPLv3](LICENSE).
- **Brand & Logos**: The **ZizAI** name, brand typography and official logo are the exclusive property of Ander Iriondo and are reserved (any fork must use a different name and branding).
- **Photographic Content & Catalog**: Original photographs in `assets/images/mushrooms/` and descriptive profiles are copyright (C) 2026 Ander Iriondo for exclusive use within the application.
