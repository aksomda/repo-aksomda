import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/flight.dart';
import '../screens/booking_screen.dart';
import '../screens/bookings_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/tracked_flights_screen.dart';
import '../widgets/main_scaffold.dart';

/// Configuration centralisée de la navigation avec GoRouter,
/// utilisant des routes nommées.
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      // ShellRoute : conserve la barre de navigation en bas d'écran
      // pour les 3 onglets principaux.
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/tracked',
            name: 'tracked',
            builder: (context, state) => const TrackedFlightsScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      // Écran de détail : passage de paramètre via l'URL (:id).
      GoRoute(
        path: '/flight/:id',
        name: 'flight-detail',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DetailScreen(flightId: id);
        },
      ),
      // Formulaire de réservation, avec vol optionnel pré-sélectionné
      // passé en paramètre (`extra`) depuis l'écran de détail.
      GoRoute(
        path: '/book',
        name: 'booking',
        builder: (context, state) {
          final flight = state.extra as Flight?;
          return BookingScreen(preselectedFlight: flight);
        },
      ),
      // Liste des réservations effectuées, accessible depuis l'écran
      // Réglages ("Réservations effectuées").
      GoRoute(
        path: '/reservations',
        name: 'reservations',
        builder: (context, state) => const BookingsScreen(),
      ),
    ],
  );
}
