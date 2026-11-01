import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../backup/services/google_drive_backup_service.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/mushroom_detail_screen.dart';
import '../models/chat_message.dart';
import '../services/gemini_mushroom_service.dart';

class AiIdentifierScreen extends ConsumerStatefulWidget {
  final void Function(Mushroom mushroom, String? photoPath)?
      onRegisterIdentifiedMushroomInMap;

  const AiIdentifierScreen({
    super.key,
    this.onRegisterIdentifiedMushroomInMap,
  });

  @override
  ConsumerState<AiIdentifierScreen> createState() => _AiIdentifierScreenState();
}

class _AiIdentifierScreenState extends ConsumerState<AiIdentifierScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickMushroomPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: source,
        maxWidth: 1440,
        imageQuality: 85,
      );
      if (picked == null) return;

      if (kIsWeb) {
        ref.read(geminiMushroomProvider.notifier).attachImage(picked.path);
        return;
      }

      final docsDir = await getApplicationDocumentsDirectory();
      final photosDir = Directory(p.join(docsDir.path, 'photos'));
      if (!await photosDir.exists()) {
        await photosDir.create(recursive: true);
      }

      final fileName =
          'ai_mushroom_${DateTime.now().millisecondsSinceEpoch}${p.extension(picked.path).isEmpty ? '.jpg' : p.extension(picked.path)}';
      final savedFile =
          await File(picked.path).copy(p.join(photosDir.path, fileName));

      ref.read(geminiMushroomProvider.notifier).attachImage(savedFile.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo abrir la cámara o galería.'),
          ),
        );
      }
    }
  }

  Future<void> _submitQuestion([String? presetQuestion]) async {
    final text = presetQuestion ?? _inputController.text;
    _inputController.clear();
    await ref.read(geminiMushroomProvider.notifier).sendQuestion(text);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 180,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final aiState = ref.watch(geminiMushroomProvider);
    final authState = ref.watch(googleDriveBackupProvider);
    final allMushrooms =
        ref.watch(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];

    // Buscar la última foto adjuntada por el usuario para ofrecer guardarla directamente en el Mapa
    final lastUserPhotoPath = aiState.messages
        .where((m) => m.isUser && m.imagePath != null)
        .map((m) => m.imagePath)
        .lastOrNull;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF3E6D3),
              AutumnColors.parchmentBg,
            ],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Cabecera del Identificador IA Gemini
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AutumnColors.boletusBrown,
                            AutumnColors.terracotta,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: AutumnColors.amberLeaf,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.tr(
                              eu: 'Gemini IA Identifikatzailea',
                              es: 'Identificador IA Gemini',
                              en: 'Gemini AI Identifier',
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  color: AutumnColors.boletusBrown,
                                  fontWeight: FontWeight.w800,
                                ),
                          ),
                          Row(
                            children: [
                              Icon(
                                authState.isAuthenticatedWithGoogle
                                    ? Icons.verified_user_rounded
                                    : Icons.wifi_off_rounded,
                                size: 13,
                                color: authState.isAuthenticatedWithGoogle
                                    ? AutumnColors.mossGreen
                                    : AutumnColors.ochreGold,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  authState.isAuthenticatedWithGoogle
                                      ? s.tr(
                                          eu: 'Google saioa aktibo (${authState.userEmail ?? "OAuth"}) • AI Studio gabe',
                                          es: 'Sesión Google activa (${authState.userEmail ?? "OAuth"}) • Sin AI Studio',
                                          en: 'Google session active (${authState.userEmail ?? "OAuth"}) • Zero AI Studio',
                                        )
                                      : s.tr(
                                          eu: 'Tokiko modua / Estaldurarik gabe • Ilara aktibo',
                                          es: 'Modo Local / Sin cobertura • Cola pendiente activa',
                                          en: 'Local / Offline mode • Pending queue active',
                                        ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AutumnColors.textSecondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const LanguageSelectorPill(darkSurface: false),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(geminiMushroomProvider.notifier)
                            .clearConversation();
                      },
                      tooltip: s.tr(
                        eu: 'Berrabiarazi elkarrizketa',
                        es: 'Reiniciar conversación',
                        en: 'Reset conversation',
                      ),
                      icon: const Icon(
                        Icons.refresh_rounded,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                  ],
                ),
              ),

              // Banner de consultas pendientes si el usuario fotografió setas sin cobertura
              if (aiState.pendingSyncCount > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AutumnColors.ochreGold.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AutumnColors.ochreGold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.cloud_sync_rounded,
                          size: 18,
                          color: AutumnColors.boletusBrown,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Tienes ${aiState.pendingSyncCount} consulta(s) con foto pendientes de analizar con Gemini al recuperar cobertura.',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AutumnColors.boletusBrown,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Sugerencias rápidas de consulta micológica
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  children: [
                    _QuickPromptChip(
                      label: '📸 Sacar foto para identificar',
                      onTap: () => _pickMushroomPhoto(ImageSource.camera),
                    ),
                    const SizedBox(width: 8),
                    _QuickPromptChip(
                      label: '¿Cómo distinguir Onddo beltza de Tylopilus?',
                      onTap: () => _submitQuestion(
                        '¿Cómo puedo distinguir un Boletus aereus u Onddo beltza del Tylopilus felleus amargo?',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _QuickPromptChip(
                      label: 'Láminas naranjas con látex zanahoria',
                      onTap: () => _submitQuestion(
                        'He encontrado una seta en pinar con sombrero anaranjado zonado y al cortarla suelta látex color zanahoria. ¿Qué especie es?',
                      ),
                    ),
                    const SizedBox(width: 8),
                    _QuickPromptChip(
                      label: 'Seta con pliegues amarillos en hayedo',
                      onTap: () => _submitQuestion(
                        'Seta amarilla con pliegues decurrentes bajo el sombrero y olor afrutado a albaricoque en hayedo. ¿Con cuál se confunde?',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Historial de mensajes del chat
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                  itemCount:
                      aiState.messages.length + (aiState.isThinking ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == aiState.messages.length) {
                      return const _ThinkingBubble();
                    }
                    final msg = aiState.messages[index];
                    final matchedSpecies = msg.matchedMushroomIds
                        .map((id) =>
                            allMushrooms.where((m) => m.id == id).firstOrNull)
                        .whereType<Mushroom>()
                        .toList();

                    return _ChatBubbleItem(
                      message: msg,
                      matchedSpecies: matchedSpecies,
                      onRetryWithGemini: msg.isPendingSync
                          ? () => ref
                              .read(geminiMushroomProvider.notifier)
                              .retryPendingWithGemini(msg.id)
                          : null,
                      onOpenSpeciesDetail: (mushroom) {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => MushroomDetailScreen(
                              mushroom: mushroom,
                              onRegisterSpotInMap: (m) {
                                Navigator.of(context).pop();
                                widget.onRegisterIdentifiedMushroomInMap
                                    ?.call(m, lastUserPhotoPath);
                              },
                            ),
                          ),
                        );
                      },
                      onSaveFoundSpeciesInMap: (mushroom) {
                        widget.onRegisterIdentifiedMushroomInMap
                            ?.call(mushroom, lastUserPhotoPath);
                      },
                    );
                  },
                ),
              ),

              // Previsualización de foto adjuntada antes de enviar
              if (aiState.selectedImagePath != null)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AutumnColors.ochreGold),
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: !kIsWeb &&
                                File(aiState.selectedImagePath!).existsSync()
                            ? Image.file(
                                File(aiState.selectedImagePath!),
                                width: 54,
                                height: 54,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 54,
                                height: 54,
                                color: AutumnColors.warmSand,
                                child: const Icon(Icons.photo_camera_rounded),
                              ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Fotografía lista para analizar con IA Gemini.\nAñade una nota opcional o pulsa Enviar.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AutumnColors.boletusBrown,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          ref
                              .read(geminiMushroomProvider.notifier)
                              .attachImage(null);
                        },
                        icon: const Icon(
                          Icons.close_rounded,
                          color: AutumnColors.terracotta,
                        ),
                      ),
                    ],
                  ),
                ),

              // Barra inferior de entrada (Cámara, Galería, Texto y Enviar)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 102),
                decoration: BoxDecoration(
                  color: AutumnColors.parchmentCard,
                  boxShadow: [
                    BoxShadow(
                      color: AutumnColors.barkDark.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, -3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => _pickMushroomPhoto(ImageSource.camera),
                      tooltip: 'Sacar foto de la seta',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AutumnColors.ochreGold.withValues(alpha: 0.18),
                      ),
                      icon: const Icon(
                        Icons.photo_camera_rounded,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                    const SizedBox(width: 6),
                    IconButton(
                      onPressed: () => _pickMushroomPhoto(ImageSource.gallery),
                      tooltip: 'Elegir foto de la galería',
                      style: IconButton.styleFrom(
                        backgroundColor:
                            AutumnColors.warmSand.withValues(alpha: 0.7),
                      ),
                      icon: const Icon(
                        Icons.photo_library_rounded,
                        color: AutumnColors.boletusBrown,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _inputController,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _submitQuestion(),
                        decoration: InputDecoration(
                          hintText:
                              'Pregunta a Gemini o describe la seta...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton.small(
                      heroTag: 'btn_send_ai_chat',
                      backgroundColor: AutumnColors.terracotta,
                      foregroundColor: Colors.white,
                      elevation: 2,
                      onPressed: aiState.isThinking ? null : _submitQuestion,
                      child: const Icon(Icons.send_rounded, size: 19),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickPromptChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _QuickPromptChip({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AutumnColors.warmSand),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AutumnColors.boletusBrown,
          ),
        ),
      ),
    );
  }
}

class _ThinkingBubble extends StatelessWidget {
  const _ThinkingBubble();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AutumnColors.warmSand),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AutumnColors.ochreGold,
              ),
            ),
            SizedBox(width: 10),
            Text(
              'Analizando morfología y consultando Gemini...',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AutumnColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatBubbleItem extends StatelessWidget {
  final AiChatMessage message;
  final List<Mushroom> matchedSpecies;
  final VoidCallback? onRetryWithGemini;
  final ValueChanged<Mushroom> onOpenSpeciesDetail;
  final ValueChanged<Mushroom> onSaveFoundSpeciesInMap;

  const _ChatBubbleItem({
    required this.message,
    required this.matchedSpecies,
    required this.onRetryWithGemini,
    required this.onOpenSpeciesDetail,
    required this.onSaveFoundSpeciesInMap,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.86,
        ),
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUser ? AutumnColors.boletusBrown : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isUser ? 20 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 20),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: AutumnColors.warmSand,
                ),
          boxShadow: [
            BoxShadow(
              color: AutumnColors.barkDark.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.imagePath != null &&
                !kIsWeb &&
                File(message.imagePath!).existsSync()) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Image.file(
                  File(message.imagePath!),
                  height: 170,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 10),
            ],
            Text(
              message.text,
              style: TextStyle(
                color: isUser ? Colors.white : AutumnColors.textPrimary,
                fontSize: 13.5,
                height: 1.42,
              ),
            ),
            if (message.isPendingSync && onRetryWithGemini != null) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRetryWithGemini,
                  style: FilledButton.styleFrom(
                    backgroundColor: AutumnColors.amberLeaf,
                    foregroundColor: AutumnColors.barkDark,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  icon: const Icon(Icons.cloud_upload_rounded, size: 16),
                  label: const Text(
                    'Pendiente de conexión • Reintentar con Gemini',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
            if (!isUser && matchedSpecies.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 10),
              const Text(
                'Especies candidatas en el Catálogo (Pulsa para ver ficha o guardar hallazgo):',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: AutumnColors.boletusBrown,
                ),
              ),
              const SizedBox(height: 8),
              ...matchedSpecies.map((m) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AutumnColors.parchmentBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AutumnColors.warmSand),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () => onOpenSpeciesDetail(m),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                m.primaryImageAsset,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 46,
                                  height: 46,
                                  color: AutumnColors.warmSand,
                                  child: const Icon(Icons.forest_rounded),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${m.commonNameEs} • ${m.nameEu}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                      color: AutumnColors.boletusBrown,
                                    ),
                                  ),
                                  Text(
                                    '${m.scientificName} (${m.edibility.labelEs})',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: m.edibility.badgeColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.open_in_new_rounded,
                              size: 16,
                              color: AutumnColors.boletusBrown,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () => onSaveFoundSpeciesInMap(m),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AutumnColors.mossGreen,
                            side: const BorderSide(
                              color: AutumnColors.mossGreen,
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            visualDensity: VisualDensity.compact,
                          ),
                          icon: const Icon(
                            Icons.add_location_alt_rounded,
                            size: 16,
                          ),
                          label: const Text(
                            'Guardar este hallazgo en Mapa / Salida activa',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.bottomRight,
              child: Text(
                DateFormat('HH:mm').format(message.createdAt),
                style: TextStyle(
                  fontSize: 10,
                  color: isUser
                      ? Colors.white.withValues(alpha: 0.7)
                      : AutumnColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
