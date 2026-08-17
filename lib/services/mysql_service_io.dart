import 'dart:async';
import 'dart:io';
import 'package:mysql_client/mysql_client.dart';
import 'package:mysql_client/exception.dart';
import '../models/booking.dart';
import 'booking_storage.dart';
import 'exceptions/app_exceptions.dart';

/// Paramètres de connexion au serveur MySQL.
///
/// ⚠️ À ADAPTER avant utilisation réelle : par défaut, ces valeurs
/// pointent vers un serveur MySQL local de développement. Dans une
/// vraie application mobile, il est fortement déconseillé d'intégrer
/// des identifiants de base de données directement dans le code client
/// (ils seraient visibles dans l'APK) — on passerait normalement par
/// une API backend intermédiaire. Ce projet expose la connexion directe
/// uniquement à des fins pédagogiques.
class MySqlConfig {
  final String host;
  final int port;
  final String userName;
  final String password;
  final String databaseName;
  final Duration connectionTimeout;

  const MySqlConfig({
    this.host = '10.0.2.2', // hôte de la machine depuis l'émulateur Android
    this.port = 3306,
    this.userName = 'root',
    this.password = '',
    this.databaseName = 'donsin_airport',
    this.connectionTimeout = const Duration(seconds: 6),
  });
}

/// Sauvegarde les réservations dans la table `reservations` d'une base
/// MySQL. Voir `sql/schema.sql` pour la structure de la table à créer
/// au préalable sur le serveur.
class MySqlService implements DatabaseBookingStorage {
  final MySqlConfig config;
  MySQLConnection? connection;

  MySqlService({this.config = const MySqlConfig()});

  /// Ouvre ou réutilise une connexion MySQL et vérifie que la table des réservations existe.
Future<MySQLConnection> connect() async {
    if (connection != null && connection!.connected) {
      return connection!;
    }

    try {
      final connection = await MySQLConnection.createConnection(
        host: config.host,
        port: config.port,
        userName: config.userName,
        password: config.password,
        databaseName: config.databaseName,
      );
      await connection.connect(
        timeoutMs: config.connectionTimeout.inMilliseconds,
      );
      connection = connection;
      await ensureTableExists(connection);
      return connection;
    } on TimeoutException catch (e) {
      throw DatabaseTimeoutException(e.toString());
    } on SocketException catch (e) {
      throw DatabaseConnectionException(e.message);
    } on MySQLServerException catch (e) {
      // mysql_client expose un code d'erreur MySQL standard :
      // 1045 = accès refusé (mauvais identifiants)
      // 1049 = base de données inconnue
      if (e.errorCode == 1045) {
        throw DatabaseAuthenticationException(e.message);
      }
      if (e.errorCode == 1049) {
        throw DatabaseNotFoundException(e.message);
      }
      throw DatabaseQueryException(e.message);
    } catch (e) {
      throw DatabaseConnectionException(e.toString());
    }
  }

  /// Crée la table `reservations` si elle n'existe pas encore sur la base cible.
Future<void> ensureTableExists(MySQLConnection connection) async {
    try {
      await connection.execute('''
        CREATE TABLE IF NOT EXISTS reservations (
          id INT AUTO_INCREMENT PRIMARY KEY,
          nom_passager VARCHAR(255) NOT NULL,
          email VARCHAR(255) NOT NULL,
          telephone VARCHAR(50) NOT NULL,
          nombre_bagages INT NOT NULL,
          destination VARCHAR(100) NOT NULL,
          compagnie VARCHAR(100) NOT NULL,
          vol_numero VARCHAR(50),
          date_reservation DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
        )
      ''');
    } catch (e) {
      throw DatabaseQueryException(e.toString());
    }
  }

  @override
  /// Insère une réservation dans la table MySQL `reservations` avec des paramètres liés.
Future<void> saveBooking(Booking booking) async {
    final connection = await connect();

    try {
      await connection.execute(
        'INSERT INTO reservations '
        '(nom_passager, email, telephone, nombre_bagages, destination, compagnie, vol_numero) '
        'VALUES (:nom, :email, :telephone, :bagages, :destination, :compagnie, :vol)',
        {
          'nom': booking.nomPassager,
          'email': booking.email,
          'telephone': booking.telephone,
          'bagages': booking.nombreBagages,
          'destination': booking.destination,
          'compagnie': booking.compagnie,
          'vol': booking.flight?.flightNumber,
        },
      );
    } on MySQLServerException catch (e) {
      throw DatabaseQueryException(e.message);
    } on SocketException catch (e) {
      throw DatabaseConnectionException(e.message);
    } on TimeoutException catch (e) {
      throw DatabaseTimeoutException(e.toString());
    } catch (e) {
      throw DatabaseQueryException(e.toString());
    }
  }

  @override
  /// Ferme proprement la connexion MySQL active et réinitialise sa référence.
Future<void> close() async {
    await connection?.close();
    connection = null;
  }
}
