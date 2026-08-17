/// Exception métier de base : toute exception levée par les services
/// de l'application (base de données, fichier JSON, validation) hérite
/// de cette classe. `message` est TOUJOURS rédigé pour être compris
/// directement par l'utilisateur final (pas de jargon technique),
/// tandis que `technicalDetails` garde la cause réelle pour les logs
/// ou le débogage (jamais affiché à l'utilisateur).
abstract class AppException implements Exception {
  final String message;
  final String? technicalDetails;

  const AppException(this.message, [this.technicalDetails]);

  /// Retourne le message utilisateur associé à l'exception.
  @override
  String toString() => message;
}

// ---------------------------------------------------------------------
// Exceptions liées à la base de données MySQL
// ---------------------------------------------------------------------

/// Le serveur MySQL est injoignable (mauvais hôte/port, pas de réseau,
/// serveur éteint...).
class DatabaseConnectionException extends AppException {
  const DatabaseConnectionException([String? details])
      : super(
          "Impossible de joindre le serveur de la base de données. "
          "Vérifiez votre connexion internet, puis réessayez. Si le "
          "problème persiste, contactez l'administrateur du système.",
          details,
        );
}

/// Identifiants MySQL refusés par le serveur.
class DatabaseAuthenticationException extends AppException {
  const DatabaseAuthenticationException([String? details])
      : super(
          "La connexion à la base de données a été refusée "
          "(identifiants incorrects). Contactez l'administrateur du "
          "système pour vérifier la configuration.",
          details,
        );
}

/// Le serveur met trop de temps à répondre.
class DatabaseTimeoutException extends AppException {
  const DatabaseTimeoutException([String? details])
      : super(
          "Le serveur met trop de temps à répondre. Vérifiez votre "
          "connexion et réessayez dans quelques instants.",
          details,
        );
}

/// La base de données demandée n'existe pas sur le serveur.
class DatabaseNotFoundException extends AppException {
  const DatabaseNotFoundException([String? details])
      : super(
          "La base de données de l'application est introuvable sur le "
          "serveur. Contactez l'administrateur du système.",
          details,
        );
}

/// La requête SQL a échoué (table manquante, doublon, colonne invalide…).
class DatabaseQueryException extends AppException {
  const DatabaseQueryException([String? details])
      : super(
          "Une erreur est survenue lors de l'enregistrement de votre "
          "réservation dans la base de données. Veuillez réessayer, et "
          "contactez le support si l'erreur se reproduit.",
          details,
        );
}

/// La connexion directe à MySQL depuis le navigateur n'est pas possible
/// (le web ne peut pas ouvrir de socket TCP brut vers un serveur MySQL).
/// Levée uniquement par la variante web du service de base de données.
class DatabaseUnavailableOnWebException extends AppException {
  const DatabaseUnavailableOnWebException([String? details])
      : super(
          "La sauvegarde en base de données n'est pas disponible depuis "
          "la version web de l'application (le navigateur ne peut pas se "
          "connecter directement à un serveur MySQL). Votre réservation "
          "reste enregistrée localement. Utilisez l'application Android "
          "ou iOS pour la sauvegarde en base de données.",
          details,
        );
}

// ---------------------------------------------------------------------
// Exceptions liées à la sauvegarde locale (fichier JSON)
// ---------------------------------------------------------------------

/// Écriture du fichier JSON impossible (stockage plein, permissions
/// refusées, appareil en lecture seule…).
class JsonFileWriteException extends AppException {
  const JsonFileWriteException([String? details])
      : super(
          "Impossible d'enregistrer votre réservation sur cet appareil. "
          "Vérifiez qu'il vous reste de l'espace de stockage disponible "
          "et que l'application a les autorisations nécessaires.",
          details,
        );
}

/// Lecture du fichier JSON impossible.
class JsonFileReadException extends AppException {
  const JsonFileReadException([String? details])
      : super(
          "Impossible de lire les réservations précédemment enregistrées "
          "sur cet appareil.",
          details,
        );
}

/// Le contenu du fichier JSON est corrompu ou dans un format inattendu.
class JsonFileCorruptedException extends AppException {
  const JsonFileCorruptedException([String? details])
      : super(
          "Le fichier de sauvegarde des réservations semble corrompu. "
          "Une nouvelle sauvegarde sera créée automatiquement, mais "
          "l'historique précédent n'a pas pu être récupéré.",
          details,
        );
}

// ---------------------------------------------------------------------
// Exceptions de validation métier (au-delà de la validation de formulaire)
// ---------------------------------------------------------------------

/// Une règle métier n'est pas respectée (ex : champ incohérent) alors
/// même que la validation du formulaire a été franchie.
class BookingValidationException extends AppException {
  const BookingValidationException(String message) : super(message);
}
