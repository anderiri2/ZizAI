import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/autumn_theme.dart';
import '../../../core/widgets/safety_disclaimer_banner.dart';
import '../data/catalog_repository.dart';
import '../models/mushroom.dart';
import 'mushroom_detail_screen.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  final void Function(Mushroom mushroom)? onRegisterSpotInMap;
  final VoidCallback? onOpenSettingsDrawer;

  const CatalogScreen({
    super.key,
    this.onRegisterSpotInMap,
    this.onOpenSettingsDrawer,
  });

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getPrimaryDisplayName(Mushroom m, CatalogSortMode sortMode) {
    switch (sortMode) {
      case CatalogSortMode.basque:
        return m.basqueName;
      case CatalogSortMode.spanish:
        return m.spanishName;
      case CatalogSortMode.english:
        return m.commonNameEn;
      case CatalogSortMode.scientific:
        return m.scientificName;
    }
  }

  String _getInitialLetter(Mushroom m, CatalogSortMode sortMode) {
    final text = _getPrimaryDisplayName(m, sortMode).trim();
    if (text.isEmpty) return '#';
    final first = text[0].toUpperCase();
    return first
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U');
  }

  @override
  Widget build(BuildContext context) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);
    final filteredAsync = ref.watch(filteredMushroomsProvider);
    final sortMode = ref.watch(catalogSortModeProvider);
    final selectedFilter = ref.watch(catalogCategoryFilterProvider);
    final searchQuery = ref.watch(catalogSearchQueryProvider);
    final favorites = ref.watch(favoriteMushroomsProvider);

    return Scaffold(
      backgroundColor: AutumnColors.parchmentBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Amanita caesarea logo (abre el menú lateral) + Title + A-Z Sort
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
              child: Row(
                children: [
                  Semantics(
                    button: true,
                    label: s.tr(
                      eu: 'Ireki ezarpenen panela',
                      es: 'Abrir panel de ajustes',
                      en: 'Open settings panel',
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: widget.onOpenSettingsDrawer ??
                          () => Scaffold.of(context).openDrawer(),
                      child: Tooltip(
                        message: s.tr(
                          eu: 'Ireki ezarpenen panela',
                          es: 'Abrir panel de ajustes',
                          en: 'Open settings panel',
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.asset(
                            'assets/images/logo_zizai.png',
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: widget.onOpenSettingsDrawer ??
                          () => Scaffold.of(context).openDrawer(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text.rich(
                              const TextSpan(
                                text: 'Ziz',
                                children: [
                                  TextSpan(
                                    text: 'AI',
                                    style: TextStyle(color: AutumnColors.amberLeaf),
                                  ),
                                ],
                              ),
                              maxLines: 1,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    color: AutumnColors.boletusBrown,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                          ),
                          Text(
                            s.catalogHeaderSubtitle,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AutumnColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  PopupMenuButton<CatalogSortMode>(
                    tooltip: s.tr(
                      eu: 'Ordenatu A-Z aurkibidea',
                      es: 'Ordenar índice alfabético A-Z',
                      en: 'Sort A-Z index',
                    ),
                    initialValue: sortMode,
                    color: AutumnColors.parchmentBg,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    onSelected: (mode) {
                      ref.read(catalogSortModeProvider.notifier).state = mode;
                    },
                    itemBuilder: (ctx) => CatalogSortMode.values
                        .map(
                          (mode) => PopupMenuItem(
                            value: mode,
                            child: Row(
                              children: [
                                Icon(
                                  sortMode == mode
                                      ? Icons.radio_button_checked_rounded
                                      : Icons.radio_button_off_rounded,
                                  size: 18,
                                  color: AutumnColors.ochreGold,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  mode.labelFor(lang),
                                  style: TextStyle(
                                    fontWeight: sortMode == mode
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AutumnColors.creamCard,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AutumnColors.warmSand),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.sort_by_alpha_rounded,
                            size: 16,
                            color: AutumnColors.boletusBrown,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            switch (sortMode) {
                              CatalogSortMode.basque => 'EU A-Z',
                              CatalogSortMode.spanish => 'ES A-Z',
                              CatalogSortMode.english => 'EN A-Z',
                              CatalogSortMode.scientific => 'LAT A-Z',
                            },
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AutumnColors.boletusBrown,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  ref.read(catalogSearchQueryProvider.notifier).state = val;
                },
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: AutumnColors.textSecondary,
                  ),
                  suffixIcon: searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            ref.read(catalogSearchQueryProvider.notifier).state =
                                '';
                          },
                        )
                      : null,
                ),
              ),
            ),

            // Category Filter Chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                scrollDirection: Axis.horizontal,
                itemCount: CatalogCategoryFilter.values.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, idx) {
                  final filter = CatalogCategoryFilter.values[idx];
                  final isSelected = selectedFilter == filter;
                  return ChoiceChip(
                    label: Text(filter.labelFor(lang)),
                    selected: isSelected,
                    onSelected: (_) {
                      ref.read(catalogCategoryFilterProvider.notifier).state =
                          filter;
                    },
                    selectedColor: AutumnColors.boletusBrown,
                    backgroundColor: AutumnColors.creamCard,
                    labelStyle: TextStyle(
                      color:
                          isSelected ? Colors.white : AutumnColors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 12.5,
                    ),
                    showCheckmark: false,
                  );
                },
              ),
            ),
            const SizedBox(height: 6),

            // Alphabetical Species List
            Expanded(
              child: filteredAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                    color: AutumnColors.ochreGold,
                  ),
                ),
                error: (err, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      s.tr(
                        eu: 'Errorea katalogoa kargatzean: $err',
                        es: 'Error al cargar el catálogo: $err',
                        en: 'Error loading catalog: $err',
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (mushrooms) {
                  if (mushrooms.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 52,
                              color:
                                  AutumnColors.textMuted.withValues(alpha: 0.6),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              s.tr(
                                eu: 'Ez da perretxikorik aurkitu iragazki horiekin.',
                                es: 'No se han encontrado setas con esos filtros.',
                                en: 'No mushrooms found matching those filters.',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: AutumnColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: () {
                                _searchController.clear();
                                ref
                                    .read(catalogSearchQueryProvider.notifier)
                                    .state = '';
                                ref
                                    .read(catalogCategoryFilterProvider.notifier)
                                    .state = CatalogCategoryFilter.all;
                              },
                              child: Text(
                                s.tr(
                                  eu: 'Berrezarri iragazkiak',
                                  es: 'Restablecer filtros',
                                  en: 'Reset filters',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(18, 6, 18, 110),
                    itemCount: mushrooms.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SafetyDisclaimerBanner(compact: true),
                              const SizedBox(height: 8),
                              Text(
                                s.tr(
                                  eu: '${mushrooms.length} espezie erakusten (${sortMode.labelFor(lang)})',
                                  es: 'Mostrando ${mushrooms.length} especies ordenadas por ${sortMode.labelFor(lang)}',
                                  en: 'Showing ${mushrooms.length} species sorted by ${sortMode.labelFor(lang)}',
                                ),
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AutumnColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      final m = mushrooms[index - 1];
                      final currentLetter = _getInitialLetter(m, sortMode);
                      final prevLetter = index > 1
                          ? _getInitialLetter(mushrooms[index - 2], sortMode)
                          : null;
                      final showLetterHeader = currentLetter != prevLetter;
                      final isFav = favorites.contains(m.id);

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showLetterHeader)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 10, bottom: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: AutumnColors.ochreGold,
                                      borderRadius: BorderRadius.circular(9),
                                    ),
                                    child: Text(
                                      currentLetter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Expanded(
                                    child: Divider(
                                      color: AutumnColors.warmSand,
                                      thickness: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          _MushroomCatalogCard(
                            mushroom: m,
                            sortMode: sortMode,
                            lang: lang,
                            isFavorite: isFav,
                            onFavoriteToggle: () {
                              ref
                                  .read(favoriteMushroomsProvider.notifier)
                                  .toggleFavorite(m.id);
                            },
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => MushroomDetailScreen(
                                    mushroom: m,
                                    onRegisterSpotInMap:
                                        widget.onRegisterSpotInMap,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MushroomCatalogCard extends StatelessWidget {
  final Mushroom mushroom;
  final CatalogSortMode sortMode;
  final AppLanguage lang;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onTap;

  const _MushroomCatalogCard({
    required this.mushroom,
    required this.sortMode,
    required this.lang,
    required this.isFavorite,
    required this.onFavoriteToggle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // El nombre científico en latín es el primer nombre visible
    final latinTitle = mushroom.scientificName;
    final commonTitle = mushroom.displayNameFor(lang);
    final secondaryTitle = mushroom.secondaryNamesFor(lang);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: 'mushroom_img_${mushroom.id}',
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: Image.asset(
                        mushroom.primaryImage,
                        width: 100,
                        height: 108,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                          'assets/images/logo_zizai.png',
                          width: 100,
                          height: 108,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: mushroom.edibility.badgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        mushroom.edibility.icon,
                        color: Colors.white,
                        size: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: mushroom.edibility.badgeColor
                                  .withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              mushroom.edibility.shortLabelFor(lang).toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: mushroom.edibility.badgeColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: onFavoriteToggle,
                          child: Icon(
                            isFavorite
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            size: 20,
                            color: isFavorite
                                ? AutumnColors.terracotta
                                : AutumnColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      latinTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        fontStyle: FontStyle.italic,
                        color: AutumnColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      commonTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.8,
                        fontWeight: FontWeight.w700,
                        color: AutumnColors.mossGreen,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      secondaryTitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: AutumnColors.textMuted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.forest_rounded,
                          size: 14,
                          color: AutumnColors.ochreGold,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mushroom.habitatFor(lang),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AutumnColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
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
