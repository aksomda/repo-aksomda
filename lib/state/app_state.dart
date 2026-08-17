import 'package:flutter/material.dart';
import '../data/flights_data.dart';
import '../models/booking.dart';
import '../models/flight.dart';
import '../services/booking_save_result.dart';
import '../services/booking_storage.dart';
import '../services/exceptions/app_exceptions.dart';
import '../services/json_storage_service.dart';
import '../services/mysql_service.dart';

export '../models/booking.dart' show Booking;

/// État global partagé de l'application : thème, vols suivis (favoris)
/// et réservations effectuées. Utilisé avec `provider` pour être
/// accessible depuis tous les écrans.
///
/// Les services de sauvegarde (`JsonBookingStorage`, `DatabaseBookingStorage`)
/// sont injectés via le constructeur : en production, les implémentations
/// réelles (`JsonStorageService`, `MySqlService`) sont utilisées par défaut ;
/// dans les tests, on peut injecter de fausses implémentations pour éviter
/// tout accès réel au disque ou au réseau.
class AppState extends ChangeNotifier {
  AppState({
    JsonBookingStorage? jsonStorage,
    DatabaseBookingStorage? databaseStorage,
  })  : _jsonStorage = jsonStorage ?? JsonStorageService(),
        _databaseStorage = databaseStorage ?? MySqlService();

  final JsonBookingStorage _jsonStorage;
  final DatabaseBookingStorage _databaseStorage;

  ThemeMode _themeMode = ThemeMode.light;
  final Set<String> _trackedIds = {};
  final List<Booking> _bookings = [];

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  List<Flight> get allFlights => flightsData;

  List<Flight> get trackedFlights =>
      allFlights.where((f) => _trackedIds.contains(f.id)).toList();

  List<Booking> get bookings => List.unmodifiable(_bookings);

  /// Bascule entre le thème clair et le thème sombre puis notifie les widgets abonnés.
void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  /// Indique si le vol identifié par [id] figure actuellement parmi les vols suivis.
bool isTracked(String id) => _trackedIds.contains(id);

  /// Ajoute ou retire un vol de la liste des vols suivis et notifie les widgets abonnés.
void toggleTracked(String id) {
    if (_trackedIds.contains(id)) {
      _trackedIds.remove(id);
    } else {
      _trackedIds.add(id);
    }
    notifyListeners();
  }

  /// Recherche un vol par son identifiant et retourne `null` s'il est introuvable.
Flight? flightById(String id) {
    try {
      return allFlights.firstWhere((f) => f.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Enregistre une réservation :
  /// 1. Elle est immédiatement ajoutée à la liste en mémoire (pour un
  ///    affichage instantané dans l'app, ex. écran Réglages).
  /// 2. Elle est sauvegardée en parallèle dans le fichier JSON local et
  ///    dans la base MySQL. Les deux sauvegardes sont indépendantes :
  ///    l'échec de l'une n'empêche pas l'autre.
  ///
  /// Retourne un [BookingSaveResult] détaillant le succès ou l'échec de
  /// chaque canal de sauvegarde, avec des exceptions personnalisées
  /// ([AppException]) portant un message compréhensible par l'utilisateur.
Future<BookingSaveResult> addBooking(Booking booking) async {
    _bookings.insert(0, booking);
    notifyListeners();

    AppException? jsonError;
    AppException? databaseError;

    try {
      await _jsonStorage.saveBooking(booking);
    } on AppException catch (e) {
      jsonError = e;
    } catch (e) {
      jsonError = JsonFileWriteException(e.toString());
    }

    try {
      await _databaseStorage.saveBooking(booking);
    } on AppException catch (e) {
      databaseError = e;
    } catch (e) {
      databaseError = DatabaseQueryException(e.toString());
    }

    return BookingSaveResult(jsonError: jsonError, databaseError: databaseError);
  }

  @override
  /// Libère les ressources associées au service de persistance avant la destruction de l'état global.
void dispose() {
    _databaseStorage.close();
    super.dispose();
  }
}
