import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Structure commune aux 3 onglets principaux (Vols, Suivis, Réglages),
/// avec une barre de navigation en bas d'écran. Widget réutilisable
/// branché sur le ShellRoute de GoRouter.
class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  int _indexFromLocation(String location) {
    if (location.startsWith('/tracked')) return 1;
    if (location.startsWith('/settings')) return 2;
    return 0;
  }

  void _onTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/tracked');
        break;
      case 2:
        context.go('/settings');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onTap(context, index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.flight),
            label: 'Vols',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark),
            label: 'Suivis',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Réglages',
          ),
        ],
      ),
    );
  }
}
