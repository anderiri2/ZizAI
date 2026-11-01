import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mushroom.dart';

enum CatalogSortMode {
  spanish('Castellano (A-Z)'),
  basque('Euskera (A-Z)'),
  scientific('Científico (A-Z)');

  final String label;
  const CatalogSortMode(this.label);
}

enum CatalogCategoryFilter {
  all('Todas'),
  excellent('Excelentes'),
  edible('Comestibles'),
  caution('Precaución'),
  dangerous('Tóxicas / Mortales'),
  autumn('Otoño'),
  spring('Primavera'),
  favorites('Favoritas');

  final String label;
  const CatalogCategoryFilter(this.label);
}

class CatalogRepository {
  static const String _catalogAssetPath = 'assets/data/mushrooms_catalog.json';

  Future<List<Mushroom>> loadMushrooms() async {
    final rawJson = await rootBundle.loadString(_catalogAssetPath);
    final List<dynamic> decoded = json.decode(rawJson) as List<dynamic>;
    return decoded
        .map((item) => Mushroom.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

final allMushroomsProvider = FutureProvider<List<Mushroom>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.loadMushrooms();
});

final catalogSearchQueryProvider = StateProvider<String>((ref) => '');

final catalogSortModeProvider =
    StateProvider<CatalogSortMode>((ref) => CatalogSortMode.spanish);

final catalogCategoryFilterProvider =
    StateProvider<CatalogCategoryFilter>((ref) => CatalogCategoryFilter.all);

class FavoriteMushroomsNotifier extends StateNotifier<Set<String>> {
  static const _prefsKey = 'perretxikotan_favorite_mushrooms';

  FavoriteMushroomsNotifier() : super(const {}) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? const [];
    state = list.toSet();
  }

  Future<void> toggleFavorite(String mushroomId) async {
    final updated = Set<String>.from(state);
    if (updated.contains(mushroomId)) {
      updated.remove(mushroomId);
    } else {
      updated.add(mushroomId);
    }
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, updated.toList());
  }
}

final favoriteMushroomsProvider =
    StateNotifierProvider<FavoriteMushroomsNotifier, Set<String>>((ref) {
  return FavoriteMushroomsNotifier();
});

final filteredMushroomsProvider = Provider<AsyncValue<List<Mushroom>>>((ref) {
  final allAsync = ref.watch(allMushroomsProvider);
  final query = ref.watch(catalogSearchQueryProvider).trim().toLowerCase();
  final sortMode = ref.watch(catalogSortModeProvider);
  final filter = ref.watch(catalogCategoryFilterProvider);
  final favorites = ref.watch(favoriteMushroomsProvider);

  return allAsync.whenData((mushrooms) {
    final filtered = mushrooms.where((m) {
      if ( query.isNotEmpty ) {
        final matchesQuery = m.spanishName.toLowerCase().contains(query) ||
            m.basqueName.toLowerCase().contains(query) ||
            m.scientificName.toLowerCase().contains(query) ||
            m.family.toLowerCase().contains(query) ||
            m.habitat.toLowerCase().contains(query);
        if (!matchesQuery) return false;
      }

      switch (filter) {
        case CatalogCategoryFilter.all:
          return true;
        case CatalogCategoryFilter.excellent:
          return m.edibility == EdibilityLevel.excellent;
        case CatalogCategoryFilter.edible:
          return m.edibility == EdibilityLevel.excellent ||
              m.edibility == EdibilityLevel.good;
        case CatalogCategoryFilter.caution:
          return m.edibility == EdibilityLevel.caution;
        case CatalogCategoryFilter.dangerous:
          return m.edibility.isDangerousGroup;
        case CatalogCategoryFilter.autumn:
          return m.season.toLowerCase().contains('otoño') ||
              m.season.toLowerCase().contains('todo el año');
        case CatalogCategoryFilter.spring:
          return m.season.toLowerCase().contains('primavera');
        case CatalogCategoryFilter.favorites:
          return favorites.contains(m.id);
      }
    }).toList();

    filtered.sort((a, b) {
      switch (sortMode) {
        case CatalogSortMode.spanish:
          return _normalizeSortKey(a.spanishName)
              .compareTo(_normalizeSortKey(b.spanishName));
        case CatalogSortMode.basque:
          return _normalizeSortKey(a.basqueName)
              .compareTo(_normalizeSortKey(b.basqueName));
        case CatalogSortMode.scientific:
          return _normalizeSortKey(a.scientificName)
              .compareTo(_normalizeSortKey(b.scientificName));
      }
    });

    return filtered;
  });
});

String _normalizeSortKey(String input) {
  return input
      .toLowerCase()
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u')
      .trim();
}
