import 'package:donsin_airport_app/models/booking.dart';
import 'package:donsin_airport_app/services/booking_storage.dart';
import 'package:donsin_airport_app/services/exceptions/app_exceptions.dart';

/// Fausse implémentation de [JsonBookingStorage] utilisée dans les tests :
/// n'accède jamais au vrai système de fichiers. Peut être configurée pour
/// simuler un succès ou un échec, afin de tester les deux scénarios.
class FakeJsonStorage implements JsonBookingStorage {
  FakeJsonStorage({this.shouldThrow = false});

  final bool shouldThrow;
  final List<Booking> savedBookings = [];

  @override
  Future<void> saveBooking(Booking booking) async {
    if (shouldThrow) {
      throw const JsonFileWriteException('Erreur simulée pour les tests.');
    }
    savedBookings.add(booking);
  }

  @override
  Future<List<Map<String, dynamic>>> loadBookings() async {
    if (shouldThrow) {
      throw const JsonFileReadException('Erreur simulée pour les tests.');
    }
    return savedBookings.map((b) => b.toJson()).toList();
  }
}

/// Fausse implémentation de [DatabaseBookingStorage] utilisée dans les
/// tests : n'ouvre jamais de connexion réseau réelle.
class FakeDatabaseStorage implements DatabaseBookingStorage {
  FakeDatabaseStorage({this.shouldThrow = false});

  final bool shouldThrow;
  final List<Booking> savedBookings = [];
  bool closed = false;

  @override
  Future<void> saveBooking(Booking booking) async {
    if (shouldThrow) {
      throw const DatabaseConnectionException('Erreur simulée pour les tests.');
    }
    savedBookings.add(booking);
  }

  @override
  Future<void> close() async {
    closed = true;
  }
}
