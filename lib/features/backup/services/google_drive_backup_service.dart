import 'dart:convert';
import 'dart:io';
import 'package:archive/archive.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../../ai_identifier/models/chat_message.dart';
import '../../ai_identifier/services/gemini_mushroom_service.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../map/data/spots_database.dart';
import '../../map/models/foraging_spot.dart';
import '../../map/services/offline_map_service.dart';
import '../../outings/data/outings_database.dart';
import '../../outings/models/foraging_outing.dart';

class FullBackupPayload {
  final List<ForagingSpot> spots;
  final List<ForagingOuting> outings;
  final List<String> favoriteIds;
  final List<AiChatMessage> aiMessages;
  final List<OfflineMapRegion> offlineRegions;

  const FullBackupPayload({
    required this.spots,
    this.outings = const <ForagingOuting>[],
    this.favoriteIds = const <String>[],
    this.aiMessages = const <AiChatMessage>[],
    this.offlineRegions = const <OfflineMapRegion>[],
  });
}

class AuthBackupState {
  final bool isAuthenticatedWithGoogle;
  final bool isLocalMode;
  final bool autoBackupEnabled;
  final String? userEmail;
  final String? userDisplayName;
  final String? userPhotoUrl;
  final DateTime? lastDriveBackupDate;
  final DateTime? lastLocalBackupDate;
  final bool isBusy;
  final String? statusMessage;
  final String? errorMessage;

  const AuthBackupState({
    this.isAuthenticatedWithGoogle = false,
    this.isLocalMode = false,
    this.autoBackupEnabled = true,
    this.userEmail,
    this.userDisplayName,
    this.userPhotoUrl,
    this.lastDriveBackupDate,
    this.lastLocalBackupDate,
    this.isBusy = false,
    this.statusMessage,
    this.errorMessage,
  });

  bool get hasEnteredApp => isAuthenticatedWithGoogle || isLocalMode;

  AuthBackupState copyWith({
    bool? isAuthenticatedWithGoogle,
    bool? isLocalMode,
    bool? autoBackupEnabled,
    String? userEmail,
    String? userDisplayName,
    String? userPhotoUrl,
    DateTime? lastDriveBackupDate,
    DateTime? lastLocalBackupDate,
    bool? isBusy,
    String? statusMessage,
    String? errorMessage,
    bool clearError = false,
    bool clearStatus = false,
  }) {
    return AuthBackupState(
      isAuthenticatedWithGoogle:
          isAuthenticatedWithGoogle ?? this.isAuthenticatedWithGoogle,
      isLocalMode: isLocalMode ?? this.isLocalMode,
      autoBackupEnabled: autoBackupEnabled ?? this.autoBackupEnabled,
      userEmail: userEmail ?? this.userEmail,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      lastDriveBackupDate: lastDriveBackupDate ?? this.lastDriveBackupDate,
      lastLocalBackupDate: lastLocalBackupDate ?? this.lastLocalBackupDate,
      isBusy: isBusy ?? this.isBusy,
      statusMessage:
          clearStatus ? null : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GoogleDriveBackupService extends StateNotifier<AuthBackupState> {
  static const String _backupFileName = 'zizai_backup.zip';
  static const String _prefLocalModeKey = 'zizai_local_mode';
  static const String _prefAutoBackupKey = 'zizai_auto_backup';
  static const String _prefLastDriveBackupKey =
      'zizai_last_drive_backup';
  static const String _prefLastLocalBackupKey =
      'zizai_last_local_backup';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      'email',
    ],
  );

  GoogleDriveBackupService() : super(const AuthBackupState());

  Future<http.Client?> getAuthenticatedHttpClient({
    bool requireDriveScope = false,
  }) async {
    try {
      if (_googleSignIn.currentUser == null) {
        await _googleSignIn.signInSilently();
      }
      if (requireDriveScope) {
        await _googleSignIn.requestScopes(<String>[
          drive.DriveApi.driveAppdataScope,
        ]);
      }
      return await _googleSignIn.authenticatedClient();
    } catch (_) {
      return null;
    }
  }

  Future<void> initializeAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocalMode = prefs.getBool(_prefLocalModeKey) ?? false;
    final savedAutoBackup = prefs.getBool(_prefAutoBackupKey) ?? true;
    final lastDriveStr = prefs.getString(_prefLastDriveBackupKey);
    final lastLocalStr = prefs.getString(_prefLastLocalBackupKey);

    final lastDrive =
        lastDriveStr != null ? DateTime.tryParse(lastDriveStr) : null;
    final lastLocal =
        lastLocalStr != null ? DateTime.tryParse(lastLocalStr) : null;

    try {
      final account = await _googleSignIn.signInSilently();
      if (account != null) {
        state = state.copyWith(
          isAuthenticatedWithGoogle: true,
          isLocalMode: false,
          autoBackupEnabled: savedAutoBackup,
          userEmail: account.email,
          userDisplayName: account.displayName ?? account.email,
          userPhotoUrl: account.photoUrl,
          lastDriveBackupDate: lastDrive,
          lastLocalBackupDate: lastLocal,
        );
        return;
      }
    } catch (_) {
      // Si no hay configuración OAuth aún o no hay red, continuamos con el estado local
    }

    state = state.copyWith(
      isAuthenticatedWithGoogle: false,
      isLocalMode: savedLocalMode,
      autoBackupEnabled: savedAutoBackup,
      lastDriveBackupDate: lastDrive,
      lastLocalBackupDate: lastLocal,
    );
  }

