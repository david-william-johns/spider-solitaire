import '../models/card_model.dart';
import '../models/game_state.dart';
import '../models/settings_model.dart';
import 'deal_manager.dart';

class CardMoveData {
  final int fromColumn;
  final int fromIndex; // index of the first card in the sequence being moved
  CardMoveData({required this.fromColumn, required this.fromIndex});
}

class GameLogic {
  /// Create a fresh game state.
  static GameState newGame(SuitCount suitCount, {int? seed}) {
    final (columns, stock) = DealManager.dealInitial(suitCount, seed: seed);
    return GameState(
      columns: columns,
      stock: stock,
      foundationCount: List.filled(8, 0),
      moves: 0,
      score: 500,
      suitCount: suitCount,
      history: [],
    );
  }

  /// Whether a sequence of cards (from index [from] to end of column) is
  /// a valid movable sequence for the given suit mode.
  static bool isValidSequence(
    List<CardModel> column,
    int from,
    SuitCount suitCount,
  ) {
    if (from >= column.length) return false;
    if (!column[from].isFaceUp) return false;

    for (int i = from; i < column.length - 1; i++) {
      final upper = column[i];
      final lower = column[i + 1];

      if (!lower.isFaceUp) return false;

      // Must be consecutive descending rank
      if (upper.rank.value != lower.rank.value + 1) return false;

      // Suit constraint by mode
      switch (suitCount) {
        case SuitCount.four:
          if (upper.suit != lower.suit) return false;
          break;
        case SuitCount.two:
          if (upper.suit.isRed != lower.suit.isRed) return false;
          break;
        case SuitCount.one:
          // Any descending sequence is movable in 1-suit mode
          break;
      }
    }
    return true;
  }

  /// Whether a card/sequence starting at [fromIndex] in [fromCol] can be
  /// moved to the top of [toCol].
  static bool canMoveTo(
    List<CardModel> fromCol,
    int fromIndex,
    List<CardModel> toCol,
    SuitCount suitCount,
  ) {
    if (!isValidSequence(fromCol, fromIndex, suitCount)) return false;

    final movingCard = fromCol[fromIndex];

    if (toCol.isEmpty) return true; // Any card can go to empty column

    final topCard = toCol.last;
    if (!topCard.isFaceUp) return false;

    // Target top card must be one rank higher than the moving card
    return topCard.rank.value == movingCard.rank.value + 1;
  }

  /// Execute a move. Returns updated GameState, or null if invalid.
  static GameState? executeMove(
    GameState state,
    int fromCol,
    int fromIndex,
    int toCol,
  ) {
    final columns = state.columns.map((c) => List<CardModel>.from(c)).toList();

    if (!canMoveTo(columns[fromCol], fromIndex, columns[toCol], state.suitCount)) {
      return null;
    }

    // Snapshot for undo
    final snapshot = GameStateSnapshot.from(state);
    final history = List<GameStateSnapshot>.from(state.history)..add(snapshot);

    // Move cards
    final movingCards = columns[fromCol].sublist(fromIndex);
    columns[fromCol] = columns[fromCol].sublist(0, fromIndex);
    columns[toCol].addAll(movingCards);

    // Flip new top card of source column if face-down
    if (columns[fromCol].isNotEmpty && !columns[fromCol].last.isFaceUp) {
      columns[fromCol].last = columns[fromCol].last.copyWith(isFaceUp: true);
    }

    // Check for completed sequences in destination column
    final (newColumns, newFoundationCount, completedCount) =
        _checkCompletedSequences(columns, List<int>.from(state.foundationCount));

    final scoreChange = -1 + (completedCount * 100);

    return state.copyWith(
      columns: newColumns,
      foundationCount: newFoundationCount,
      moves: state.moves + 1,
      score: (state.score + scoreChange).clamp(0, 9999),
      history: history,
      hintColumn: -1,
      hintCard: -1,
    );
  }

  /// Deal one card from stock to each column.
  static GameState? dealFromStock(GameState state) {
    if (!state.canDealFromStock) return null;

    final snapshot = GameStateSnapshot.from(state);
    final history = List<GameStateSnapshot>.from(state.history)..add(snapshot);

    final stock = state.stock.map((g) => List<CardModel>.from(g)).toList();
    final group = stock.removeAt(0);

    final columns = state.columns.map((c) => List<CardModel>.from(c)).toList();
    for (int i = 0; i < 10; i++) {
      columns[i].add(group[i]);
    }

    // Check for completed sequences after deal
    final (newColumns, newFoundationCount, completedCount) =
        _checkCompletedSequences(columns, List<int>.from(state.foundationCount));

    return state.copyWith(
      columns: newColumns,
      stock: stock,
      foundationCount: newFoundationCount,
      moves: state.moves + 1,
      score: (state.score - 1 + completedCount * 100).clamp(0, 9999),
      history: history,
      hintColumn: -1,
      hintCard: -1,
    );
  }

  /// Undo last move. Returns updated state or null if no history.
  static GameState? undo(GameState state) {
    if (state.history.isEmpty) return null;

    final history = List<GameStateSnapshot>.from(state.history);
    final snapshot = history.removeLast();

    return state.copyWith(
      columns: snapshot.columns,
      stock: snapshot.stock,
      foundationCount: snapshot.foundationCount,
      moves: snapshot.moves,
      score: snapshot.score,
      history: history,
      hintColumn: -1,
      hintCard: -1,
    );
  }

  /// Check all columns for completed K→A same-suit sequences and remove them.
  /// Returns (updatedColumns, updatedFoundations, completedCount).
  static (List<List<CardModel>>, List<int>, int) _checkCompletedSequences(
    List<List<CardModel>> columns,
    List<int> foundationCount,
  ) {
    int completedCount = 0;
    bool found = true;

    while (found) {
      found = false;
      for (int col = 0; col < columns.length; col++) {
        final column = columns[col];
        if (column.length < 13) continue;

        final start = column.length - 13;
        final seq = column.sublist(start);

        // Must be K at top, A at bottom, all same suit, all face-up
        if (seq.first.rank != Rank.king) continue;
        if (seq.last.rank != Rank.ace) continue;
        final suit = seq.first.suit;
        bool valid = true;
        for (int i = 0; i < 13; i++) {
          if (!seq[i].isFaceUp) { valid = false; break; }
          if (seq[i].suit != suit) { valid = false; break; }
          if (seq[i].rank.value != 13 - i) { valid = false; break; }
        }

        if (valid) {
          // Remove from column
          columns[col] = column.sublist(0, start);
          // Flip new last card if face-down
          if (columns[col].isNotEmpty && !columns[col].last.isFaceUp) {
            columns[col].last = columns[col].last.copyWith(isFaceUp: true);
          }
          // Increment foundation
          final fIdx = foundationCount.indexOf(0);
          if (fIdx != -1) {
            foundationCount = List<int>.from(foundationCount);
            foundationCount[fIdx] = 13;
          }
          completedCount++;
          found = true;
        }
      }
    }

    return (columns, foundationCount, completedCount);
  }
}
