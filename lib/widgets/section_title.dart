import 'package:flutter/material.dart';

/// Widget réutilisable pour les titres de section
/// (ex. "Informations", "Itinéraire") dans l'écran de détail.
class SectionTitle extends StatelessWidget {
  final String title;
  final IconData? icon;

  const SectionTitle({super.key, required this.title, this.icon});

  @override
  /// Construit un titre de section avec une icône optionnelle et le style du thème courant.
Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
