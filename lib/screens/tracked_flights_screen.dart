import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/flight_card.dart';

/// Écran listant les vols suivis (marqués avec un signet) par l'utilisateur.
class TrackedFlightsScreen extends StatelessWidget {
  const TrackedFlightsScreen({super.key});

  @override
  /// Construit l'écran affichant les vols suivis par l'utilisateur.
Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final tracked = appState.trackedFlights;

    return Scaffold(
      appBar: AppBar(title: const Text('Vols suivis')),
      body: tracked.isEmpty
          ? const EmptyState(
              icon: Icons.bookmark_border,
              message: 'Vous ne suivez encore aucun vol.\n'
                  'Appuyez sur l\'icône signet d\'un vol pour le suivre.',
            )
          : LayoutBuilder(
              builder: (context, constraints) {
                final isTablet = constraints.maxWidth >= 600;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isTablet ? 3 : 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: isTablet ? 0.85 : 0.72,
                  ),
                  itemCount: tracked.length,
                  itemBuilder: (context, index) {
                    final flight = tracked[index];
                    return FlightCard(
                      flight: flight,
                      isTracked: true,
                      onTap: () => context.push('/flight/${flight.id}'),
                      onTrackTap: () => appState.toggleTracked(flight.id),
                    );
                  },
                );
              },
            ),
    );
  }
}
