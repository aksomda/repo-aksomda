import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../state/app_state.dart';
import '../widgets/section_title.dart';
import '../widgets/status_badge.dart';

/// Écran de détail : reçoit l'identifiant du vol en paramètre de route
/// (`/flight/:id`) et récupère le vol correspondant depuis l'état global.
class DetailScreen extends StatelessWidget {
  final String flightId;

  const DetailScreen({super.key, required this.flightId});

  @override
  /// Construit l'écran présentant les informations détaillées d'un vol sélectionné.
Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final flight = appState.flightById(flightId);

    if (flight == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Vol introuvable'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Retour',
            onPressed: () =>
                context.canPop() ? context.pop() : context.go('/'),
          ),
        ),
        body: const Center(child: Text('Ce vol n\'existe pas ou plus.')),
      );
    }

    final isTracked = appState.isTracked(flight.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(flight.flightNumber),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isTracked ? Icons.bookmark : Icons.bookmark_border,
              color: isTracked ? Colors.amber[800] : null,
            ),
            onPressed: () => appState.toggleTracked(flight.id),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: 'flight-icon-${flight.id}',
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: flight.color.withValues(alpha: 0.22),
                borderRadius: BorderRadius.circular(16),
              ),
              alignment: Alignment.center,
              child: Icon(flight.icon, size: 64, color: flight.color),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(label: Text(flight.type.label)),
              const SizedBox(width: 8),
              StatusBadge(status: flight.status),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            flight.airline,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SectionTitle(title: 'Itinéraire', icon: Icons.map),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Origine',
                            style: TextStyle(color: Colors.grey)),
                        Text(flight.origin,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Destination',
                            style: TextStyle(color: Colors.grey)),
                        Text(flight.destination,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SectionTitle(title: 'Informations', icon: Icons.info_outline),
          _InfoRow(icon: Icons.calendar_today, label: 'Date', value: flight.date),
          _InfoRow(icon: Icons.schedule, label: 'Heure', value: flight.time),
          _InfoRow(
              icon: Icons.door_front_door,
              label: 'Porte d\'embarquement',
              value: flight.gate),
          _InfoRow(
              icon: Icons.timer,
              label: 'Durée',
              value: '${flight.durationMinutes} min'),
          _InfoRow(
              icon: Icons.payments,
              label: 'Prix',
              value: '${flight.price.toStringAsFixed(0)} FCFA'),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: () => context.push('/book', extra: flight),
            icon: const Icon(Icons.airplane_ticket),
            label: const Text('Réserver ce vol'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  /// Construit l'écran présentant les informations détaillées d'un vol sélectionné.
Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
