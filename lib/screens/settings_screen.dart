import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

/// Écran de réglages : permet de basculer entre thème clair et sombre,
/// et donne accès aux différentes listes (vols disponibles, vols
/// suivis, réservations effectuées) via un résumé cliquable.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Réglages')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              secondary: Icon(
                appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              title: const Text('Thème sombre'),
              subtitle: const Text('Basculer entre thème clair et sombre'),
              value: appState.isDarkMode,
              onChanged: (_) => appState.toggleTheme(),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: ListTile(
              leading: const Icon(Icons.flight),
              title: const Text('Vols disponibles'),
              subtitle: const Text('Voir la liste complète des vols'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${appState.allFlights.length}'),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              // Bascule vers l'onglet Accueil (liste/recherche des vols).
              onTap: () => context.go('/'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bookmark),
              title: const Text('Vols suivis'),
              subtitle: const Text('Voir les vols que vous suivez'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${appState.trackedFlights.length}'),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              // Bascule vers l'onglet Vols suivis.
              onTap: () => context.go('/tracked'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.airplane_ticket),
              title: const Text('Réservations effectuées'),
              subtitle: const Text('Voir le détail de vos réservations'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('${appState.bookings.length}'),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right),
                ],
              ),
              // Ouvre l'écran dédié listant les réservations.
              onTap: () => context.push('/reservations'),
            ),
          ),
          const SizedBox(height: 16),
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Application de gestion des vols de l\'aéroport '
                      'international Ouagadougou-Donsin, Burkina Faso.',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
