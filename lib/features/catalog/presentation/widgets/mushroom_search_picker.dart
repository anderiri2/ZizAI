import 'package:flutter/material.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/autumn_theme.dart';
import '../../models/mushroom.dart';

/// Selector interactivo y táctil de setas del catálogo con buscador integrado y chips rápidos de otoño.
class MushroomSearchPicker extends StatelessWidget {
  final Mushroom? selectedMushroom;
  final List<Mushroom> catalogMushrooms;
  final ValueChanged<Mushroom> onMushroomChanged;
  final AppLanguage lang;

  const MushroomSearchPicker({
    super.key,
    required this.selectedMushroom,
    required this.catalogMushrooms,
    required this.onMushroomChanged,
    required this.lang,
  });

  // IDs de las especies más frecuentes en otoño vasco e ibérico
  static const List<String> _frequentAutumnSpeciesIds = [
    'boletus_edulis',
    'cantharellus_cibarius',
    'lactarius_deliciosus',
    'amanita_caesarea',
    'hydnum_repandum',
    'craterellus_cornucopioides',
    'macrolepiota_procera',
  ];

  static String _normalize(String input) {
    var str = input.toLowerCase().trim();
    const withDiacritics = 'áàäâãéèëêíìïîóòöôõúùüûñç';
    const withoutDiacritics = 'aaaaaeeeeiiiiooooouuuunc';
    for (int i = 0; i < withDiacritics.length; i++) {
      str = str.replaceAll(withDiacritics[i], withoutDiacritics[i]);
    }
    return str;
  }

  Future<void> _openSearchModal(BuildContext context) async {
    final picked = await showModalBottomSheet<Mushroom>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AutumnColors.parchmentBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
      ),
      builder: (ctx) => _MushroomSearchModal(
        catalogMushrooms: catalogMushrooms,
        lang: lang,
        initialSelected: selectedMushroom,
      ),
    );

    if (picked != null) {
      onMushroomChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(lang);
    final m = selectedMushroom;

    // Obtener las setas frecuentes que existen en el catálogo
    final quickMushrooms = _frequentAutumnSpeciesIds
        .map((id) => catalogMushrooms.where((it) => it.id == id).firstOrNull)
        .whereType<Mushroom>()
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta del campo
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              s.tr(
                eu: 'Katalogoko espeziea',
                es: 'Especie del catálogo',
                en: 'Catalog species',
              ),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AutumnColors.boletusBrown,
              ),
            ),
            InkWell(
              onTap: () => _openSearchModal(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                child: Row(
                  children: [
                    const Icon(
                      Icons.search_rounded,
                      size: 16,
                      color: AutumnColors.mossGreen,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      s.tr(
                        eu: 'Bilatu setak',
                        es: 'Buscar seta',
                        en: 'Search mushroom',
                      ),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AutumnColors.mossGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Tarjeta de la seta seleccionada actualmente
        InkWell(
          onTap: () => _openSearchModal(context),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: m != null
                    ? AutumnColors.amberLeaf.withValues(alpha: 0.6)
                    : AutumnColors.warmSand,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Miniatura de la seta
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: m != null
                      ? Image.asset(
                          m.primaryImage,
                          width: 52,
                          height: 52,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            width: 52,
                            height: 52,
                            color: AutumnColors.warmSand,
                            child: const Icon(Icons.eco_rounded,
                                color: AutumnColors.boletusBrown),
                          ),
                        )
                      : Container(
                          width: 52,
                          height: 52,
                          color: AutumnColors.warmSand,
                          child: const Icon(Icons.eco_rounded,
                              color: AutumnColors.boletusBrown),
                        ),
                ),
                const SizedBox(width: 12),

                // Nombres y etiqueta de comestibilidad
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        m != null ? m.scientificName : s.tr(eu: 'Aukeratu seta bat', es: 'Selecciona una seta', en: 'Select a mushroom'),
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          fontStyle: FontStyle.italic,
                          color: AutumnColors.boletusBrown,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        m != null
                            ? m.displayNameFor(lang)
                            : s.tr(eu: 'Ukitu bilatzailea irekitzeko', es: 'Toca para abrir el buscador', en: 'Tap to open search'),
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: AutumnColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (m != null) ...[
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: m.edibility.badgeColor.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: m.edibility.badgeColor.withValues(alpha: 0.6),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            m.edibility.labelFor(lang),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: m.edibility.badgeColor,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Icono para cambiar
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AutumnColors.warmSand.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.swap_horiz_rounded,
                    color: AutumnColors.boletusBrown,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Chips rápidos para otoño
        if (quickMushrooms.isNotEmpty) ...[
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: quickMushrooms.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final qm = quickMushrooms[index];
                final isSelected = selectedMushroom?.id == qm.id;
                return ActionChip(
                  avatar: CircleAvatar(
                    backgroundImage: AssetImage(qm.primaryImage),
                    radius: 10,
                  ),
                  label: Text(
                    qm.displayNameFor(lang),
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? AutumnColors.boletusBrown
                          : AutumnColors.textSecondary,
                    ),
                  ),
                  backgroundColor: isSelected
                      ? AutumnColors.ochreGold.withValues(alpha: 0.3)
                      : Colors.white,
                  side: BorderSide(
                    color: isSelected
                        ? AutumnColors.ochreGold
                        : AutumnColors.warmSand,
                    width: isSelected ? 1.5 : 1,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  onPressed: () => onMushroomChanged(qm),
                );
              },
            ),
          ),
        ],
      ],
    );
  }
}

