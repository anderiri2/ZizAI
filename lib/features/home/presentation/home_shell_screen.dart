import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/safety_disclaimer_banner.dart';
import '../../../core/widgets/translucent_bottom_nav.dart';
import '../../ai_identifier/presentation/ai_identifier_screen.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../catalog/data/catalog_repository.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/catalog_screen.dart';
import '../../map/presentation/map_screen.dart';
import '../../outings/presentation/outings_screen.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  final VoidCallback? onSignOutToLogin;

  const HomeShellScreen({
    super.key,
    this.onSignOutToLogin,
  });

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _currentTabIndex = 0;
  Mushroom? _pendingMushroomForMap;
  String? _pendingPhotoPathForMap;
  String? _selectedOutingIdForMapFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SafetyDisclaimerBanner.showFirstLaunchDialogIfNeeded(context);
    });
  }

  void _openMapToRegisterSpecies(Mushroom mushroom, [String? photoPath]) {
    setState(() {
      _pendingMushroomForMap = mushroom;
      _pendingPhotoPathForMap = photoPath;
      _currentTabIndex = 1;
    });
  }

  void _openMapFilteredByOuting(String outingId) {
    setState(() {
      _selectedOutingIdForMapFilter = outingId;
      _currentTabIndex = 1;
    });
  }

  void _openMapToRegisterSpotOnActiveOuting() {
    final catalog =
        ref.read(allMushroomsProvider).valueOrNull ?? const <Mushroom>[];
    setState(() {
      if (catalog.isNotEmpty) {
        _pendingMushroomForMap = catalog.first;
      }
      _currentTabIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentTabIndex,
        children: [
          CatalogScreen(
            onRegisterSpotInMap: (mushroom) =>
                _openMapToRegisterSpecies(mushroom),
          ),
          MapScreen(
            initialMushroomToRegister: _pendingMushroomForMap,
            initialImagePathToRegister: _pendingPhotoPathForMap,
            initialSelectedOutingFilter: _selectedOutingIdForMapFilter,
            onInitialMushroomConsumed: () {
              setState(() {
                _pendingMushroomForMap = null;
                _pendingPhotoPathForMap = null;
              });
            },
          ),
          OutingsScreen(
            onViewOutingInGlobalMap: _openMapFilteredByOuting,
            onAddSpotInMapDuringOuting: _openMapToRegisterSpotOnActiveOuting,
          ),
          AiIdentifierScreen(
            onRegisterIdentifiedMushroomInMap: (mushroom, photoPath) =>
                _openMapToRegisterSpecies(mushroom, photoPath),
          ),
          const BackupScreen(),
        ],
      ),
      bottomNavigationBar: TranslucentBottomNavBar(
        currentIndex: _currentTabIndex,
        onTabSelected: (index) {
          setState(() {
            _currentTabIndex = index;
          });
        },
      ),
    );
  }
}
