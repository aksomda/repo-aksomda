import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:donsin_airport_app/screens/booking_screen.dart';
import 'package:donsin_airport_app/state/app_state.dart';
import '../fakes/fake_storage.dart';

void main() {
  Widget wrapWithApp(Widget child) {
    return ChangeNotifierProvider(
      create: (_) => AppState(
        jsonStorage: FakeJsonStorage(),
        databaseStorage: FakeDatabaseStorage(),
      ),
      child: MaterialApp(home: child),
    );
  }

  testWidgets(
    'affiche des erreurs de validation quand le formulaire est vide',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(const BookingScreen()));

      // Soumettre le formulaire sans rien saisir.
      await tester.tap(find.text('Confirmer la réservation'));
      await tester.pumpAndSettle();

      expect(find.text('Le nom du passager est obligatoire.'), findsOneWidget);
      expect(find.text('L\'email est obligatoire.'), findsOneWidget);
      expect(find.text('Le téléphone est obligatoire.'), findsOneWidget);
      expect(find.text('Veuillez choisir une destination.'), findsOneWidget);
      expect(find.text('Veuillez choisir une compagnie.'), findsOneWidget);
    },
  );

  testWidgets(
    'affiche une erreur pour un email mal formé',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(const BookingScreen()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Adresse email'),
        'email-invalide',
      );
      await tester.tap(find.text('Confirmer la réservation'));
      await tester.pumpAndSettle();

      expect(find.text('Entrez une adresse email valide.'), findsOneWidget);
    },
  );

  testWidgets(
    'propose bien les 4 destinations et les 5 compagnies demandées',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(const BookingScreen()));

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Destination'));
      await tester.pumpAndSettle();
      for (final destination in [
        'Ouagadougou',
        'Bobo-Dioulasso',
        'Bamako',
        'Niamey',
      ]) {
        expect(find.text(destination), findsWidgets);
      }
      await tester.pageBack();
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Compagnie'));
      await tester.pumpAndSettle();
      for (final compagnie in [
        'Air Burkina',
        'Kangala Airlines',
        'Asky Airlines',
        'Mali Airlines',
        'Niger Airline',
      ]) {
        expect(find.text(compagnie), findsWidgets);
      }
    },
  );

  testWidgets(
    'affiche un message de succès personnalisé quand tout est bien enregistré',
    (tester) async {
      await tester.pumpWidget(wrapWithApp(const BookingScreen()));

      await tester.enterText(
        find.widgetWithText(TextFormField, 'Nom_passager'),
        'Awa Traoré',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Adresse email'),
        'awa@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Téléphone'),
        '70123456',
      );

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Destination'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bamako').last);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(DropdownButtonFormField<String>, 'Compagnie'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Air Burkina').last);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmer la réservation'));
      await tester.pump(); // affiche l'indicateur de chargement
      await tester.pumpAndSettle();

      expect(find.textContaining('enregistrée avec succès'), findsOneWidget);
    },
  );
}
