import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../logic/game_logic.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/responsive.dart';
import 'column_widget.dart';
import 'foundation_widget.dart';
import 'stock_widget.dart';
import 'toolbar_widget.dart';
import 'settings_dialog.dart';
import 'win_dialog.dart';

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard> {
  late GameNotifier _notifier;
  bool _winDialogShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final gameState = ref.watch(gameProvider(settings.suitCount));
    _notifier = ref.read(gameProvider(settings.suitCount).notifier);

    // Show win dialog once
    if (gameState.isWon && !_winDialogShown) {
      _winDialogShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showWinDialog(gameState);
      });
    }

    final bgColor = settings.darkMode
        ? const Color(0xFF1A2A1A)
        : const Color(0xFF2E7D32);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(gameState, settings.darkMode),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final sizing = computeCardSizing(
                    BoxConstraints(
                      maxWidth: constraints.maxWidth - sizing_stockWidth(constraints),
                    ),
                  );

                  return _buildMainArea(gameState, sizing, constraints);
                },
              ),
            ),
            ToolbarWidget(
              canUndo: gameState.canUndo,
              onSettings: () => showSettingsDialog(context),
              onNewGame: _startNewGame,
              onHint: () {
                _notifier.showHint();
                Future.delayed(const Duration(milliseconds: 1500), () {
                  if (mounted) _notifier.clearHint();
                });
              },
              onUndo: _notifier.undo,
            ),
          ],
        ),
      ),
    );
  }

  double sizing_stockWidth(BoxConstraints constraints) {
    return constraints.maxWidth * 0.1 + 16;
  }

  Widget _buildHeader(GameState state, bool darkMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Text(
            'Moves: ${state.moves}',
            style: TextStyle(
              color: darkMode ? Colors.white70 : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            'Score: ${state.score}',
            style: TextStyle(
              color: darkMode ? Colors.white70 : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainArea(
    GameState state,
    CardSizing sizing,
    BoxConstraints constraints,
  ) {
    // Recalculate sizing using full width minus stock area
    final stockWidth = constraints.maxWidth * 0.095;
    final tableauWidth = constraints.maxWidth - stockWidth - 16;
    final actualSizing = computeCardSizing(
      BoxConstraints(maxWidth: tableauWidth),
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tableau (10 columns)
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foundation row
                  FoundationWidget(
                    foundationCount: state.foundationCount,
                    sizing: actualSizing,
                  ),
                  const SizedBox(height: 8),
                  // Tableau columns
                  _buildTableau(state, actualSizing),
                ],
              ),
            ),
          ),
        ),
        // Stock panel (right side)
        Padding(
          padding: const EdgeInsets.only(top: 60, right: 8),
          child: StockWidget(
            dealsRemaining: state.stockDealsRemaining,
            canDeal: state.canDealFromStock,
            sizing: actualSizing,
            onTap: _notifier.dealFromStock,
          ),
        ),
      ],
    );
  }

  Widget _buildTableau(GameState state, CardSizing sizing) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int col = 0; col < 10; col++) ...[
          if (col > 0) SizedBox(width: sizing.columnGap),
          ColumnWidget(
            columnIndex: col,
            cards: state.columns[col],
            sizing: sizing,
            hintColumn: state.hintColumn,
            hintCard: state.hintCard,
            onDrop: (data, toCol) {
              _notifier.move(data.fromColumn, data.fromIndex, toCol);
            },
          ),
        ],
      ],
    );
  }

  void _startNewGame() {
    setState(() => _winDialogShown = false);
    final settings = ref.read(settingsProvider);
    _notifier.newGame(settings.suitCount);
  }

  void _showWinDialog(GameState state) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => WinDialog(
        score: state.score,
        moves: state.moves,
        onNewGame: _startNewGame,
      ),
    );
  }
}
