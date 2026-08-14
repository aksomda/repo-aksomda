import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:donsin_airport_app/state/app_state.dart';
import '../fakes/fake_storage.dart';

void main() {
  group('Thème', () {
    test('le thème par défaut est clair', () {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );
      expect(appState.themeMode, ThemeMode.light);
      expect(appState.isDarkMode, isFalse);
    });

    test('toggleTheme() bascule entre clair et sombre', () {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );
      appState.toggleTheme();
      expect(appState.themeMode, ThemeMode.dark);

      appState.toggleTheme();
      expect(appState.themeMode, ThemeMode.light);
    });
  });

  group('Vols suivis', () {
    test('aucun vol suivi au démarrage', () {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );
      expect(appState.trackedFlights, isEmpty);
    });

    test('toggleTracked() ajoute puis retire un vol suivi', () {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );
      final firstFlightId = appState.allFlights.first.id;

      appState.toggleTracked(firstFlightId);
      expect(appState.isTracked(firstFlightId), isTrue);
      expect(appState.trackedFlights.length, 1);

      appState.toggleTracked(firstFlightId);
      expect(appState.isTracked(firstFlightId), isFalse);
      expect(appState.trackedFlights, isEmpty);
    });
  });

  group('flightById', () {
    test('retrouve un vol existant par son identifiant', () {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );
      final expected = appState.allFlights.first;
      final found = appState.flightById(expected.id);
      expect(found, isNotNull);
      expect(found!.flightNumber, expected.flightNumber);
    });

    test('retourne null pour un identifiant inexistant', () {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );
      expect(appState.flightById('id-inexistant'), isNull);
    });
  });

  group('Réservations (Booking) — sauvegarde JSON + MySQL', () {
    test('addBooking() ajoute la réservation en mémoire immédiatement', () async {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );

      expect(appState.bookings, isEmpty);

      await appState.addBooking(const Booking(
        nomPassager: 'Jean Compaoré',
        email: 'jean@example.com',
        telephone: '70123456',
        nombreBagages: 2,
        destination: 'Bamako',
        compagnie: 'Air Burkina',
      ));

      expect(appState.bookings.length, 1);
      expect(appState.bookings.first.nomPassager, 'Jean Compaoré');
    });

    test('quand les deux sauvegardes réussissent, le résultat est un succès complet', () async {
      final jsonStorage = FakeJsonStorage();
      final dbStorage = FakeDatabaseStorage();
      final appState = AppState(jsonStorage: jsonStorage, databaseStorage: dbStorage);

      final result = await appState.addBooking(const Booking(
        nomPassager: 'Awa Traoré',
        email: 'awa@example.com',
        telephone: '70000000',
        nombreBagages: 1,
        destination: 'Niamey',
        compagnie: 'Niger Airline',
      ));

      expect(result.isFullSuccess, isTrue);
      expect(jsonStorage.savedBookings.length, 1);
      expect(dbStorage.savedBookings.length, 1);
    });

    test('quand seul le stockage JSON échoue, le résultat signale une réussite partielle', () async {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(shouldThrow: true),
        databaseStorage: FakeDatabaseStorage(),
      );

      final result = await appState.addBooking(const Booking(
        nomPassager: 'Boureima Sawadogo',
        email: 'boureima@example.com',
        telephone: '70000001',
        nombreBagages: 0,
        destination: 'Ouagadougou',
        compagnie: 'Asky Airlines',
      ));

      expect(result.jsonSaved, isFalse);
      expect(result.databaseSaved, isTrue);
      expect(result.isFullFailure, isFalse);
      expect(
        result.jsonError!.message,
        contains('Impossible d\'enregistrer votre réservation'),
      );
    });

    test('quand les deux sauvegardes échouent, le résultat est un échec complet', () async {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(shouldThrow: true),
        databaseStorage: FakeDatabaseStorage(shouldThrow: true),
      );

      final result = await appState.addBooking(const Booking(
        nomPassager: 'Fatimata Ouédraogo',
        email: 'fatimata@example.com',
        telephone: '70000002',
        nombreBagages: 3,
        destination: 'Bobo-Dioulasso',
        compagnie: 'Mali Airlines',
      ));

      expect(result.isFullFailure, isTrue);
      expect(
        result.databaseError!.message,
        contains('Impossible de joindre le serveur'),
      );
    });

    test('les réservations les plus récentes sont en tête de liste', () async {
      final appState = AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      );

      await appState.addBooking(const Booking(
        nomPassager: 'Passager 1',
        email: 'p1@example.com',
        telephone: '70000001',
        nombreBagages: 1,
        destination: 'Ouagadougou',
        compagnie: 'Asky Airlines',
      ));
      await appState.addBooking(const Booking(
        nomPassager: 'Passager 2',
        email: 'p2@example.com',
        telephone: '70000002',
        nombreBagages: 0,
        destination: 'Niamey',
        compagnie: 'Niger Airline',
      ));

      expect(appState.bookings.first.nomPassager, 'Passager 2');
      expect(appState.bookings.last.nomPassager, 'Passager 1');
    });
  });
}
