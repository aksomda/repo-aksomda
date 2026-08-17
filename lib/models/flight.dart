import 'package:flutter/material.dart';

/// Modèle représentant un vol à l'aéroport international de Donsin.
/// Aucune donnée n'est écrite en dur dans les widgets : toutes les
/// instances de [Flight] viennent de `data/flights_data.dart` ou sont
/// créées dynamiquement via le formulaire de réservation.
class Flight {
  final String id;
  final String flightNumber;
  final String airline;
  final String origin;
  final String destination;
  final FlightType type; // Départ ou Arrivée
  final String date; // format lisible : ex "12 Août 2026"
  final String time; // ex "14:30"
  final String gate;
  final FlightStatus status;
  final IconData icon;
  final Color color;
  final int durationMinutes;
  final double price; // en FCFA

  const Flight({
    required this.id,
    required this.flightNumber,
    required this.airline,
    required this.origin,
    required this.destination,
    required this.type,
    required this.date,
    required this.time,
    required this.gate,
    required this.status,
    required this.icon,
    required this.color,
    required this.durationMinutes,
    required this.price,
  });
}

enum FlightType { depart, arrivee }

enum FlightStatus { aLHeure, retarde, embarquement, decolle, annule }

extension FlightTypeLabel on FlightType {
  /// Retourne le libellé français correspondant au type de vol.
  String get label => this == FlightType.depart ? 'Départ' : 'Arrivée';
}

extension FlightStatusLabel on FlightStatus {
  /// Retourne le libellé français correspondant au statut du vol.
  String get label {
    switch (this) {
      case FlightStatus.aLHeure:
        return 'À l\'heure';
      case FlightStatus.retarde:
        return 'Retardé';
      case FlightStatus.embarquement:
        return 'Embarquement';
      case FlightStatus.decolle:
        return 'Décollé';
      case FlightStatus.annule:
        return 'Annulé';
    }
  }

  /// Retourne la couleur d'affichage associée au statut du vol.
  Color get color {
    switch (this) {
      case FlightStatus.aLHeure:
        return Colors.green;
      case FlightStatus.retarde:
        return Colors.orange;
      case FlightStatus.embarquement:
        return Colors.blue;
      case FlightStatus.decolle:
        return Colors.grey;
      case FlightStatus.annule:
        return Colors.red;
    }
  }
}
