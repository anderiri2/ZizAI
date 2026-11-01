# Perretxikotan 🍄🍂

Aplicación móvil multiplataforma (**Android e iOS**) desarrollada en **Flutter** para los aficionados a la recolección de setas en el **País Vasco (Euskadi) y España**.

---

## Características Principales

1. **Catálogo Micológico Extenso 100 % Offline (126 especies)**:
   - Ordenación alfabética (**A–Z**) intercambiable por **Nombre en Castellano**, **Nombre en Euskera** o **Nombre Científico**.
   - Búsqueda instantánea y filtros rápidos (*Excelentes*, *Comestibles*, *Precaución*, *Tóxicas / Mortales*, *Otoño*, *Primavera*, *Favoritas*).
   - Ficha detallada con fotografías reales empaquetadas para uso sin cobertura en el monte, nivel de comestibilidad en 6 niveles, hábitat, época de fructificación, morfología detallada (*Sombrero / Txapela*, *Himenio*, *Pie / Hanka*, *Carne y Olor*) y **Confusiones Habituales** con navegación directa a la especie confusa.
   - Aviso de seguridad micológica integrado en el primer arranque y en cada ficha.

2. **Mapa Topográfico de Setales y Notas Descriptivas (`flutter_map`)**:
   - Cartografía **OpenTopoMap** (con curvas de nivel para monte) y **OpenStreetMap** estándar.
   - Guardado de ubicaciones por **GPS** o manteniendo pulsado cualquier punto del mapa.
   - Asociación de **nota descriptiva**, **seta del catálogo**, fecha del hallazgo y fotografía opcional.

3. **Arquitectura Standalone (Sin Servidor) + Backup en Google Drive (Estilo WhatsApp)**:
   - Persistencia local en **SQLite (`sqflite`)** + copias de seguridad comprimidas en `.zip` (`perretxikotan_backup.zip`) dentro de la carpeta privada de aplicación (`appDataFolder`) del **Google Drive personal** del usuario.
   - Incluye también modo local sin conexión e instantáneas ZIP locales.

4. **Diseño Otoñal y Barra Inferior Translúcida (*Glassmorphism*)**:
   - Paleta inspirada en los colores del otoño (*Marrón Boletus*, *Ocre Ziza Horia*, *Terracota Esnegorri*, *Verde Musgo* y *Pergamino Cálido*).
   - Splash Screen animado con logo emblema propio, pantalla de Login con Google / Modo local y barra de navegación inferior con desenfoque (`BackdropFilter`).

---

## Estructura del Proyecto

```text
lib/
├── main.dart
├── core/
│   ├── theme/autumn_theme.dart
│   └── widgets/
│       ├── safety_disclaimer_banner.dart
│       └── translucent_bottom_nav.dart
└── features/
    ├── auth/presentation/
    │   ├── splash_screen.dart
    │   └── login_screen.dart
    ├── catalog/
    │   ├── models/mushroom.dart
    │   ├── data/catalog_repository.dart
    │   └── presentation/
    │       ├── catalog_screen.dart
    │       └── mushroom_detail_screen.dart
    ├── map/
    │   ├── models/foraging_spot.dart
    │   ├── data/spots_database.dart
    │   └── presentation/map_screen.dart
    ├── backup/
    │   ├── services/google_drive_backup_service.dart
    │   └── presentation/backup_screen.dart
    └── home/presentation/home_shell_screen.dart
```

---

## Puesta en Marcha

1. Generar las carpetas nativas de plataforma (si es la primera vez tras clonar) y descargar dependencias:
   ```bash
   flutter create --org com.perretxikotan --project-name perretxikotan .
   flutter pub get
   ```
2. Ejecutar las pruebas automatizadas de integridad del catálogo y sistema de backup:
   ```bash
   flutter test
   ```
3. Ejecutar la aplicación en un emulador Android, simulador iOS o dispositivo físico:
   ```bash
   flutter run
   ```
4. *(Opcional)* Para regenerar o ampliar el catálogo micológico y sus fotografías offline:
   ```bash
   python3 tool/generate_catalog.py
   ```
5. Consulta [GOOGLE_SETUP.md](GOOGLE_SETUP.md) para registrar las credenciales OAuth 2.0 en Google Cloud Console cuando quieras utilizar el backup de Google Drive en tu dispositivo real.
