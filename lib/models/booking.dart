import 'flight.dart';

/// Représente une réservation effectuée via le formulaire.
/// Ce modèle est volontairement séparé de l'état applicatif
/// pour pouvoir être utilisé à la fois par `AppState` et par
/// les services de sauvegarde (`services/`).
class Booking {
  final String nomPassager;
  final String email;
  final String telephone;
  final int nombreBagages;
  final String destination;
  final String compagnie;
  final Flight? flight; // vol de référence, optionnel (pré-sélection)

  const Booking({
    required this.nomPassager,
    required this.email,
    required this.telephone,
    required this.nombreBagages,
    required this.destination,
    required this.compagnie,
    this.flight,
  });

  Map<String, dynamic> toJson() => {
        'nomPassager': nomPassager,
        'email': email,
        'telephone': telephone,
        'nombreBagages': nombreBagages,
        'destination': destination,
        'compagnie': compagnie,
        'volNumero': flight?.flightNumber,
      };
}
