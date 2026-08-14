/// Point d'entrée unique du service de sauvegarde en base de données.
///
/// Comme pour `json_storage_service.dart`, la bonne implémentation est
/// choisie à la compilation :
/// - Par défaut (web) : [mysql_service_web.dart], qui ne tente aucune
///   connexion réseau bas niveau (impossible dans un navigateur) et
///   échoue proprement avec un message explicite.
/// - Si `dart:io` est disponible (Android, iOS, desktop) :
///   [mysql_service_io.dart], qui utilise `package:mysql_client` pour
///   se connecter réellement à un serveur MySQL.
///
/// Ce fichier garantit surtout que `package:mysql_client` (qui dépend
/// de `dart:io`) n'est **jamais importé** dans le bundle web, ce qui
/// empêcherait `flutter build web` de fonctionner.
export 'mysql_service_web.dart'
    if (dart.library.io) 'mysql_service_io.dart';
