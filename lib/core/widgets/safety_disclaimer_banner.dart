import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/autumn_theme.dart';

class SafetyDisclaimerBanner extends StatelessWidget {
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
            const Expanded(
              child: Text(
                'Aviso de Seguridad Micológica',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AutumnColors.boletusBrown,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'La información e imágenes de Perretxikotan tienen carácter exclusivamente divulgativo y orientativo.\n\n'
          'Nunca consumas una seta silvestre si no estás 100 % seguro de su identificación morfológica o sin haberla consultado presencialmente con expertos o en una sociedad micológica.',
          style: TextStyle(
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
            label: const Text('Entendido, recolectar con prudencia'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
              compact
                  ? 'Guía orientativa: no consumas ningún ejemplar sin estar 100 % seguro o consultar a una sociedad micológica.'
                  : 'Aviso micológico: Esta ficha tiene carácter informativo. Ante la más mínima duda sobre la identidad de un ejemplar, nunca lo consumas y consulta a una sociedad micológica.',
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
