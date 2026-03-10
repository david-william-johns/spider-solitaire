import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SoundManager {
  final AudioPlayer _player = AudioPlayer();

  Future<void> playDeal() => _play('sounds/deal.mp3');
  Future<void> playMove() => _play('sounds/move.mp3');
  Future<void> playSequenceComplete() => _play('sounds/sequence_complete.mp3');
  Future<void> playWin() => _play('sounds/win.mp3');

  Future<void> _play(String asset) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(asset));
    } catch (_) {
      // Silently ignore sound errors (missing files, platform issues)
    }
  }

  void dispose() => _player.dispose();
}

final soundManagerProvider = Provider<SoundManager>((ref) {
  final manager = SoundManager();
  ref.onDispose(manager.dispose);
  return manager;
});

/// Helper extension to play sounds only when enabled in settings.
extension SoundManagerExt on SoundManager {
  Future<void> playIfEnabled(
    Future<void> Function() playFn,
    WidgetRef ref,
  ) async {
    if (ref.read(settingsProvider).soundEnabled) {
      await playFn();
    }
  }
}
