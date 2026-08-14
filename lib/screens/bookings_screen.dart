import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';

/// Écran listant toutes les réservations effectuées durant la session
/// (stockées en mémoire dans `AppState.bookings`, et sauvegardées en
/// parallèle en JSON/MySQL par `AppState.addBooking`).
class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookings = context.watch<AppState>().bookings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réservations effectuées'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: bookings.isEmpty
          ? const EmptyState(
              icon: Icons.airplane_ticket_outlined,
              message: 'Vous n\'avez encore effectué aucune réservation.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: bookings.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                return _BookingCard(booking: bookings[index]);
              },
            ),
    );
  }
}

class _BookingCard extends StatelessWidget {
  final Booking booking;

  const _BookingCard({required this.booking});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.nomPassager,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        booking.email,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (booking.flight != null)
                  Chip(label: Text(booking.flight!.flightNumber)),
              ],
            ),
            const Divider(height: 24),
            _InfoLine(icon: Icons.phone, label: 'Téléphone', value: booking.telephone),
            _InfoLine(
                icon: Icons.flight_takeoff,
                label: 'Destination',
                value: booking.destination),
            _InfoLine(
                icon: Icons.airlines, label: 'Compagnie', value: booking.compagnie),
            _InfoLine(
                icon: Icons.luggage,
                label: 'Bagages',
                value: '${booking.nombreBagages}'),
          ],
        ),
      ),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoLine({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
