import 'exceptions/app_exceptions.dart';

/// Résultat d'une tentative de sauvegarde d'une réservation.
/// Les deux canaux de sauvegarde (fichier JSON local et base MySQL)
/// sont indépendants : l'un peut réussir alors que l'autre échoue.
/// L'écran de réservation utilise ce résultat pour informer
/// l'utilisateur avec un message précis et compréhensible.
class BookingSaveResult {
  final AppException? jsonError;
  final AppException? databaseError;

  const BookingSaveResult({this.jsonError, this.databaseError});

  bool get jsonSaved => jsonError == null;
  bool get databaseSaved => databaseError == null;
  bool get isFullSuccess => jsonSaved && databaseSaved;
  bool get isFullFailure => !jsonSaved && !databaseSaved;
}
