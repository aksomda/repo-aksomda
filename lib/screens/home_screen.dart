import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/flight.dart';
import '../state/app_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/flight_card.dart';

/// Écran de liste des vols, avec recherche (numéro de vol, ville,
/// compagnie) et filtrage par type (Départ / Arrivée).
/// S'adapte à mobile (2 colonnes) et tablette (3 colonnes) : responsive.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  String _selectedFilter = 'Tous';

  static const _filters = ['Tous', 'Départ', 'Arrivée'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Flight> _filter(List<Flight> flights) {
    return flights.where((f) {
      final q = _query.toLowerCase();
      final matchesQuery = f.flightNumber.toLowerCase().contains(q) ||
          f.airline.toLowerCase().contains(q) ||
          f.origin.toLowerCase().contains(q) ||
          f.destination.toLowerCase().contains(q);
      final matchesFilter = _selectedFilter == 'Tous' ||
          f.type.label == _selectedFilter;
      return matchesQuery && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final filtered = _filter(appState.allFlights);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Aéroport de Donsin'),
        actions: [
          IconButton(
            tooltip: 'Changer le thème',
            icon: Icon(
              appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
            ),
            onPressed: () => appState.toggleTheme(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/book'),
        icon: const Icon(Icons.airplane_ticket),
        label: const Text('Réserver'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un vol, une ville, une compagnie…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final selected = filter == _selectedFilter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                );
              },
            ),
          ),
          Expanded(
            child: filtered.isEmpty
                ? const EmptyState(
                    icon: Icons.airplanemode_off,
                    message: 'Aucun vol ne correspond à votre recherche.',
                  )
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final isTablet = constraints.maxWidth >= 600;
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: isTablet ? 3 : 2,
                          mainAxisSpacing: 14,
                          crossAxisSpacing: 14,
                          childAspectRatio: isTablet ? 0.85 : 0.72,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final flight = filtered[index];
                          return FlightCard(
                            flight: flight,
                            isTracked: appState.isTracked(flight.id),
                            onTap: () => context.push('/flight/${flight.id}'),
                            onTrackTap: () =>
                                appState.toggleTracked(flight.id),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
