import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/booking.dart';
import 'booking_storage.dart';
import 'exceptions/app_exceptions.dart';

/// Sauvegarde les réservations dans un fichier JSON local
/// (`reservations.json`), stocké dans le répertoire de documents de
/// l'application (`getApplicationDocumentsDirectory()` du package
/// `path_provider`). Ce fichier survit aux redémarrages de l'app mais
/// reste propre à l'appareil (il n'est pas synchronisé entre appareils).
class JsonStorageService implements JsonBookingStorage {
  static const String _fileName = 'reservations.json';

  Future<File> _getFile() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      return File('${directory.path}/$_fileName');
    } on MissingPlatformDirectoryException catch (e) {
      throw JsonFileWriteException(e.toString());
    } catch (e) {
      throw JsonFileWriteException(e.toString());
    }
  }

  @override
  Future<void> saveBooking(Booking booking) async {
    final file = await _getFile();
    List<dynamic> current = [];

    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          current = jsonDecode(content) as List<dynamic>;
        }
      } on FormatException catch (e) {
        // Fichier illisible : on repart d'une liste vide plutôt que
        // de bloquer l'utilisateur, mais on le prévient.
        current = [];
        throw JsonFileCorruptedException(e.message);
      } on FileSystemException catch (e) {
        throw JsonFileReadException(e.message);
      }
    }

    current.insert(0, {
      ...booking.toJson(),
      'dateEnregistrement': DateTime.now().toIso8601String(),
    });

    try {
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(current),
      );
    } on FileSystemException catch (e) {
      throw JsonFileWriteException(e.message);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadBookings() async {
    final file = await _getFile();
    if (!await file.exists()) return [];

    try {
      final content = await file.readAsString();
      if (content.trim().isEmpty) return [];
      final decoded = jsonDecode(content) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } on FormatException catch (e) {
      throw JsonFileCorruptedException(e.message);
    } on FileSystemException catch (e) {
      throw JsonFileReadException(e.message);
    }
  }
}
