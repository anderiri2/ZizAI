import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../../core/widgets/safety_disclaimer_banner.dart';
import '../data/catalog_repository.dart';
import '../models/mushroom.dart';

class MushroomDetailScreen extends ConsumerStatefulWidget {
  final Mushroom mushroom;
  final void Function(Mushroom mushroom)? onRegisterSpotInMap;

  const MushroomDetailScreen({
    super.key,
    required this.mushroom,
    this.onRegisterSpotInMap,
  });

  @override
  ConsumerState<MushroomDetailScreen> createState() =>
      _MushroomDetailScreenState();
}

class _MushroomDetailScreenState extends ConsumerState<MushroomDetailScreen> {
  int _currentImageIndex = 0;

  void _openImageZoom(BuildContext context, String assetPath) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.black.withValues(alpha: 0.92),
        insetPadding: const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4.0,
                child: Image.asset(
                  assetPath,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Image.asset(
                    'assets/images/logo_perretxikotan.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: IconButton.filled(
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(ctx).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.mushroom;
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final favorites = ref.watch(favoriteMushroomsProvider);
    final isFavorite = favorites.contains(m.id);
    final allMushroomsAsync = ref.watch(allMushroomsProvider);
    final morph = m.morphologyFor(lang);

    return Scaffold(
      backgroundColor: AutumnColors.parchmentBg,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 330,
            pinned: true,
            backgroundColor: AutumnColors.boletusBrown,
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                tooltip: isFavorite
                    ? s.tr(
                        eu: 'Kendu gogokoetatik',
                        es: 'Quitar de favoritas',
                        en: 'Remove from favorites',
                      )
                    : s.tr(
                        eu: 'Gorde gogokoetan',
                        es: 'Guardar en favoritas',
                        en: 'Save to favorites',
                      ),
                onPressed: () {
                  ref
                      .read(favoriteMushroomsProvider.notifier)
                      .toggleFavorite(m.id);
                },
                icon: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: isFavorite ? AutumnColors.amberLeaf : Colors.white,
                ),
              ),
              const SizedBox(width: 6),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  PageView.builder(
                    itemCount: m.images.length,
                    onPageChanged: (idx) =>
                        setState(() => _currentImageIndex = idx),
                    itemBuilder: (context, index) {
                      final imgPath = m.images[index];
                      return GestureDetector(
                        onTap: () => _openImageZoom(context, imgPath),
                        child: Hero(
                          tag: index == 0
                              ? 'mushroom_img_${m.id}'
                              : '${m.id}_$index',
                          child: Image.asset(
                            imgPath,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Image.asset(
                              'assets/images/logo_perretxikotan.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: 120,
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              AutumnColors.barkDark.withValues(alpha: 0.85),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_currentImageIndex + 1}/${m.images.length}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    bottom: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: m.edibility.badgeColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            m.edibility.icon,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            m.edibilityLabelFor(lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.displayNameFor(lang),
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AutumnColors.boletusBrown,
                              height: 1.15,
                            ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AutumnColors.mossGreen.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                AutumnColors.mossGreen.withValues(alpha: 0.35),
                          ),
                        ),
                        child: Text(
                          'EU: ${m.basqueName}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AutumnColors.mossGreen,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color:
                              AutumnColors.ochreGold.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'ES: ${m.spanishName}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AutumnColors.boletusBrown,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AutumnColors.creamCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'EN: ${m.commonNameEn}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AutumnColors.textSecondary,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AutumnColors.creamCard,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          m.scientificName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.w600,
                            color: AutumnColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Summary
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AutumnColors.warmSand),
                    ),
                    child: Text(
                      m.summaryFor(lang),
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.48,
                        color: AutumnColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  if (widget.onRegisterSpotInMap != null) ...[
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AutumnColors.boletusBrown,
                          backgroundColor:
                              AutumnColors.ochreGold.withValues(alpha: 0.12),
                          side: const BorderSide(
                            color: AutumnColors.ochreGold,
                            width: 1.4,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                          widget.onRegisterSpotInMap!(m);
                        },
                        icon: const Icon(Icons.add_location_alt_rounded),
                        label: Text(
                          s.tr(
                            eu: 'Gorde perretxiko honen kokapena Mapan',
                            es: 'Guardar ubicación de esta seta en el Mapa',
                            en: 'Save location of this mushroom on the Map',
                          ),
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Habitat & Season
                  _InfoSectionCard(
                    title: s.tr(
                      eu: 'Habitata eta Sasoia',
                      es: 'Hábitat y Época de Fructificación',
                      en: 'Habitat & Fruiting Season',
                    ),
                    icon: Icons.forest_rounded,
                    iconColor: AutumnColors.mossGreen,
                    children: [
                      _DetailRow(
                        icon: Icons.park_rounded,
                        label: s.tr(
                          eu: 'Ohiko habitata',
                          es: 'Hábitat habitual',
                          en: 'Typical habitat',
                        ),
                        value: m.habitatFor(lang),
                      ),
                      const Divider(height: 22),
                      _DetailRow(
                        icon: Icons.calendar_month_rounded,
                        label: s.tr(
                          eu: 'Sasoia',
                          es: 'Temporada',
                          en: 'Season',
                        ),
                        value: m.seasonFor(lang),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Morphology
                  _InfoSectionCard(
                    title: s.tr(
                      eu: 'Identifikazioa eta Morfologia',
                      es: 'Identificación y Morfología',
                      en: 'Identification & Morphology',
                    ),
                    icon: Icons.biotech_rounded,
                    iconColor: AutumnColors.ochreGold,
                    children: [
                      _DetailRow(
                        icon: Icons.umbrella_rounded,
                        label: s.tr(
                          eu: 'Txapela',
                          es: 'Sombrero (Txapela)',
                          en: 'Cap (Pileus)',
                        ),
                        value: morph.cap,
                      ),
                      const Divider(height: 22),
                      _DetailRow(
                        icon: Icons.view_stream_rounded,
                        label: s.tr(
                          eu: 'Himenioa (Orriak, poroak edo tolesturak)',
                          es: 'Himenio (Láminas, poros o pliegues)',
                          en: 'Hymenium (Gills, pores or ridges)',
                        ),
                        value: morph.hymenium,
                      ),
                      const Divider(height: 22),
                      _DetailRow(
                        icon: Icons.vertical_align_bottom_rounded,
                        label: s.tr(
                          eu: 'Hanka',
                          es: 'Pie',
                          en: 'Stem',
                        ),
                        value: morph.stem,
                      ),
                      const Divider(height: 22),
                      _DetailRow(
                        icon: Icons.air_rounded,
                        label: s.tr(
                          eu: 'Mamia, Usaina eta Zaporea',
                          es: 'Carne, Olor y Sabor',
                          en: 'Flesh, Odor & Taste',
                        ),
                        value: morph.flesh,
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  // Confusions
                  Row(
                    children: [
                      const Icon(
                        Icons.compare_arrows_rounded,
                        color: AutumnColors.terracotta,
                        size: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        s.tr(
                          eu: 'Ohiko Nahasketak',
                          es: 'Confusiones Habituales',
                          en: 'Common Lookalikes & Confusions',
                        ),
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AutumnColors.boletusBrown,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (m.confusions.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AutumnColors.warmSand),
                      ),
                      child: Text(
                        s.tr(
                          eu: 'Morfologia oso bereizgarria duen espeziea, ohiko nahasketa arriskutsurik gabea.',
                          es: 'Especie de morfología muy característica sin confusiones peligrosas habituales.',
                          en: 'Distinctive morphology with no common dangerous lookalikes.',
                        ),
                        style: const TextStyle(color: AutumnColors.textSecondary),
                      ),
                    )
                  else
                    ...m.confusions.map((conf) {
                      final targetMushroom = allMushroomsAsync.valueOrNull
                          ?.where((sp) => sp.id == conf.mushroomId)
                          .firstOrNull;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: conf.riskLevel.badgeColor
                                .withValues(alpha: 0.45),
                            width: 1.3,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (targetMushroom != null)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.asset(
                                      targetMushroom.primaryImage,
                                      width: 58,
                                      height: 58,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Image.asset(
                                        'assets/images/logo_perretxikotan.png',
                                        width: 58,
                                        height: 58,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                if (targetMushroom != null)
                                  const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: conf.riskLevel.badgeColor,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          conf
                                              .edibilityWarningFor(lang)
                                              .toUpperCase(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        conf.commonName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15.5,
                                          color: AutumnColors.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        conf.scientificName,
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                          fontSize: 13,
                                          color: AutumnColors.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              '${s.tr(eu: 'Nola bereizi', es: 'Cómo diferenciarla', en: 'How to distinguish')}: ${conf.difference}',
                              style: const TextStyle(
                                fontSize: 13.8,
                                height: 1.42,
                                color: AutumnColors.textPrimary,
                              ),
                            ),
                            if (targetMushroom != null) ...[
                              const SizedBox(height: 10),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  style: TextButton.styleFrom(
                                    foregroundColor: AutumnColors.boletusBrown,
                                    backgroundColor: AutumnColors.creamCard,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => MushroomDetailScreen(
                                          mushroom: targetMushroom,
                                          onRegisterSpotInMap:
                                              widget.onRegisterSpotInMap,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                  ),
                                  label: Text(
                                    s.tr(
                                      eu: 'Ikusi espezie honen fitxa',
                                      es: 'Ver ficha de esta especie',
                                      en: 'View species sheet',
                                    ),
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }),

                  const SizedBox(height: 12),
                  const SafetyDisclaimerBanner(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoSectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _InfoSectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AutumnColors.warmSand),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AutumnColors.boletusBrown,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AutumnColors.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AutumnColors.ochreGold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.42,
                  color: AutumnColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
