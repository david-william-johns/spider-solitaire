import '../models/game_state.dart';
import 'game_logic.dart';

class HintResult {
  final int fromColumn;
  final int fromIndex;
  final int toColumn;

  const HintResult({
    required this.fromColumn,
    required this.fromIndex,
    required this.toColumn,
  });
}

class HintEngine {
  /// Find the best available move. Returns null if none found.
  /// Priority: complete a sequence > move to empty > any valid move.
  static HintResult? findHint(GameState state) {
    final columns = state.columns;
    final suitCount = state.suitCount;

    // Priority 1: moves that would complete a K→A sequence
    for (int toCol = 0; toCol < 10; toCol++) {
      final toColumn = columns[toCol];
      if (toColumn.isEmpty) continue;
      final topTarget = toColumn.last;
      if (!topTarget.isFaceUp) continue;

      for (int fromCol = 0; fromCol < 10; fromCol++) {
        if (fromCol == toCol) continue;
        final fromColumn = columns[fromCol];
        for (int fromIdx = 0; fromIdx < fromColumn.length; fromIdx++) {
          if (GameLogic.canMoveTo(fromColumn, fromIdx, toColumn, suitCount)) {
            // Check if this move would create a longer sequence
            final movingLen = fromColumn.length - fromIdx;
            if (movingLen + toColumn.length >= 13) {
              return HintResult(fromColumn: fromCol, fromIndex: fromIdx, toColumn: toCol);
            }
          }
        }
      }
    }

    // Priority 2: move a sequence to an empty column
    final emptyColumns = [for (int i = 0; i < 10; i++) if (columns[i].isEmpty) i];
    if (emptyColumns.isNotEmpty) {
      for (int fromCol = 0; fromCol < 10; fromCol++) {
        final fromColumn = columns[fromCol];
        // Find the longest movable sequence
        for (int fromIdx = 0; fromIdx < fromColumn.length; fromIdx++) {
          if (GameLogic.isValidSequence(fromColumn, fromIdx, suitCount)) {
            return HintResult(
              fromColumn: fromCol,
              fromIndex: fromIdx,
              toColumn: emptyColumns.first,
            );
          }
        }
      }
    }

    // Priority 3: any valid move
    for (int fromCol = 0; fromCol < 10; fromCol++) {
      final fromColumn = columns[fromCol];
      for (int fromIdx = 0; fromIdx < fromColumn.length; fromIdx++) {
        if (!GameLogic.isValidSequence(fromColumn, fromIdx, suitCount)) continue;
        for (int toCol = 0; toCol < 10; toCol++) {
          if (fromCol == toCol) continue;
          if (GameLogic.canMoveTo(fromColumn, fromIdx, columns[toCol], suitCount)) {
            return HintResult(fromColumn: fromCol, fromIndex: fromIdx, toColumn: toCol);
          }
        }
      }
    }

    return null;
  }
}
