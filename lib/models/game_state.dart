import 'card_model.dart';
import 'settings_model.dart';

class GameStateSnapshot {
  final List<List<CardModel>> columns;
  final List<List<CardModel>> stock;
  final List<int> foundationCount;
  final int moves;
  final int score;

  GameStateSnapshot({
    required this.columns,
    required this.stock,
    required this.foundationCount,
    required this.moves,
    required this.score,
  });

  factory GameStateSnapshot.from(GameState state) {
    return GameStateSnapshot(
      columns: state.columns
          .map((col) => col.map((c) => c.copyWith()).toList())
          .toList(),
      stock: state.stock
          .map((group) => group.map((c) => c.copyWith()).toList())
          .toList(),
      foundationCount: List<int>.from(state.foundationCount),
      moves: state.moves,
      score: state.score,
    );
  }
}

class GameState {
  /// 10 tableau columns
  final List<List<CardModel>> columns;

  /// 5 groups of 10 cards (stock deals)
  final List<List<CardModel>> stock;

  /// 8 foundation piles — stored as count of completed cards (0–13)
  final List<int> foundationCount;

  final int moves;
  final int score;
  final SuitCount suitCount;

  /// Undo history (most recent last)
  final List<GameStateSnapshot> history;

  /// Index of column/card highlighted by hint (-1 = none)
  final int hintColumn;
  final int hintCard;

  const GameState({
    required this.columns,
    required this.stock,
    required this.foundationCount,
    required this.moves,
    required this.score,
    required this.suitCount,
    required this.history,
    this.hintColumn = -1,
    this.hintCard = -1,
  });

  bool get isWon => foundationCount.every((c) => c == 13);

  int get stockDealsRemaining => stock.length;

  bool get canDealFromStock {
    if (stock.isEmpty) return false;
    // Cannot deal if any column is empty
    return columns.every((col) => col.isNotEmpty);
  }

  bool get canUndo => history.isNotEmpty;

  GameState copyWith({
    List<List<CardModel>>? columns,
    List<List<CardModel>>? stock,
    List<int>? foundationCount,
    int? moves,
    int? score,
    SuitCount? suitCount,
    List<GameStateSnapshot>? history,
    int? hintColumn,
    int? hintCard,
  }) {
    return GameState(
      columns: columns ?? this.columns,
      stock: stock ?? this.stock,
      foundationCount: foundationCount ?? this.foundationCount,
      moves: moves ?? this.moves,
      score: score ?? this.score,
      suitCount: suitCount ?? this.suitCount,
      history: history ?? this.history,
      hintColumn: hintColumn ?? this.hintColumn,
      hintCard: hintCard ?? this.hintCard,
    );
  }
}
