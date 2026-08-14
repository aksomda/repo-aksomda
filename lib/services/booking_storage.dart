import '../models/booking.dart';

/// Interface d'un service capable de sauvegarder/charger des réservations
/// dans un fichier local. Permet d'injecter une fausse implémentation
/// dans les tests, sans toucher au système de fichiers réel.
abstract class JsonBookingStorage {
  Future<void> saveBooking(Booking booking);
  Future<List<Map<String, dynamic>>> loadBookings();
}

/// Interface d'un service capable de sauvegarder des réservations dans
/// une base de données distante. Permet d'injecter une fausse
/// implémentation dans les tests, sans ouvrir de connexion réseau réelle.
abstract class DatabaseBookingStorage {
  Future<void> saveBooking(Booking booking);
  Future<void> close();
}
