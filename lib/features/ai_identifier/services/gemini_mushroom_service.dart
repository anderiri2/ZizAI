import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../backup/services/google_drive_backup_service.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../models/chat_message.dart';

class AiIdentifierState {
  final List<AiChatMessage> messages;
  final bool isThinking;
  final String? selectedImagePath;

  const AiIdentifierState({
    this.messages = const <AiChatMessage>[],
    this.isThinking = false,
    this.selectedImagePath,
  });

  int get pendingSyncCount =>
      messages.where((m) => m.isUser && m.isPendingSync).length;

  AiIdentifierState copyWith({
    List<AiChatMessage>? messages,
    bool? isThinking,
    String? selectedImagePath,
    bool clearSelectedImage = false,
  }) {
    return AiIdentifierState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      selectedImagePath: clearSelectedImage
          ? null
          : (selectedImagePath ?? this.selectedImagePath),
    );
  }
}

class GeminiMushroomNotifier extends StateNotifier<AiIdentifierState> {
  static const String _storageKey = 'zizai_ai_chats_v1';
  final Ref _ref;

  GeminiMushroomNotifier(this._ref) : super(const AiIdentifierState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null || raw.isEmpty) {
      state = state.copyWith(
        messages: [
          AiChatMessage(
            id: 'welcome_msg',
            isUser: false,
            createdAt: DateTime.now(),
            text:
                'Kaixo! Soy el asistente micológico de **ZizAI** conectado con **Gemini** mediante tu cuenta de Google.\n\n'
                '• Puedes **sacar una foto** del ejemplar (sombrero, láminas/poros y base del pie) o describir su hábitat y olor.\n'
                '• Si estás en el monte **sin cobertura**, guardaré tu foto como *Pendiente de conexión* para analizarla con Gemini al regresar y te daré al instante una orientación morfológica con las 126 especies del catálogo local.\n'
                '• Recuerda: ninguna identificación por foto sustituye la revisión presencial de una sociedad micológica.',
          ),
        ],
      );
      return;
    }
    try {
      final decoded = json.decode(raw) as List<dynamic>;
      final loaded = decoded
          .map((e) => AiChatMessage.fromJson(e as Map<String, dynamic>))
          .toList();
      state = state.copyWith(messages: loaded);
    } catch (_) {}
  }

  Future<void> _persistMessages(List<AiChatMessage> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      json.encode(list.map((e) => e.toJson()).toList()),
    );
  }

  void attachImage(String? path) {
    state = state.copyWith(
      selectedImagePath: path,
      clearSelectedImage: path == null,
    );
  }

  Future<void> clearConversation() async {
    final welcome = AiChatMessage(
      id: 'welcome_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      createdAt: DateTime.now(),
      text:
          'Conversación reiniciada. Sube una foto de la seta o describe sus características (sombrero, himenio, pie, hábitat) para ayudarte a identificarla.',
    );
    state = AiIdentifierState(messages: [welcome]);
    await _persistMessages([welcome]);
  }

  Future<void> replaceAllMessages(List<AiChatMessage> messages) async {
    state = state.copyWith(messages: messages);
    await _persistMessages(messages);
  }

  Future<void> mergeMessages(List<AiChatMessage> incoming) async {
    final byId = <String, AiChatMessage>{
      for (final m in state.messages) m.id: m,
    };
    for (final m in incoming) {
      byId[m.id] = m;
    }
    final merged = byId.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    state = state.copyWith(messages: merged);
    await _persistMessages(merged);
  }

  Future<void> sendQuestion(String rawQuestion) async {
    final trimmed = rawQuestion.trim();
    final imagePath = state.selectedImagePath;
    if (trimmed.isEmpty && imagePath == null) return;

    final userPrompt = trimmed.isEmpty
        ? '¿Qué especie micológica puede ser el ejemplar de esta fotografía y con qué especies tóxicas podría confundirse?'
        : trimmed;

    final userMsg = AiChatMessage(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      isUser: true,
      text: userPrompt,
      createdAt: DateTime.now(),
      imagePath: imagePath,
    );

    final updatedWithUser = [...state.messages, userMsg];
    state = state.copyWith(
      messages: updatedWithUser,
      isThinking: true,
      clearSelectedImage: true,
    );
    await _persistMessages(updatedWithUser);

    final catalog =
        await _ref.read(allMushroomsProvider.future).catchError((_) => <Mushroom>[]);

    // 1. Intentar llamada multimodal a Gemini usando la sesión OAuth de Google del usuario
    String? geminiReply;
    try {
      geminiReply = await _callGeminiWithGoogleOAuth(
        prompt: userPrompt,
        imagePath: imagePath,
        catalog: catalog,
      );
    } catch (_) {
      geminiReply = null;
    }

    final bool wasOfflineFallback = geminiReply == null;
    final String finalReply = geminiReply ??
        _buildOfflineExpertResponse(
          prompt: userPrompt,
          hasPhoto: imagePath != null,
          catalog: catalog,
        );

    final matchedIds = _extractMatchedCatalogIds(
      prompt: userPrompt,
      reply: finalReply,
      catalog: catalog,
    );

    // Si falló por falta de cobertura o sesión, marcamos el mensaje del usuario como pendiente de sincronizar con Gemini
    final updatedMessages = state.messages.map((m) {
      if (m.id == userMsg.id && wasOfflineFallback) {
        return m.copyWith(isPendingSync: true);
      }
      return m;
    }).toList();

    final aiMsg = AiChatMessage(
      id: 'ai_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      text: finalReply,
      createdAt: DateTime.now(),
      matchedMushroomIds: matchedIds,
    );

    final finalHistory = [...updatedMessages, aiMsg];
    state = state.copyWith(
      messages: finalHistory,
      isThinking: false,
    );
    await _persistMessages(finalHistory);
  }

  /// Permite reintentar con Gemini una consulta con foto que quedó pendiente cuando el usuario estaba sin cobertura en el monte.
  Future<void> retryPendingWithGemini(String userMessageId) async {
    final targetUserMsg =
        state.messages.where((m) => m.id == userMessageId).firstOrNull;
    if (targetUserMsg == null || state.isThinking) return;

    state = state.copyWith(isThinking: true);

    final catalog =
        await _ref.read(allMushroomsProvider.future).catchError((_) => <Mushroom>[]);

    String? geminiReply;
    try {
      geminiReply = await _callGeminiWithGoogleOAuth(
        prompt: targetUserMsg.text,
        imagePath: targetUserMsg.imagePath,
        catalog: catalog,
      );
    } catch (_) {
      geminiReply = null;
    }

    if (geminiReply == null) {
      state = state.copyWith(isThinking: false);
      return;
    }

    final matchedIds = _extractMatchedCatalogIds(
      prompt: targetUserMsg.text,
      reply: geminiReply,
      catalog: catalog,
    );

    final updatedList = state.messages.map((m) {
      if (m.id == userMessageId) {
        return m.copyWith(isPendingSync: false);
      }
      return m;
    }).toList();

    final aiMsg = AiChatMessage(
      id: 'ai_retry_${DateTime.now().millisecondsSinceEpoch}',
      isUser: false,
      text: '✨ **Análisis con Gemini completado (conexión recuperada):**\n\n$geminiReply',
      createdAt: DateTime.now(),
      matchedMushroomIds: matchedIds,
    );

    final finalHistory = [...updatedList, aiMsg];
    state = state.copyWith(
      messages: finalHistory,
      isThinking: false,
    );
    await _persistMessages(finalHistory);
  }

  Future<String?> _callGeminiWithGoogleOAuth({
    required String prompt,
    required String? imagePath,
    required List<Mushroom> catalog,
  }) async {
    final authService = _ref.read(googleDriveBackupProvider.notifier);
    final client = await authService.getAuthenticatedHttpClient();
    if (client == null) return null;

    try {
      final catalogSummary = catalog
          .take(65)
          .map((m) =>
              '${m.id}: ${m.commonNameEs} / ${m.nameEu} (${m.scientificName}) [${m.edibility.labelEs}]')
          .join('; ');

      final systemInstruction =
          'Eres un experto micólogo integrado en la app ZizAI. '
          'Responde en español claro, estructurado y riguroso. '
          '1) Propón las especies candidatas indicando nombre común en castellano, nombre en euskera y nombre científico. '
          '2) Detalla rasgos clave de sombrero (txapela), himenio (láminas/poros/pliegues), pie (hanka) y hábitat. '
          '3) Advierte SIEMPRE sobre posibles confusiones tóxicas o mortales y recuerda no consumir ningún ejemplar sin verificación presencial. '
          'Especies de referencia en el catálogo de la app: $catalogSummary';

      final parts = <Map<String, dynamic>>[
        {'text': '$systemInstruction\n\nConsulta del recolector: $prompt'},
      ];

      if (imagePath != null && !kIsWeb) {
        final file = File(imagePath);
        if (await file.exists()) {
          final bytes = await file.readAsBytes();
          final base64Image = base64Encode(bytes);
          parts.add({
            'inline_data': {
              'mime_type': 'image/jpeg',
              'data': base64Image,
            },
          });
        }
      }

      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent',
      );

      final response = await client
          .post(
            uri,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'contents': [
                {'parts': parts},
              ],
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;
        final candidates = decoded['candidates'] as List<dynamic>?;
        if (candidates != null && candidates.isNotEmpty) {
          final content =
              candidates.first['content'] as Map<String, dynamic>?;
          final resParts = content?['parts'] as List<dynamic>?;
          if (resParts != null && resParts.isNotEmpty) {
            final text = resParts.first['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      }
    } finally {
      client.close();
    }
    return null;
  }

  String _buildOfflineExpertResponse({
    required String prompt,
    required bool hasPhoto,
    required List<Mushroom> catalog,
  }) {
    final q = prompt.toLowerCase();
    final matched = catalog.where((m) {
      return m.commonNameEs.toLowerCase().contains(q) ||
          m.nameEu.toLowerCase().contains(q) ||
          m.scientificName.toLowerCase().contains(q) ||
          q.split(RegExp(r'\s+')).any((word) =>
              word.length >= 4 &&
              (m.commonNameEs.toLowerCase().contains(word) ||
                  m.nameEu.toLowerCase().contains(word) ||
                  m.scientificName.toLowerCase().contains(word) ||
                  m.capDescription.toLowerCase().contains(word) ||
                  m.hymeniumDescription.toLowerCase().contains(word) ||
                  m.habitat.toLowerCase().contains(word)));
    }).take(3).toList();

    final candidates = matched.isNotEmpty
        ? matched
        : catalog.take(3).toList();

    final buffer = StringBuffer();
    if (hasPhoto) {
      buffer.writeln(
        '🌲 **Consulta guardada como Pendiente de Conexión:** He almacenado tu fotografía para enviarla a **Gemini** en cuanto recuperes cobertura o inicies sesión con Google (puedes pulsar *"Reintentar con Gemini"* sobre tu mensaje).\n',
      );
    } else {
      buffer.writeln(
        '🌲 **Asistente Micológico Local (Modo Sin Cobertura / Sin conexión a Gemini):**\n',
      );
    }

    buffer.writeln(
      'Mientras tanto, según el análisis local sobre las **${catalog.length} especies** del catálogo de **ZizAI**, revisa estas especies y sus posibles confusiones:',
    );

    for (final m in candidates) {
      buffer.writeln(
        '\n• **${m.commonNameEs} / ${m.nameEu}** (*${m.scientificName}*) — **${m.edibility.labelEs}**\n'
        '  - *Sombrero:* ${m.capDescription}\n'
        '  - *Himenio:* ${m.hymeniumDescription}\n'
        '  - *Hábitat:* ${m.habitat}',
      );
      if (m.confusions.isNotEmpty) {
        final confNames = m.confusions
            .map((c) => '${c.speciesName} (${c.edibilityWarning})')
            .join(', ');
        buffer.writeln('  - ⚠️ *Confusiones habituales:* $confNames');
      }
    }

    buffer.writeln(
      '\n⚠️ **Aviso de seguridad:** Nunca consumas una seta basándote únicamente en fotografías o análisis automatizados. Consulta siempre en una sociedad micológica.',
    );
    return buffer.toString();
  }

  List<String> _extractMatchedCatalogIds({
    required String prompt,
    required String reply,
    required List<Mushroom> catalog,
  }) {
    final combined = '${prompt.toLowerCase()} ${reply.toLowerCase()}';
    final matched = <String>[];
    for (final m in catalog) {
      if (combined.contains(m.scientificName.toLowerCase()) ||
          combined.contains(m.commonNameEs.toLowerCase()) ||
          combined.contains(m.nameEu.toLowerCase())) {
        matched.add(m.id);
      }
      if (matched.length >= 4) break;
    }
    if (matched.isEmpty && catalog.isNotEmpty) {
      matched.addAll(catalog.take(3).map((e) => e.id));
    }
    return matched;
  }
}

final geminiMushroomProvider =
    StateNotifierProvider<GeminiMushroomNotifier, AiIdentifierState>((ref) {
  return GeminiMushroomNotifier(ref);
});
