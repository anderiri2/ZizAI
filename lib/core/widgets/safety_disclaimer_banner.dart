import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../localization/app_localizations.dart';
import '../theme/autumn_theme.dart';

class SafetyDisclaimerBanner extends ConsumerWidget {
  final bool compact;

  const SafetyDisclaimerBanner({
    super.key,
    this.compact = false,
  });

  static const String _prefKeyAccepted = 'perretxikotan_safety_accepted';

  static Future<void> showFirstLaunchDialogIfNeeded(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final accepted = prefs.getBool(_prefKeyAccepted) ?? false;
    if (accepted || !context.mounted) return;
    final lang = AppLanguage.fromCode(
      prefs.getString('perretxikotan_app_language'),
    );
    final s = AppStrings(lang);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AutumnColors.parchmentBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AutumnColors.ochreGold.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.health_and_safety_rounded,
                color: AutumnColors.terracotta,
                size: 26,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                s.safetyDialogTitle,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AutumnColors.boletusBrown,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          s.safetyDialogBody,
          style: const TextStyle(
            fontSize: 14.5,
            height: 1.45,
            color: AutumnColors.textSecondary,
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () async {
              await prefs.setBool(_prefKeyAccepted, true);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
            label: Text(s.understood),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(appLanguageProvider);
    final s = AppStrings(lang);

    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: AutumnColors.creamCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AutumnColors.ochreGold.withValues(alpha: 0.45),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: AutumnColors.terracotta,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              compact ? s.safetyDisclaimerShort : s.safetyDialogBody,
              style: TextStyle(
                fontSize: compact ? 12 : 12.5,
                height: 1.38,
                color: AutumnColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
