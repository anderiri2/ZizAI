import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/localization/app_localizations.dart';
import '../models/mushroom.dart';

enum CatalogSortMode {
  basque('Euskara (A-Z)'),
  spanish('Castellano (A-Z)'),
  english('English (A-Z)'),
  scientific('Científico / Latin (A-Z)');

  final String label;
  const CatalogSortMode(this.label);

  String labelFor(AppLanguage lang) {
    switch (this) {
      case CatalogSortMode.basque:
        return 'Euskara (A-Z)';
      case CatalogSortMode.spanish:
        return 'Castellano (A-Z)';
      case CatalogSortMode.english:
        return 'English (A-Z)';
      case CatalogSortMode.scientific:
        switch (lang) {
          case AppLanguage.eu:
            return 'Izen zientifikoa (A-Z)';
          case AppLanguage.es:
            return 'Científico (A-Z)';
          case AppLanguage.en:
            return 'Scientific (A-Z)';
        }
    }
  }
}

enum CatalogCategoryFilter {
  all('Todas'),
  excellent('Excelentes'),
  edible('Comestibles'),
  caution('Precaución'),
  dangerous('Tóxicas y mortales'),
  autumn('Otoño'),
  spring('Primavera'),
  favorites('Favoritas');

  final String label;
  const CatalogCategoryFilter(this.label);

  String labelFor(AppLanguage lang) {
    switch (this) {
      case CatalogCategoryFilter.all:
        switch (lang) {
          case AppLanguage.eu:
            return 'Guztiak';
          case AppLanguage.es:
            return 'Todas';
          case AppLanguage.en:
            return 'All';
        }
      case CatalogCategoryFilter.excellent:
        switch (lang) {
          case AppLanguage.eu:
            return 'Bikainak';
          case AppLanguage.es:
            return 'Excelentes';
          case AppLanguage.en:
            return 'Choice';
        }
      case CatalogCategoryFilter.edible:
        switch (lang) {
          case AppLanguage.eu:
            return 'Jangarriak';
          case AppLanguage.es:
            return 'Comestibles';
          case AppLanguage.en:
            return 'Edible';
        }
      case CatalogCategoryFilter.caution:
        switch (lang) {
          case AppLanguage.eu:
            return 'Kontuz';
          case AppLanguage.es:
            return 'Precaución';
          case AppLanguage.en:
            return 'Caution';
        }
      case CatalogCategoryFilter.dangerous:
        switch (lang) {
          case AppLanguage.eu:
            return 'Toxikoak eta hilgarriak';
          case AppLanguage.es:
            return 'Tóxicas y mortales';
          case AppLanguage.en:
            return 'Toxic & deadly';
        }
      case CatalogCategoryFilter.autumn:
        switch (lang) {
          case AppLanguage.eu:
            return 'Udazkena';
          case AppLanguage.es:
            return 'Otoño';
          case AppLanguage.en:
            return 'Autumn';
        }
      case CatalogCategoryFilter.spring:
        switch (lang) {
          case AppLanguage.eu:
            return 'Udaberria';
          case AppLanguage.es:
            return 'Primavera';
          case AppLanguage.en:
            return 'Spring';
        }
      case CatalogCategoryFilter.favorites:
        switch (lang) {
          case AppLanguage.eu:
            return 'Gogokoak';
          case AppLanguage.es:
            return 'Favoritas';
          case AppLanguage.en:
            return 'Favorites';
        }
    }
  }
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

/// Defaults to Scientific/Latin (`CatalogSortMode.scientific`) as primary taxonomy of the catalog.
final catalogSortModeProvider =
    StateProvider<CatalogSortMode>((ref) => CatalogSortMode.scientific);

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

  Future<void> replaceAllFavorites(List<String> ids) async {
    final updated = ids.toSet();
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, updated.toList());
  }

  Future<void> mergeFavorites(List<String> incomingIds) async {
    final updated = Set<String>.from(state)..addAll(incomingIds);
    state = updated;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_prefsKey, updated.toList());
  }
}

final favoriteMushroomsProvider =
    StateNotifierProvider<FavoriteMushroomsNotifier, Set<String>>((ref) {
  return FavoriteMushroomsNotifier();
});

final favoriteMushroomIdsProvider = favoriteMushroomsProvider;

final filteredMushroomsProvider = Provider<AsyncValue<List<Mushroom>>>((ref) {
  final allAsync = ref.watch(allMushroomsProvider);
  final query = ref.watch(catalogSearchQueryProvider).trim().toLowerCase();
  final sortMode = ref.watch(catalogSortModeProvider);
  final filter = ref.watch(catalogCategoryFilterProvider);
  final favorites = ref.watch(favoriteMushroomsProvider);

  return allAsync.whenData((mushrooms) {
    final filtered = mushrooms.where((m) {
      if (query.isNotEmpty) {
        final matchesQuery = m.basqueName.toLowerCase().contains(query) ||
            m.spanishName.toLowerCase().contains(query) ||
            m.commonNameEn.toLowerCase().contains(query) ||
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
        case CatalogSortMode.basque:
          return _normalizeSortKey(a.basqueName)
              .compareTo(_normalizeSortKey(b.basqueName));
        case CatalogSortMode.spanish:
          return _normalizeSortKey(a.spanishName)
              .compareTo(_normalizeSortKey(b.spanishName));
        case CatalogSortMode.english:
          return _normalizeSortKey(a.commonNameEn)
              .compareTo(_normalizeSortKey(b.commonNameEn));
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
