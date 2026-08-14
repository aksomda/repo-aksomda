import 'dart:convert';
import 'dart:html' as html;
import '../models/booking.dart';
import 'booking_storage.dart';
import 'exceptions/app_exceptions.dart';

/// Implémentation web de la sauvegarde JSON des réservations.
///
/// Le web n'a pas accès à un système de fichiers comme Android/iOS
/// (pas de `dart:io`, pas de `path_provider`). On utilise donc le
/// `localStorage` du navigateur pour stocker le même contenu JSON que
/// la version mobile/desktop (voir `json_storage_service_io.dart`),
/// sous la clé [_storageKey]. Le format des données (liste de
/// réservations encodées en JSON) reste identique sur toutes les
/// plateformes ; seul le support de stockage change.
class JsonStorageService implements JsonBookingStorage {
  static const String _storageKey = 'donsin_airport_reservations';

  @override
  Future<void> saveBooking(Booking booking) async {
    try {
      final current = await loadBookings();
      current.insert(0, {
        ...booking.toJson(),
        'dateEnregistrement': DateTime.now().toIso8601String(),
      });
      html.window.localStorage[_storageKey] =
          const JsonEncoder.withIndent('  ').convert(current);
    } on AppException {
      rethrow;
    } catch (e) {
      throw JsonFileWriteException(
        'Impossible d\'enregistrer la réservation dans le navigateur '
        '(localStorage indisponible ou plein) : $e',
      );
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadBookings() async {
    final raw = html.window.localStorage[_storageKey];
    if (raw == null || raw.trim().isEmpty) return [];

    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } on FormatException catch (e) {
      throw JsonFileCorruptedException(e.message);
    }
  }
}
