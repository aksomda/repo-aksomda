import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donsin_airport_app/models/flight.dart';

void main() {
  group('FlightTypeLabel', () {
    test('renvoie "Départ" pour FlightType.depart', () {
      expect(FlightType.depart.label, 'Départ');
    });

    test('renvoie "Arrivée" pour FlightType.arrivee', () {
      expect(FlightType.arrivee.label, 'Arrivée');
    });
  });

  group('FlightStatusLabel', () {
    test('associe le bon libellé à chaque statut', () {
      expect(FlightStatus.aLHeure.label, "À l'heure");
      expect(FlightStatus.retarde.label, 'Retardé');
      expect(FlightStatus.embarquement.label, 'Embarquement');
      expect(FlightStatus.decolle.label, 'Décollé');
      expect(FlightStatus.annule.label, 'Annulé');
    });

    test('associe une couleur distincte à chaque statut', () {
      expect(FlightStatus.aLHeure.color, Colors.green);
      expect(FlightStatus.retarde.color, Colors.orange);
      expect(FlightStatus.embarquement.color, Colors.blue);
      expect(FlightStatus.decolle.color, Colors.grey);
      expect(FlightStatus.annule.color, Colors.red);
    });
  });

  group('Flight', () {
    test('construit correctement un vol avec toutes ses propriétés', () {
      const flight = Flight(
        id: 'test-1',
        flightNumber: 'AH 9999',
        airline: 'Air Burkina',
        origin: 'Donsin (OUA)',
        destination: 'Bamako (BKO)',
        type: FlightType.depart,
        date: '01 Janvier 2027',
        time: '09:00',
        gate: 'A1',
        status: FlightStatus.aLHeure,
        icon: Icons.flight_takeoff,
        color: Colors.blue,
        durationMinutes: 90,
        price: 100000,
      );

      expect(flight.flightNumber, 'AH 9999');
      expect(flight.type, FlightType.depart);
      expect(flight.durationMinutes, 90);
    });
  });
}
