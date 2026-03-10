import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../models/settings_model.dart';
import '../logic/game_logic.dart';
import '../logic/hint_engine.dart';

class GameNotifier extends StateNotifier<GameState> {
  GameNotifier(SuitCount suitCount)
      : super(GameLogic.newGame(suitCount));

  void newGame(SuitCount suitCount) {
    state = GameLogic.newGame(suitCount);
  }

  void move(int fromCol, int fromIndex, int toCol) {
    final next = GameLogic.executeMove(state, fromCol, fromIndex, toCol);
    if (next != null) state = next;
  }

  void dealFromStock() {
    final next = GameLogic.dealFromStock(state);
    if (next != null) state = next;
  }

  void undo() {
    final next = GameLogic.undo(state);
    if (next != null) state = next;
  }

  void showHint() {
    final hint = HintEngine.findHint(state);
    if (hint != null) {
      state = state.copyWith(
        hintColumn: hint.fromColumn,
        hintCard: hint.fromIndex,
      );
    }
  }

  void clearHint() {
    if (state.hintColumn != -1) {
      state = state.copyWith(hintColumn: -1, hintCard: -1);
    }
  }
}

final gameProvider =
    StateNotifierProvider.family<GameNotifier, GameState, SuitCount>(
  (ref, suitCount) => GameNotifier(suitCount),
);

// Convenience provider using current settings
final currentGameProvider = Provider<GameNotifier>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});
