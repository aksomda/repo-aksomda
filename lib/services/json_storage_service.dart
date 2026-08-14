/// Point d'entrée unique du service de sauvegarde JSON.
///
/// La bonne implémentation est choisie **à la compilation**, selon la
/// plateforme cible, grâce à un export conditionnel Dart :
/// - Par défaut (web) : [json_storage_service_web.dart], qui utilise le
///   `localStorage` du navigateur car `dart:io` n'existe pas sur le web.
/// - Si `dart:io` est disponible (Android, iOS, desktop) :
///   [json_storage_service_io.dart], qui écrit un vrai fichier
///   `reservations.json` via `path_provider`.
///
/// Les deux implémentations exposent la même classe `JsonStorageService`
/// (implémentant `JsonBookingStorage`), donc le reste de l'application
/// (`AppState`) n'a pas besoin de savoir laquelle est utilisée.
export 'json_storage_service_web.dart'
    if (dart.library.io) 'json_storage_service_io.dart';
