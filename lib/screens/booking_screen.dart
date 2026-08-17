import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/flight.dart';
import '../services/booking_save_result.dart';
import '../state/app_state.dart';

/// Formulaire de réservation avec validation.
/// Champs : nom_passager, email, téléphone, nombre de bagages,
/// destination (liste déroulante) et compagnie (liste déroulante).
///
/// PERSISTANCE : à la soumission, la réservation est sauvegardée à la
/// fois dans un fichier JSON local (`services/json_storage_service.dart`)
/// et dans une base MySQL (`services/mysql_service.dart`). Les deux
/// canaux sont indépendants ; en cas d'échec de l'un ou l'autre (ou des
/// deux), un message d'erreur personnalisé et compréhensible est affiché
/// à l'utilisateur (voir `services/exceptions/app_exceptions.dart`).
class BookingScreen extends StatefulWidget {
  final Flight? preselectedFlight;

  const BookingScreen({super.key, this.preselectedFlight});

  /// Crée l'état mutable associé au formulaire de réservation.
  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomPassagerController = TextEditingController();
  final _emailController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _nombreBagagesController = TextEditingController(text: '1');

  static const _destinations = [
    'Ouagadougou',
    'Bobo-Dioulasso',
    'Bamako',
    'Niamey',
  ];

  static const _compagnies = [
    'Air Burkina',
    'Kangala Airlines',
    'Asky Airlines',
    'Mali Airlines',
    'Niger Airlines',
  ];

  String? _selectedDestination;
  String? _selectedCompagnie;
  bool _isSubmitting = false;

  @override
  /// Initialise les contrôleurs du formulaire et préremplit les champs lorsqu'un vol a été sélectionné.
void initState() {
    super.initState();
    // Pré-remplissage à partir du vol sélectionné depuis l'écran de détail
    // (passage de paramètre via `extra` dans GoRouter), si présent et si
    // les valeurs correspondent aux listes proposées.
    final flight = widget.preselectedFlight;
    if (flight != null) {
      final destinationCity = flight.type == FlightType.depart
          ? flight.destination
          : flight.origin;
      _selectedDestination = _destinations.firstWhere(
        (d) => destinationCity.toLowerCase().contains(d.toLowerCase()),
        orElse: () => _destinations.first,
      );
      _selectedCompagnie = _compagnies.contains(flight.airline)
          ? flight.airline
          : null;
    }
  }

  @override
  /// Libère les contrôleurs du formulaire afin d'éviter les fuites de ressources.
void dispose() {
    _nomPassagerController.dispose();
    _emailController.dispose();
    _telephoneController.dispose();
    _nombreBagagesController.dispose();
    super.dispose();
  }

  /// Construit un message personnalisé et compréhensible à partir du
  /// résultat de sauvegarde (succès total, échec partiel ou total).
  ({String message, Color color}) _feedbackFor(
    BookingSaveResult result,
    String nomPassager,
  ) {
    if (result.isFullSuccess) {
      return (
        message: 'Réservation confirmée pour $nomPassager et enregistrée '
            'avec succès (fichier local et base de données).',
        color: Colors.green,
      );
    }
    if (result.isFullFailure) {
      return (
        message: 'Votre réservation n\'a pas pu être sauvegardée. '
            '${result.jsonError!.message} ${result.databaseError!.message}',
        color: Colors.red,
      );
    }
    // Échec partiel : un seul des deux canaux a échoué.
    final failedMessage =
        result.jsonError?.message ?? result.databaseError?.message ?? '';
    return (
      message: 'Réservation enregistrée pour $nomPassager, mais avec un '
          'avertissement : $failedMessage',
      color: Colors.orange,
    );
  }

  /// Valide le formulaire, crée la réservation et lance sa sauvegarde dans les différents canaux configurés.
Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final booking = Booking(
      nomPassager: _nomPassagerController.text.trim(),
      email: _emailController.text.trim(),
      telephone: _telephoneController.text.trim(),
      nombreBagages: int.parse(_nombreBagagesController.text.trim()),
      destination: _selectedDestination!,
      compagnie: _selectedCompagnie!,
      flight: widget.preselectedFlight,
    );

    final result = await context.read<AppState>().addBooking(booking);

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    final feedback = _feedbackFor(result, booking.nomPassager);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: feedback.color,
        duration: const Duration(seconds: 5),
        content: Text(feedback.message),
      ),
    );

    // On revient à l'écran précédent uniquement si au moins une des deux
    // sauvegardes a réussi, pour ne pas faire perdre sa saisie à
    // l'utilisateur en cas d'échec total.
    if (!result.isFullFailure) {
      Navigator.of(context).pop();
    }
  }

  @override
  /// Construit le formulaire complet de réservation et ses contrôles de validation.
Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Réserver un vol'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Retour',
          onPressed: () => context.canPop() ? context.pop() : context.go('/'),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (widget.preselectedFlight != null)
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: ListTile(
                  leading: const Icon(Icons.flight),
                  title: Text('Vol pré-sélectionné : '
                      '${widget.preselectedFlight!.flightNumber}'),
                  subtitle: const Text(
                    'La destination et la compagnie ont été pré-remplies.',
                  ),
                ),
              ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nomPassagerController,
              decoration: const InputDecoration(
                labelText: 'Nom_passager',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le nom du passager est obligatoire.';
                }
                if (value.trim().length < 3) {
                  return 'Le nom doit contenir au moins 3 caractères.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Adresse email',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'L\'email est obligatoire.';
                }
                final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                if (!regex.hasMatch(value.trim())) {
                  return 'Entrez une adresse email valide.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telephoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                hintText: 'Ex : 70 12 34 56',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Le téléphone est obligatoire.';
                }
                final digits = value.trim().replaceAll(' ', '');
                if (digits.length < 8) {
                  return 'Entrez un numéro de téléphone valide.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedDestination,
              decoration: const InputDecoration(
                labelText: 'Destination',
                border: OutlineInputBorder(),
              ),
              items: _destinations
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedDestination = value),
              validator: (value) =>
                  value == null ? 'Veuillez choisir une destination.' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _selectedCompagnie,
              decoration: const InputDecoration(
                labelText: 'Compagnie',
                border: OutlineInputBorder(),
              ),
              items: _compagnies
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (value) =>
                  setState(() => _selectedCompagnie = value),
              validator: (value) =>
                  value == null ? 'Veuillez choisir une compagnie.' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nombreBagagesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Nombre de bagages',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Ce champ est obligatoire.';
                }
                final n = int.tryParse(value.trim());
                if (n == null || n < 0 || n > 10) {
                  return 'Entrez un nombre entre 0 et 10.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _isSubmitting ? null : submit,
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_circle),
              label: Text(
                _isSubmitting
                    ? 'Enregistrement en cours…'
                    : 'Confirmer la réservation',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
