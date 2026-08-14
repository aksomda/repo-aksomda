import '../models/booking.dart';
import 'booking_storage.dart';
import 'exceptions/app_exceptions.dart';

/// Implémentation web du canal de sauvegarde en base de données.
///
/// Un navigateur ne peut pas ouvrir de connexion TCP brute vers un
/// serveur MySQL (ni `dart:io`, ni le package `mysql_client`, qui
/// dépend de sockets bas niveau, ne sont disponibles sur le web). Une
/// vraie application web passerait par une API HTTP intermédiaire.
///
/// Ce projet étant pédagogique, cette version web échoue proprement
/// avec un message clair plutôt que d'empêcher l'application de
/// compiler : la réservation reste malgré tout enregistrée via le
/// canal JSON (voir `json_storage_service_web.dart`), et l'utilisateur
/// est informé que seule la sauvegarde base de données n'a pas pu
/// avoir lieu (voir la gestion de succès partiel dans `BookingScreen`).
class MySqlService implements DatabaseBookingStorage {
  MySqlService();

  @override
  Future<void> saveBooking(Booking booking) async {
    throw const DatabaseUnavailableOnWebException();
  }

  @override
  Future<void> close() async {
    // Rien à fermer : aucune connexion n'est jamais ouverte sur le web.
  }
}
