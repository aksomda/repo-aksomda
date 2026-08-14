import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'router/app_router.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const DonsinAirportApp());
}

/// Widget racine de l'application.
/// Fournit l'état global (AppState) à tout l'arbre de widgets
/// via `provider`, et configure la navigation via GoRouter.
class DonsinAirportApp extends StatelessWidget {
  const DonsinAirportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, appState, _) {
          return MaterialApp.router(
            title: 'Aéroport de Donsin',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: appState.themeMode,
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
