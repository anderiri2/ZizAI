import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/safety_disclaimer_banner.dart';
import '../../../core/widgets/translucent_bottom_nav.dart';
import '../../backup/presentation/backup_screen.dart';
import '../../catalog/models/mushroom.dart';
import '../../catalog/presentation/catalog_screen.dart';
import '../../map/data/spots_database.dart';
import '../../map/presentation/map_screen.dart';

class HomeShellScreen extends ConsumerStatefulWidget {
  final VoidCallback onSignOutToLogin;

  const HomeShellScreen({
    super.key,
    required this.onSignOutToLogin,
  });

  @override
  ConsumerState<HomeShellScreen> createState() => _HomeShellScreenState();
}

class _HomeShellScreenState extends ConsumerState<HomeShellScreen> {
  int _selectedIndex = 0;
  Mushroom? _pendingMushroomForMap;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      SafetyDisclaimerBanner.showFirstLaunchDialogIfNeeded(context);
    });
  }

  void _navigateToMapWithMushroom(Mushroom mushroom) {
    setState(() {
      _pendingMushroomForMap = mushroom;
      _selectedIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final spotsAsync = ref.watch(foragingSpotsProvider);
    final spotsCount = spotsAsync.valueOrNull?.length ?? 0;

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          CatalogScreen(
            onRegisterSpotInMap: _navigateToMapWithMushroom,
          ),
          MapScreen(
            initialMushroomToRegister: _pendingMushroomForMap,
            onInitialMushroomConsumed: () {
              setState(() => _pendingMushroomForMap = null);
            },
          ),
          BackupScreen(
            onSignOutToLogin: widget.onSignOutToLogin,
          ),
        ],
      ),
      bottomNavigationBar: TranslucentBottomNav(
        currentIndex: _selectedIndex,
        savedSpotsCount: spotsCount,
        onTap: (idx) {
          setState(() => _selectedIndex = idx);
        },
      ),
    );
  }
}
