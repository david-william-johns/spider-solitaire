import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/game_state.dart';
import '../providers/game_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/responsive.dart';
import '../utils/sound_manager.dart';
import 'card_widget.dart';
import 'column_widget.dart';
import 'foundation_widget.dart';
import 'stock_widget.dart';
import 'toolbar_widget.dart';
import 'settings_dialog.dart';
import 'win_dialog.dart';

// Describes one card's animation path: from stock → column top.
class _DealTarget {
  final Offset from;
  final Offset to;
  final double startT; // normalised 0.0–1.0 when this card starts moving
  final double endT;   // normalised 0.0–1.0 when this card arrives
  const _DealTarget({
    required this.from,
    required this.to,
    required this.startT,
    required this.endT,
  });
}

class GameBoard extends ConsumerStatefulWidget {
  const GameBoard({super.key});

  @override
  ConsumerState<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends ConsumerState<GameBoard>
    with SingleTickerProviderStateMixin {
  late GameNotifier _notifier;
  bool _winDialogShown = false;

  // ── Deal animation ────────────────────────────────────────────────────────
  late final AnimationController _dealController;
  bool _isDealAnimating = false;
  List<_DealTarget> _dealTargets = [];

  // Layout metrics captured each LayoutBuilder pass; used by animation triggers.
  CardSizing? _dealSizing;
  double _dealTableauWidth = 0;
  double _dealRightPanelWidth = 0;
  double _dealAreaHeight = 0;

  // Dummy face-down card used for the flying card-back overlay.
  static final _dummyCard =
      CardModel(suit: Suit.spades, rank: Rank.ace, isFaceUp: false);

  @override
  void initState() {
    super.initState();
    _dealController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingsProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _dealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final gameState = ref.watch(gameProvider(settings.suitCount));
    _notifier = ref.read(gameProvider(settings.suitCount).notifier);

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
                builder: (context, constraints) =>
                    _buildMainArea(gameState, constraints),
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

  Widget _buildMainArea(GameState state, BoxConstraints constraints) {
    // Right panel is one card wide; compute tableau width first with an estimate,
    // then derive the actual card size from the tableau width.
    const rightPanelPadding = 12.0;
    final estSizing = computeCardSizing(BoxConstraints(maxWidth: constraints.maxWidth));
    final rightPanelWidth = estSizing.cardWidth + rightPanelPadding;
    final tableauWidth = constraints.maxWidth - rightPanelWidth;
    final sizing = computeCardSizing(BoxConstraints(maxWidth: tableauWidth));

    // Capture layout metrics for animation targeting.
    _dealSizing = sizing;
    _dealTableauWidth = tableauWidth;
    _dealRightPanelWidth = rightPanelWidth;
    _dealAreaHeight = constraints.maxHeight;

    return Stack(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Tableau (10 columns, full height) ─────────────────────────────
            SizedBox(
              width: tableauWidth,
              height: constraints.maxHeight,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, left: 6, right: 6, bottom: 8),
                  child: _buildTableau(state, sizing),
                ),
              ),
            ),

            // ── Right panel: vertical foundations + stock at bottom ────────────
            SizedBox(
              width: rightPanelWidth,
              height: constraints.maxHeight,
              child: Padding(
                padding: const EdgeInsets.only(top: 6, right: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    VerticalFoundationPanel(
                      foundationCount: state.foundationCount,
                      sizing: sizing,
                    ),

                    const Spacer(),

                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: StockWidget(
                        dealsRemaining: state.stockDealsRemaining,
                        canDeal: state.canDealFromStock && !_isDealAnimating,
                        sizing: sizing,
                        onTap: () => _triggerDeal(_notifier.dealFromStock),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // ── Animated deal overlay ────────────────────────────────────────────
        if (_isDealAnimating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _dealController,
                builder: (_, __) => _buildDealOverlay(),
              ),
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

  // ── Deal animation helpers ─────────────────────────────────────────────────

  /// Builds the overlay Stack of flying card-backs at the current animation tick.
  Widget _buildDealOverlay() {
    final sizing = _dealSizing!;
    final t = _dealController.value;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        for (final target in _dealTargets)
          Builder(builder: (_) {
            final localT =
                ((t - target.startT) / (target.endT - target.startT))
                    .clamp(0.0, 1.0);
            final easedT = Curves.easeInOut.transform(localT);
            final pos = Offset.lerp(target.from, target.to, easedT)!;
            return Positioned(
              left: pos.dx,
              top: pos.dy,
              child: SizedBox(
                width: sizing.cardWidth,
                height: sizing.cardHeight,
                child: CardWidget(
                  card: _dummyCard,
                  width: sizing.cardWidth,
                  height: sizing.cardHeight,
                ),
              ),
            );
          }),
      ],
    );
  }

  /// Computes the 10 animation targets (stock → column top).
  List<_DealTarget> _buildDealTargets() {
    final sizing = _dealSizing!;
    const travelFraction = 0.40; // each card travels for 40% of the total time
    const n = 10;
    const stagger = (1.0 - travelFraction) / (n - 1);

    // Stock widget centre-left in mainArea-local coordinates.
    final stockFrom = Offset(
      _dealTableauWidth + (_dealRightPanelWidth - sizing.cardWidth) / 2,
      _dealAreaHeight - sizing.cardHeight - 8,
    );

    const leftPad = 6.0;
    const topPad = 6.0;

    return List.generate(n, (i) {
      final colLeft = leftPad + i * (sizing.cardWidth + sizing.columnGap);
      return _DealTarget(
        from: stockFrom,
        to: Offset(colLeft, topPad),
        startT: i * stagger,
        endT: i * stagger + travelFraction,
      );
    });
  }

  /// Runs the deal animation then calls [onComplete] to update game state.
  Future<void> _triggerDeal(VoidCallback onComplete) async {
    if (_isDealAnimating || _dealSizing == null) return;

    setState(() {
      _isDealAnimating = true;
      _dealTargets = _buildDealTargets();
    });

    // Play deal sound (respects soundEnabled setting).
    final soundManager = ref.read(soundManagerProvider);
    await soundManager.playIfEnabled(soundManager.playDeal, ref);

    await _dealController.forward(from: 0.0);

    if (mounted) {
      setState(() => _isDealAnimating = false);
      onComplete();
    }
  }

  // ── Game actions ───────────────────────────────────────────────────────────

  void _startNewGame() {
    setState(() => _winDialogShown = false);
    final settings = ref.read(settingsProvider);
    _triggerDeal(() => _notifier.newGame(settings.suitCount));
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