class _MushroomSearchModal extends StatefulWidget {
  final List<Mushroom> catalogMushrooms;
  final AppLanguage lang;
  final Mushroom? initialSelected;

  const _MushroomSearchModal({
    required this.catalogMushrooms,
    required this.lang,
    this.initialSelected,
  });

  @override
  State<_MushroomSearchModal> createState() => _MushroomSearchModalState();
}

class _MushroomSearchModalState extends State<_MushroomSearchModal> {
  final _searchCtrl = TextEditingController();
  String _filterQuery = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(widget.lang);
    final q = MushroomSearchPicker._normalize(_filterQuery);

    final filteredList = widget.catalogMushrooms.where((m) {
      if (q.isEmpty) return true;
      final sci = MushroomSearchPicker._normalize(m.scientificName);
      final es = MushroomSearchPicker._normalize(m.spanishName);
      final eu = MushroomSearchPicker._normalize(m.basqueName);
      final en = MushroomSearchPicker._normalize(m.englishName);
      final fam = MushroomSearchPicker._normalize(m.family);
      return sci.contains(q) ||
          es.contains(q) ||
          eu.contains(q) ||
          en.contains(q) ||
          fam.contains(q);
    }).toList()
      ..sort((a, b) => a.scientificName
          .toLowerCase()
          .compareTo(b.scientificName.toLowerCase()));

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.94,
      minChildSize: 0.5,
      builder: (_, scrollController) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Barra de arrastre superior
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AutumnColors.warmSand,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),

              // Cabecera con título y contador
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    s.tr(
                      eu: 'Bilatu Katalogoko Perretxikoa',
                      es: 'Buscar Seta del Catálogo',
                      en: 'Search Catalog Mushroom',
                    ),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AutumnColors.boletusBrown,
                          fontWeight: FontWeight.w800,
                          fontSize: 19,
                        ),
                  ),
                  Text(
                    '${filteredList.length}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AutumnColors.mossGreen,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Buscador de setas con autofocus y botón limpiar
              TextField(
                controller: _searchCtrl,
                autofocus: true,
                onChanged: (v) => setState(() => _filterQuery = v),
                decoration: InputDecoration(
                  hintText: s.tr(
                    eu: 'Bilatu zientifikoz, euskaraz edo gaztelaniaz...',
                    es: 'Buscar por científico, castellano o euskera...',
                    en: 'Search by scientific, Basque or Spanish name...',
                  ),
                  prefixIcon: const Icon(Icons.search_rounded,
                      color: AutumnColors.boletusBrown),
                  suffixIcon: _filterQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _filterQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AutumnColors.warmSand),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: AutumnColors.warmSand),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                        color: AutumnColors.ochreGold, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Lista filtrada
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.search_off_rounded,
                              size: 44,
                              color: AutumnColors.textSecondary,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              s.tr(
                                eu: 'Ez da perretxikorik aurkitu "$_filterQuery" bilaketarekin.',
                                es: 'No se encontraron setas para "$_filterQuery".',
                                en: 'No mushrooms found for "$_filterQuery".',
                              ),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AutumnColors.textSecondary,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        itemCount: filteredList.length,
                        separatorBuilder: (_, __) => const Divider(
                          height: 1,
                          color: AutumnColors.warmSand,
                        ),
                        itemBuilder: (context, idx) {
                          final item = filteredList[idx];
                          final isSelected =
                              widget.initialSelected?.id == item.id;
                          final primaryName = item.scientificName;
                          final localName = item.displayNameFor(widget.lang);
                          final altName = widget.lang == AppLanguage.eu
                              ? item.spanishName
                              : item.basqueName;

                          return ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            selected: isSelected,
                            selectedTileColor:
                                AutumnColors.ochreGold.withValues(alpha: 0.14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.asset(
                                item.primaryImage,
                                width: 46,
                                height: 46,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 46,
                                  height: 46,
                                  color: AutumnColors.warmSand,
                                  child: const Icon(Icons.eco_rounded,
                                      color: AutumnColors.boletusBrown),
                                ),
                              ),
                            ),
                            title: Text(
                              primaryName,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontStyle: FontStyle.italic,
                                color: isSelected
                                    ? AutumnColors.mossGreen
                                    : AutumnColors.boletusBrown,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(
                              altName.isNotEmpty
                                  ? '$localName ($altName)'
                                  : localName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AutumnColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: item.edibility.badgeColor
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: item.edibility.badgeColor
                                      .withValues(alpha: 0.5),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                item.edibility.shortLabel,
                                style: TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w800,
                                  color: item.edibility.badgeColor,
                                ),
                              ),
                            ),
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