  Future<void> setAutoBackupEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefAutoBackupKey, enabled);
    state = state.copyWith(autoBackupEnabled: enabled);
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: 'Inicio de sesión con Google cancelado por el usuario.',
        );
        return false;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefLocalModeKey, false);

      state = state.copyWith(
        isBusy: false,
        isAuthenticatedWithGoogle: true,
        isLocalMode: false,
        userEmail: account.email,
        userDisplayName: account.displayName ?? account.email,
        userPhotoUrl: account.photoUrl,
        statusMessage:
            'Conectado como ${account.email} (Google Drive activo).',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage:
            'No se pudo completar el inicio de sesión con Google en este momento.',
      );
      return false;
    }
  }

  Future<void> continueInLocalMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLocalModeKey, true);
    state = state.copyWith(
      isLocalMode: true,
      isAuthenticatedWithGoogle: false,
      clearError: true,
      statusMessage: 'Modo local activado. Tus datos se guardan en el teléfono.',
    );
  }

  Future<void> signOut() async {
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLocalModeKey, false);
    state = const AuthBackupState();
  }

  /// Empaqueta toda la actividad del usuario en un archivo ZIP en memoria:
  /// - spots.json (ubicaciones del mapa global y salidas)
  /// - outings.json (salidas al monte con polilíneas GPS y tiempos)
  /// - favorites.json (especies favoritas del catálogo)
  /// - ai_chats.json (historial de identificaciones con IA Gemini)
  /// - offline_regions.json (regiones de mapa offline descargadas)
  /// - photos/ (fotografías tomadas en el mapa, salidas y chat IA)
  static Future<Uint8List> createBackupArchiveBytes(
    List<ForagingSpot> spots, {
    List<ForagingOuting> outings = const <ForagingOuting>[],
    List<String> favoriteIds = const <String>[],
    List<AiChatMessage> aiMessages = const <AiChatMessage>[],
    List<OfflineMapRegion> offlineRegions = const <OfflineMapRegion>[],
  }) async {
    final archive = Archive();
    final exportedSpotsJson = <Map<String, dynamic>>[];

    for (final spot in spots) {
      String? relativePhotoName;
      if (spot.photoPath != null &&
          spot.photoPath!.isNotEmpty &&
          !kIsWeb) {
        final photoFile = File(spot.photoPath!);
        if (await photoFile.exists()) {
          final fileName = p.basename(spot.photoPath!);
          relativePhotoName = 'photos/$fileName';
          final photoBytes = await photoFile.readAsBytes();
          archive.addFile(
            ArchiveFile(relativePhotoName, photoBytes.length, photoBytes),
          );
        }
      }

      final map = spot.toJson();
      map['photoRelativePath'] = relativePhotoName;
      exportedSpotsJson.add(map);
    }

    // Incluir también fotos de las consultas a la IA Gemini
    final exportedAiJson = <Map<String, dynamic>>[];
    for (final msg in aiMessages) {
      String? relativeAiPhoto;
      if (msg.imagePath != null &&
          msg.imagePath!.isNotEmpty &&
          !kIsWeb) {
        final photoFile = File(msg.imagePath!);
        if (await photoFile.exists()) {
          final fileName = p.basename(msg.imagePath!);
          relativeAiPhoto = 'photos/$fileName';
          final alreadyAdded =
              archive.files.any((f) => f.name == relativeAiPhoto);
          if (!alreadyAdded) {
            final photoBytes = await photoFile.readAsBytes();
            archive.addFile(
              ArchiveFile(relativeAiPhoto, photoBytes.length, photoBytes),
            );
          }
        }
      }
      final map = msg.toJson();
      map['imageRelativePath'] = relativeAiPhoto;
      exportedAiJson.add(map);
    }

    void addJsonFileToArchive(String fileName, Object payload) {
      final bytes =
          utf8.encode(const JsonEncoder.withIndent('  ').convert(payload));
      archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
    }

    addJsonFileToArchive('spots.json', {
      'version': 2,
      'exportedAt': DateTime.now().toIso8601String(),
      'spots': exportedSpotsJson,
    });

    addJsonFileToArchive('outings.json', {
      'version': 2,
      'outings': outings.map((o) => o.toJson()).toList(),
    });

    addJsonFileToArchive('favorites.json', {
      'version': 2,
      'favoriteIds': favoriteIds,
    });

    addJsonFileToArchive('ai_chats.json', {
      'version': 2,
      'messages': exportedAiJson,
    });

    addJsonFileToArchive('offline_regions.json', {
      'version': 2,
      'regions': offlineRegions.map((r) => r.toJson()).toList(),
    });

    final encodedZip = ZipEncoder().encode(archive);
    return Uint8List.fromList(encodedZip);
  }

  /// Extrae un paquete ZIP completo con toda la actividad del usuario y restaura las fotos en disco.
  static Future<FullBackupPayload> extractFullActivityBackupBytes(
    Uint8List zipBytes, {
    Directory? customPhotosParentDir,
  }) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    Directory? photosDir;

    if (!kIsWeb) {
      final baseDir =
          customPhotosParentDir ?? await getApplicationDocumentsDirectory();
      photosDir = Directory(p.join(baseDir.path, 'photos'));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }
    }

    final restoredPhotosMap = <String, String>{};
    ArchiveFile? spotsJsonFile;
    ArchiveFile? outingsJsonFile;
    ArchiveFile? favoritesJsonFile;
    ArchiveFile? aiChatsJsonFile;
    ArchiveFile? offlineRegionsJsonFile;

    for (final file in archive) {
      if (!file.isFile) continue;
      if (file.name == 'spots.json') {
        spotsJsonFile = file;
      } else if (file.name == 'outings.json') {
        outingsJsonFile = file;
      } else if (file.name == 'favorites.json') {
        favoritesJsonFile = file;
      } else if (file.name == 'ai_chats.json') {
        aiChatsJsonFile = file;
      } else if (file.name == 'offline_regions.json') {
        offlineRegionsJsonFile = file;
      } else if (file.name.startsWith('photos/') && photosDir != null) {
        final fileName = p.basename(file.name);
        final destFile = File(p.join(photosDir.path, fileName));
        final contentBytes = file.content as List<int>;
        await destFile.writeAsBytes(contentBytes, flush: true);
        restoredPhotosMap[file.name] = destFile.path;
      }
    }

    final restoredSpots = <ForagingSpot>[];
    if (spotsJsonFile != null) {
      final jsonStr = utf8.decode(spotsJsonFile.content as List<int>);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      final rawSpots =
          decoded['spots'] as List<dynamic>? ?? const <dynamic>[];
      for (final raw in rawSpots) {
        final map = Map<String, dynamic>.from(raw as Map);
        final relPath = map['photoRelativePath'] as String?;
        if (relPath != null && restoredPhotosMap.containsKey(relPath)) {
          map['photoPath'] = restoredPhotosMap[relPath];
        }
        restoredSpots.add(ForagingSpot.fromJson(map));
      }
    }

    final restoredOutings = <ForagingOuting>[];
    if (outingsJsonFile != null) {
      final jsonStr = utf8.decode(outingsJsonFile.content as List<int>);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      final rawOutings =
          decoded['outings'] as List<dynamic>? ?? const <dynamic>[];
      for (final raw in rawOutings) {
        restoredOutings
            .add(ForagingOuting.fromJson(Map<String, dynamic>.from(raw as Map)));
      }
    }

    final restoredFavorites = <String>[];
    if (favoritesJsonFile != null) {
      final jsonStr = utf8.decode(favoritesJsonFile.content as List<int>);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      final rawFavs =
          decoded['favoriteIds'] as List<dynamic>? ?? const <dynamic>[];
      restoredFavorites.addAll(rawFavs.map((e) => e.toString()));
    }

    final restoredAiChats = <AiChatMessage>[];
    if (aiChatsJsonFile != null) {
      final jsonStr = utf8.decode(aiChatsJsonFile.content as List<int>);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      final rawMsgs =
          decoded['messages'] as List<dynamic>? ?? const <dynamic>[];
      for (final raw in rawMsgs) {
        final map = Map<String, dynamic>.from(raw as Map);
        final relPath = map['imageRelativePath'] as String?;
        if (relPath != null && restoredPhotosMap.containsKey(relPath)) {
          map['imagePath'] = restoredPhotosMap[relPath];
        }
        restoredAiChats.add(AiChatMessage.fromJson(map));
      }
    }

    final restoredRegions = <OfflineMapRegion>[];
    if (offlineRegionsJsonFile != null) {
      final jsonStr = utf8.decode(offlineRegionsJsonFile.content as List<int>);
      final decoded = json.decode(jsonStr) as Map<String, dynamic>;
      final rawRegions =
          decoded['regions'] as List<dynamic>? ?? const <dynamic>[];
      for (final raw in rawRegions) {
        restoredRegions.add(
          OfflineMapRegion.fromJson(Map<String, dynamic>.from(raw as Map)),
        );
      }
    }

    return FullBackupPayload(
      spots: restoredSpots,
      outings: restoredOutings,
      favoriteIds: restoredFavorites,
      aiMessages: restoredAiChats,
      offlineRegions: restoredRegions,
    );
  }

  /// Compatibilidad directa para extraer únicamente la lista de ForagingSpot.
  static Future<List<ForagingSpot>> extractBackupArchiveBytes(
    Uint8List zipBytes, {
    Directory? customPhotosParentDir,
  }) async {
    final full = await extractFullActivityBackupBytes(
      zipBytes,
      customPhotosParentDir: customPhotosParentDir,
    );
    return full.spots;
  }

  /// Respalda toda la actividad del usuario en su cuenta personal de Google Drive (appDataFolder).
  Future<bool> backupAllActivityToGoogleDrive({
    required List<ForagingSpot> spots,
    required List<ForagingOuting> outings,
    required List<String> favoriteIds,
    required List<AiChatMessage> aiMessages,
    required List<OfflineMapRegion> offlineRegions,
    AppLanguage lang = AppLanguage.es,
  }) async {
    final s = AppStrings(lang);
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      var account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();

      if (account == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: s.tr(
            eu: 'Hasi saioa Google kontuarekin kopia Google Drive-ra igotzeko.',
            es: 'Debes iniciar sesión con tu cuenta de Google para subir el backup a Google Drive.',
            en: 'Sign in to Google to upload backup to Google Drive.',
          ),
        );
        return false;
      }

      await _googleSignIn.requestScopes(<String>[
        drive.DriveApi.driveAppdataScope,
      ]);
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: s.tr(
            eu: 'Ezin izan da Google Drive-ko bezero autentifikatua lortu.',
            es: 'No se pudo obtener el cliente autenticado de Google Drive.',
            en: 'Could not obtain authenticated Google Drive client.',
          ),
        );
        return false;
      }

      final driveApi = drive.DriveApi(httpClient);
      final zipBytes = await createBackupArchiveBytes(
        spots,
        outings: outings,
        favoriteIds: favoriteIds,
        aiMessages: aiMessages,
        offlineRegions: offlineRegions,
      );

      // También guardamos copia espejo local automática
      await _writeLocalMirrorZip(zipBytes);

      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName' and trashed = false",
        $fields: 'files(id, name, modifiedTime)',
      );

      final media = drive.Media(
        Stream<List<int>>.value(zipBytes),
        zipBytes.length,
      );

      if (fileList.files != null && fileList.files!.isNotEmpty) {
        final existingFileId = fileList.files!.first.id!;
        await driveApi.files.update(
          drive.File()..name = _backupFileName,
          existingFileId,
          uploadMedia: media,
        );
      } else {
        final driveFile = drive.File()
          ..name = _backupFileName
          ..parents = <String>['appDataFolder'];
        await driveApi.files.create(
          driveFile,
          uploadMedia: media,
        );
      }

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastDriveBackupKey, now.toIso8601String());

      state = state.copyWith(
        isBusy: false,
        isAuthenticatedWithGoogle: true,
        userEmail: account.email,
        userDisplayName: account.displayName ?? account.email,
        userPhotoUrl: account.photoUrl,
        lastDriveBackupDate: now,
        statusMessage: s.tr(
          eu: 'Kopia osoa Google Drive-n gorde da (${spots.length} perretxiko-leku, ${outings.length} irteera, ${favoriteIds.length} gogoko).',
          es: 'Copia integral guardada en Google Drive (${spots.length} setales, ${outings.length} salidas, ${favoriteIds.length} favoritos).',
          en: 'Full backup saved to Google Drive (${spots.length} spots, ${outings.length} outings, ${favoriteIds.length} favorites).',
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: s.tr(
          eu: 'Ezin izan da une honetan Google Drive-rekin sinkronizatu. Gailuko tokiko kopia ere erabilgarri duzu.',
          es: 'No se pudo sincronizar con Google Drive en este momento. También tienes disponible la copia local en tu dispositivo.',
          en: 'Could not sync with Google Drive right now. Local backup on your device is also available.',
        ),
      );
      return false;
    }
  }

  /// Restaura toda la actividad desde Google Drive (appDataFolder).
  Future<FullBackupPayload?> restoreFullActivityFromGoogleDrive({
    AppLanguage lang = AppLanguage.es,
  }) async {
    final s = AppStrings(lang);
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      var account = _googleSignIn.currentUser;
      account ??= await _googleSignIn.signInSilently();
      account ??= await _googleSignIn.signIn();

      if (account == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: s.tr(
            eu: 'Hasi saioa Google-n zure Google Drive-n segurtasun-kopiak bilatzeko.',
            es: 'Inicia sesión en Google para buscar copias de seguridad en tu Google Drive.',
            en: 'Sign in to Google to search for backups in your Google Drive.',
          ),
        );
        return null;
      }

      await _googleSignIn.requestScopes(<String>[
        drive.DriveApi.driveAppdataScope,
      ]);
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: s.tr(
            eu: 'Ezin izan da Google Drive-rekin autentifikatu.',
            es: 'No se pudo autenticar con Google Drive.',
            en: 'Could not authenticate with Google Drive.',
          ),
        );
        return null;
      }

      final driveApi = drive.DriveApi(httpClient);
      final fileList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName' and trashed = false",
        $fields: 'files(id, name, modifiedTime)',
      );

      if (fileList.files == null || fileList.files!.isEmpty) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: s.tr(
            eu: 'Ez da aldez aurreko kopiarik aurkitu ($_backupFileName) zure Google Drive kontuan.',
            es: 'No se encontró ninguna copia previa ($_backupFileName) en tu cuenta de Google Drive.',
            en: 'No prior backup ($_backupFileName) found in your Google Drive account.',
          ),
        );
        return null;
      }

      final fileId = fileList.files!.first.id!;
      final mediaResponse = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final chunks = <int>[];
      await for (final chunk in mediaResponse.stream) {
        chunks.addAll(chunk);
      }

      final payload = await extractFullActivityBackupBytes(
        Uint8List.fromList(chunks),
      );

      state = state.copyWith(
        isBusy: false,
        statusMessage: s.tr(
          eu: 'Google Drive-tik leheneratzea osatu da (${payload.spots.length} perretxiko-leku, ${payload.outings.length} irteera, ${payload.favoriteIds.length} gogoko).',
          es: 'Restauración completada desde Google Drive (${payload.spots.length} setales, ${payload.outings.length} salidas, ${payload.favoriteIds.length} favoritos).',
          en: 'Restoration completed from Google Drive (${payload.spots.length} spots, ${payload.outings.length} outings, ${payload.favoriteIds.length} favorites).',
        ),
      );
      return payload;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: s.tr(
          eu: 'Ezin izan da backup-a Google Drive-tik deskargatu. Tokiko Snapshot-etik lehenera dezakezu.',
          es: 'No se pudo descargar el backup desde Google Drive. Puedes restaurar desde tu Snapshot Local.',
          en: 'Could not download backup from Google Drive. You can restore from your Local Snapshot.',
        ),
      );
      return null;
    }
  }

  Future<void> _writeLocalMirrorZip(Uint8List zipBytes) async {
    if (kIsWeb) return;
    final docsDir = await getApplicationDocumentsDirectory();
    final backupFile = File(p.join(docsDir.path, _backupFileName));
    await backupFile.writeAsBytes(zipBytes, flush: true);
  }

  /// Guarda una instantánea ZIP local completa en el almacenamiento del dispositivo.
  Future<bool> saveLocalSnapshotAllActivity({
    required List<ForagingSpot> spots,
    required List<ForagingOuting> outings,
    required List<String> favoriteIds,
    required List<AiChatMessage> aiMessages,
    required List<OfflineMapRegion> offlineRegions,
    AppLanguage lang = AppLanguage.es,
  }) async {
    final s = AppStrings(lang);
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      final zipBytes = await createBackupArchiveBytes(
        spots,
        outings: outings,
        favoriteIds: favoriteIds,
        aiMessages: aiMessages,
        offlineRegions: offlineRegions,
      );
      await _writeLocalMirrorZip(zipBytes);

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLastLocalBackupKey, now.toIso8601String());

      state = state.copyWith(
        isBusy: false,
        lastLocalBackupDate: now,
        statusMessage: s.tr(
          eu: 'ZIP snapshot osoa gailuan gorde da (${spots.length} perretxiko-leku, ${outings.length} irteera, ${favoriteIds.length} gogoko).',
          es: 'Snapshot ZIP completo guardado en el dispositivo (${spots.length} setales, ${outings.length} salidas, ${favoriteIds.length} favoritos).',
          en: 'Full ZIP snapshot saved on device (${spots.length} spots, ${outings.length} outings, ${favoriteIds.length} favorites).',
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: s.tr(
          eu: 'Errorea tokiko kopia sortzean: $e',
          es: 'Error al crear la copia local: $e',
          en: 'Error creating local backup: $e',
        ),
      );
      return false;
    }
  }

  /// Restaura toda la actividad desde la instantánea ZIP local del dispositivo.
  Future<FullBackupPayload?> restoreFromLocalSnapshotFullActivity({
    AppLanguage lang = AppLanguage.es,
  }) async {
    final s = AppStrings(lang);
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      if (kIsWeb) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: s.tr(
            eu: 'Fitxategi lokaletik leheneratzeko gailu mugikorra behar da.',
            es: 'La restauración desde archivo local requiere móvil.',
            en: 'Restoring from local file requires a mobile device.',
          ),
        );
        return null;
      }
      final docsDir = await getApplicationDocumentsDirectory();
      final backupFile = File(p.join(docsDir.path, _backupFileName));
      if (!await backupFile.exists()) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: s.tr(
            eu: 'Ez dago oraindik tokiko kopia fitxategirik ($_backupFileName).',
            es: 'Aún no existe ningún archivo de copia local ($_backupFileName).',
            en: 'No local backup file ($_backupFileName) exists yet.',
          ),
        );
        return null;
      }

      final zipBytes = await backupFile.readAsBytes();
      final payload = await extractFullActivityBackupBytes(zipBytes);
      state = state.copyWith(
        isBusy: false,
        statusMessage: s.tr(
          eu: '${payload.spots.length} perretxiko-leku eta ${payload.outings.length} irteera leheneratu dira tokiko kopiatik.',
          es: 'Se han restaurado ${payload.spots.length} setales y ${payload.outings.length} salidas desde la copia local.',
          en: 'Restored ${payload.spots.length} spots and ${payload.outings.length} outings from local backup.',
        ),
      );
      return payload;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: s.tr(
          eu: 'Errorea tokiko kopia leheneratzean: $e',
          es: 'Error al restaurar la copia local: $e',
          en: 'Error restoring local backup: $e',
        ),
      );
      return null;
    }
  }

  /// Aplica el payload restaurado a todos los repositorios de la app usando Fusión Inteligente (por defecto) o Reemplazo Total.
  Future<void> applyRestoredPayloadToApp(
    WidgetRef ref,
    FullBackupPayload payload, {
    required bool smartMerge,
  }) async {
    if (smartMerge) {
      await ref.read(foragingSpotsProvider.notifier).mergeSpots(payload.spots);
      await ref.read(outingsProvider.notifier).mergeOutings(payload.outings);
      await ref
          .read(favoriteMushroomIdsProvider.notifier)
          .mergeFavorites(payload.favoriteIds);
      await ref
          .read(geminiMushroomProvider.notifier)
          .mergeMessages(payload.aiMessages);
      await ref
          .read(offlineMapServiceProvider.notifier)
          .mergeRegions(payload.offlineRegions);
    } else {
      await ref
          .read(foragingSpotsProvider.notifier)
          .replaceAllSpots(payload.spots);
      await ref
          .read(outingsProvider.notifier)
          .replaceAllOutings(payload.outings);
      await ref
          .read(favoriteMushroomIdsProvider.notifier)
          .replaceAllFavorites(payload.favoriteIds);
      await ref
          .read(geminiMushroomProvider.notifier)
          .replaceAllMessages(payload.aiMessages);
      await ref
          .read(offlineMapServiceProvider.notifier)
          .replaceAllRegions(payload.offlineRegions);
    }
  }
}

final googleDriveBackupProvider =
    StateNotifierProvider<GoogleDriveBackupService, AuthBackupState>((ref) {
  return GoogleDriveBackupService();
});
