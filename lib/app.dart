import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/game_board.dart';
import 'providers/settings_provider.dart';

class SpiderSolitaireApp extends ConsumerWidget {
  const SpiderSolitaireApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Spider Solitaire',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      home: const GameBoard(),
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    return ThemeData(
      colorSchemeSeed: const Color(0xFF2E7D32),
      brightness: brightness,
      useMaterial3: true,
    );
  }
}
