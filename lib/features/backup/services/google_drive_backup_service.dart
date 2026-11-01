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
import '../../map/models/foraging_spot.dart';

class AuthBackupState {
  final bool isAuthenticatedWithGoogle;
  final bool isLocalMode;
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
      userEmail: userEmail ?? this.userEmail,
      userDisplayName: userDisplayName ?? this.userDisplayName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      lastDriveBackupDate: lastDriveBackupDate ?? this.lastDriveBackupDate,
      lastLocalBackupDate: lastLocalBackupDate ?? this.lastLocalBackupDate,
      isBusy: isBusy ?? this.isBusy,
      statusMessage: clearStatus ? null : (statusMessage ?? this.statusMessage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class GoogleDriveBackupService extends StateNotifier<AuthBackupState> {
  static const String _backupFileName = 'perretxikotan_backup.zip';
  static const String _prefLocalModeKey = 'perretxikotan_local_mode';
  static const String _prefLastDriveBackupKey = 'perretxikotan_last_drive_backup';
  static const String _prefLastLocalBackupKey = 'perretxikotan_last_local_backup';

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: <String>[
      drive.DriveApi.driveAppdataScope,
      'https://www.googleapis.com/auth/generative-language.retriever',
      'email',
    ],
  );

  GoogleDriveBackupService() : super(const AuthBackupState());

  Future<http.Client?> getAuthenticatedHttpClient() async {
    try {
      if (_googleSignIn.currentUser == null) {
        await _googleSignIn.signInSilently();
      }
      return await _googleSignIn.authenticatedClient();
    } catch (_) {
      return null;
    }
  }

  Future<void> initializeAuthSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLocalMode = prefs.getBool(_prefLocalModeKey) ?? false;
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
      lastDriveBackupDate: lastDrive,
      lastLocalBackupDate: lastLocal,
    );
  }

  Future<bool> signInWithGoogle() async {
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: 'Inicio de sesión con Google cancelado.',
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
        statusMessage: 'Cuenta de Google conectada correctamente.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage:
            'No se pudo conectar con Google Sign-In. Verifica tu conexión o la configuración OAuth (SHA-1 / Client ID en GOOGLE_SETUP.md) o continúa en modo local.',
      );
      return false;
    }
  }

  Future<void> continueInLocalMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLocalModeKey, true);
    state = state.copyWith(
      isLocalMode: true,
      clearError: true,
      statusMessage: 'Modo local activado (datos guardados en el dispositivo).',
    );
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefLocalModeKey, false);
    state = const AuthBackupState();
  }

  /// Empaqueta las ubicaciones, notas descriptivas y fotos en un archivo ZIP en memoria.
  static List<int> createBackupArchiveBytes(List<ForagingSpot> spots) {
    final archive = Archive();

    final spotsJsonList = spots.map((s) {
      final map = s.toMap();
      if (!kIsWeb &&
          s.photoPath != null &&
          s.photoPath!.isNotEmpty &&
          File(s.photoPath!).existsSync()) {
        final photoFileName = p.basename(s.photoPath!);
        map['archivedPhotoName'] = photoFileName;
        final photoBytes = File(s.photoPath!).readAsBytesSync();
        archive.addFile(
          ArchiveFile('photos/$photoFileName', photoBytes.length, photoBytes),
        );
      }
      return map;
    }).toList();

    final payload = {
      'app': 'Perretxikotan',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'spotsCount': spots.length,
      'spots': spotsJsonList,
    };

    final jsonBytes = utf8.encode(
      const JsonEncoder.withIndent('  ').convert(payload),
    );
    archive.addFile(ArchiveFile('spots.json', jsonBytes.length, jsonBytes));

    return ZipEncoder().encode(archive) ?? <int>[];
  }

  /// Desempaqueta un archivo ZIP de backup y restaura los puntos y fotos.
  static Future<List<ForagingSpot>> extractSpotsFromBackupBytes(
    List<int> zipBytes, {
    String? targetPhotosDirPath,
  }) async {
    final archive = ZipDecoder().decodeBytes(zipBytes);
    ArchiveFile? spotsJsonFile;

    for (final file in archive) {
      if (file.name == 'spots.json') {
        spotsJsonFile = file;
        break;
      }
    }

    if (spotsJsonFile == null) {
      throw const FormatException(
        'El archivo de copia de seguridad no contiene spots.json.',
      );
    }

    final contentStr = utf8.decode(spotsJsonFile.content as List<int>);
    final Map<String, dynamic> decoded =
        json.decode(contentStr) as Map<String, dynamic>;
    final List<dynamic> rawSpots =
        (decoded['spots'] as List<dynamic>?) ?? const [];

    String? photosDir = targetPhotosDirPath;
    if (photosDir == null && !kIsWeb) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final dir = Directory(p.join(appDir.path, 'spot_photos'));
        if (!dir.existsSync()) {
          await dir.create(recursive: true);
        }
        photosDir = dir.path;
      } catch (_) {}
    }

    final restoredSpots = <ForagingSpot>[];
    for (final item in rawSpots) {
      final map = Map<String, dynamic>.from(item as Map<String, dynamic>);
      final archivedPhotoName = map['archivedPhotoName'] as String?;
      if (archivedPhotoName != null && photosDir != null && !kIsWeb) {
        final photoArchiveEntry = archive.files
            .where((f) => f.name == 'photos/$archivedPhotoName')
            .firstOrNull;
        if (photoArchiveEntry != null) {
          final destPath = p.join(photosDir, archivedPhotoName);
          await File(destPath)
              .writeAsBytes(photoArchiveEntry.content as List<int>);
          map['photoPath'] = destPath;
        }
      }
      restoredSpots.add(ForagingSpot.fromMap(map));
    }

    return restoredSpots;
  }

  /// Sube el backup comprimido a la carpeta oculta `appDataFolder` del Google Drive personal del usuario.
  Future<bool> backupToGoogleDrive(List<ForagingSpot> spots) async {
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage:
              'Debes iniciar sesión con tu cuenta de Google para subir la copia a Google Drive.',
        );
        return false;
      }

      final driveApi = drive.DriveApi(httpClient);
      final zipBytes = createBackupArchiveBytes(spots);
      final media = drive.Media(
        Stream<List<int>>.value(zipBytes),
        zipBytes.length,
        contentType: 'application/zip',
      );

      // Comprobar si ya existe un backup previo en appDataFolder para actualizarlo
      final existingList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName' and trashed = false",
        $fields: 'files(id, name, modifiedTime)',
      );

      if (existingList.files != null && existingList.files!.isNotEmpty) {
        final fileId = existingList.files!.first.id!;
        final updateFile = drive.File()..name = _backupFileName;
        await driveApi.files.update(
          updateFile,
          fileId,
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
        lastDriveBackupDate: now,
        statusMessage:
            'Copia de seguridad guardada en tu Google Drive (${spots.length} ubicaciones).',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Error al subir copia a Google Drive: $e',
      );
      return false;
    }
  }

  /// Descarga y restaura el backup desde la carpeta `appDataFolder` de Google Drive.
  Future<List<ForagingSpot>?> restoreFromGoogleDrive() async {
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      final httpClient = await _googleSignIn.authenticatedClient();
      if (httpClient == null) {
        state = state.copyWith(
          isBusy: false,
          errorMessage:
              'Conecta primero tu cuenta de Google para restaurar desde Google Drive.',
        );
        return null;
      }

      final driveApi = drive.DriveApi(httpClient);
      final existingList = await driveApi.files.list(
        spaces: 'appDataFolder',
        q: "name = '$_backupFileName' and trashed = false",
        orderBy: 'modifiedTime desc',
        $fields: 'files(id, name, modifiedTime, size)',
      );

      if (existingList.files == null || existingList.files!.isEmpty) {
        state = state.copyWith(
          isBusy: false,
          errorMessage:
              'No se encontró ninguna copia de seguridad previa en tu Google Drive.',
        );
        return null;
      }

      final fileId = existingList.files!.first.id!;
      final mediaResponse = await driveApi.files.get(
        fileId,
        downloadOptions: drive.DownloadOptions.fullMedia,
      ) as drive.Media;

      final bytes = <int>[];
      await for (final chunk in mediaResponse.stream) {
        bytes.addAll(chunk);
      }

      final restored = await extractSpotsFromBackupBytes(bytes);
      state = state.copyWith(
        isBusy: false,
        statusMessage:
            'Se han restaurado ${restored.length} ubicaciones desde tu Google Drive.',
      );
      return restored;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Error al restaurar desde Google Drive: $e',
      );
      return null;
    }
  }

  /// Crea una copia de seguridad ZIP local en el almacenamiento de la app.
  Future<bool> saveLocalBackupSnapshot(List<ForagingSpot> spots) async {
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      final zipBytes = createBackupArchiveBytes(spots);
      final prefs = await SharedPreferences.getInstance();

      if (!kIsWeb) {
        final appDir = await getApplicationDocumentsDirectory();
        final backupFile = File(p.join(appDir.path, _backupFileName));
        await backupFile.writeAsBytes(zipBytes);
      } else {
        await prefs.setString(
          'perretxikotan_web_backup_b64',
          base64Encode(zipBytes),
        );
      }

      final now = DateTime.now();
      await prefs.setString(_prefLastLocalBackupKey, now.toIso8601String());

      state = state.copyWith(
        isBusy: false,
        lastLocalBackupDate: now,
        statusMessage:
            'Copia de seguridad local empaquetada correctamente (${spots.length} setales).',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Error al crear copia local: $e',
      );
      return false;
    }
  }

  /// Restaura la copia de seguridad ZIP local del dispositivo.
  Future<List<ForagingSpot>?> restoreFromLocalBackupSnapshot() async {
    state = state.copyWith(isBusy: true, clearError: true, clearStatus: true);
    try {
      List<int>? zipBytes;
      final prefs = await SharedPreferences.getInstance();

      if (!kIsWeb) {
        final appDir = await getApplicationDocumentsDirectory();
        final backupFile = File(p.join(appDir.path, _backupFileName));
        if (backupFile.existsSync()) {
          zipBytes = await backupFile.readAsBytes();
        }
      } else {
        final b64 = prefs.getString('perretxikotan_web_backup_b64');
        if (b64 != null) {
          zipBytes = base64Decode(b64);
        }
      }

      if (zipBytes == null || zipBytes.isEmpty) {
        state = state.copyWith(
          isBusy: false,
          errorMessage: 'Aún no hay ningún paquete de backup local guardado.',
        );
        return null;
      }

      final restored = await extractSpotsFromBackupBytes(zipBytes);
      state = state.copyWith(
        isBusy: false,
        statusMessage:
            'Restauradas ${restored.length} ubicaciones desde la copia local.',
      );
      return restored;
    } catch (e) {
      state = state.copyWith(
        isBusy: false,
        errorMessage: 'Error al restaurar copia local: $e',
      );
      return null;
    }
  }
}

final googleDriveBackupProvider =
    StateNotifierProvider<GoogleDriveBackupService, AuthBackupState>((ref) {
  return GoogleDriveBackupService();
});
