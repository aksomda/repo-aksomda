import '../models/booking.dart';

/// Interface d'un service capable de sauvegarder/charger des réservations
/// dans un fichier local. Permet d'injecter une fausse implémentation
/// dans les tests, sans toucher au système de fichiers réel.
abstract class JsonBookingStorage {
  /// Enregistre une réservation dans le stockage local.
  Future<void> saveBooking(Booking booking);

  /// Charge les réservations déjà enregistrées depuis le stockage local.
  Future<List<Map<String, dynamic>>> loadBookings();
}

/// Interface d'un service capable de sauvegarder des réservations dans
/// une base de données distante. Permet d'injecter une fausse
/// implémentation dans les tests, sans ouvrir de connexion réseau réelle.
abstract class DatabaseBookingStorage {
  /// Enregistre une réservation dans le stockage de base de données.
  Future<void> saveBooking(Booking booking);

  /// Ferme les ressources utilisées par le stockage de base de données.
  Future<void> close();
}
