import 'package:flutter_test/flutter_test.dart';
import 'package:donsin_airport_app/services/exceptions/app_exceptions.dart';

void main() {
  group('Exceptions personnalisées', () {
    test('chaque exception porte un message non technique et non vide', () {
      final exceptions = <AppException>[
        const DatabaseConnectionException('SocketException: refused'),
        const DatabaseAuthenticationException('Access denied for user'),
        const DatabaseTimeoutException('TimeoutException after 6s'),
        const DatabaseNotFoundException('Unknown database'),
        const DatabaseQueryException('Duplicate entry'),
        const JsonFileWriteException('No space left on device'),
        const JsonFileReadException('Permission denied'),
        const JsonFileCorruptedException('Unexpected character'),
        const BookingValidationException('Champ incohérent.'),
      ];

      for (final exception in exceptions) {
        // Le message utilisateur ne doit jamais être vide...
        expect(exception.message, isNotEmpty);
        // ...ni contenir de jargon technique brut (noms de classes
        // d'exceptions Dart/Java, stack traces, etc.).
        expect(exception.message, isNot(contains('Exception:')));
        expect(exception.message, isNot(contains('SocketException')));
        expect(exception.message, isNot(contains('TimeoutException')));
      }
    });

    test('toString() renvoie directement le message convivial', () {
      const exception = DatabaseConnectionException('détail technique');
      expect(exception.toString(), exception.message);
      expect(exception.toString(), isNot(contains('détail technique')));
    });

    test('les détails techniques restent accessibles séparément (pour les logs)', () {
      const exception = JsonFileWriteException('errno=28: No space left');
      expect(exception.technicalDetails, 'errno=28: No space left');
    });

    test('DatabaseAuthenticationException distingue un problème d\'identifiants', () {
      const exception = DatabaseAuthenticationException();
      expect(exception.message, contains('identifiants'));
    });

    test('DatabaseTimeoutException invite à réessayer', () {
      const exception = DatabaseTimeoutException();
      expect(exception.message.toLowerCase(), contains('réessay'));
    });
  });
}
