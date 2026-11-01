import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../localization/app_localizations.dart';
import '../theme/autumn_theme.dart';

class TranslucentBottomNavBar extends ConsumerWidget {
  final int currentIndex;
  final ValueChanged<int> onTabSelected;

  const TranslucentBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              height: 68,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              decoration: BoxDecoration(
                color: AutumnColors.barkDark.withValues(alpha: 0.80),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AutumnColors.amberLeaf.withValues(alpha: 0.38),
                  width: 1.1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AutumnColors.barkDark.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _NavItem(
                    icon: Icons.menu_book_rounded,
                    label: s.navMushrooms,
                    selected: currentIndex == 0,
                    onTap: () => onTabSelected(0),
                  ),
                  _NavItem(
                    icon: Icons.map_rounded,
                    label: s.navMap,
                    selected: currentIndex == 1,
                    onTap: () => onTabSelected(1),
                  ),
                  _NavItem(
                    icon: Icons.hiking_rounded,
                    label: s.navOutings,
                    selected: currentIndex == 2,
                    onTap: () => onTabSelected(2),
                  ),
                  _NavItem(
                    icon: Icons.auto_awesome_rounded,
                    label: s.navAiPhoto,
                    selected: currentIndex == 3,
                    onTap: () => onTabSelected(3),
                  ),
                  _NavItem(
                    icon: Icons.cloud_sync_rounded,
                    label: s.navBackup,
                    selected: currentIndex == 4,
                    onTap: () => onTabSelected(4),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2, vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [
                      AutumnColors.ochreGold,
                      AutumnColors.terracotta,
                    ],
                  )
                : null,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 20,
                color: selected
                    ? Colors.white
                    : AutumnColors.parchmentBg.withValues(alpha: 0.72),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    color: selected
                        ? Colors.white
                        : AutumnColors.parchmentBg.withValues(alpha: 0.72),
                    fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
