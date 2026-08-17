import 'package:flutter/material.dart';
import '../models/flight.dart';
import 'status_badge.dart';

/// Widget réutilisable représentant un vol dans une liste/grille.
/// Utilisé dans HomeScreen et TrackedFlightsScreen.
class FlightCard extends StatelessWidget {
  final Flight flight;
  final bool isTracked;
  final VoidCallback onTap;
  final VoidCallback onTrackTap;

  const FlightCard({
    super.key,
    required this.flight,
    required this.isTracked,
    required this.onTap,
    required this.onTrackTap,
  });

  @override
  /// Construit la carte d'un vol avec son statut, ses informations principales et les actions disponibles.
Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              children: [
                Hero(
                  tag: 'flight-icon-${flight.id}',
                  child: Container(
                    height: 90,
                    color: flight.color.withValues(alpha: 0.22),
                    alignment: Alignment.center,
                    child: Icon(flight.icon, size: 40, color: flight.color),
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: Icon(
                      isTracked ? Icons.bookmark : Icons.bookmark_border,
                      color: isTracked ? Colors.amber[800] : Colors.white,
                    ),
                    onPressed: onTrackTap,
                  ),
                ),
                Positioned(
                  bottom: 4,
                  left: 8,
                  child: Chip(
                    label: Text(
                      flight.type.label,
                      style: const TextStyle(fontSize: 11),
                    ),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flight.flightNumber,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    flight.type == FlightType.depart
                        ? flight.destination
                        : flight.origin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  StatusBadge(status: flight.status),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14),
                      const SizedBox(width: 4),
                      Text(flight.time, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: 10),
                      const Icon(Icons.door_front_door, size: 14),
                      const SizedBox(width: 4),
                      Text('Porte ${flight.gate}',
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
