import 'dart:math';
import 'package:flutter/material.dart';

class WinDialog extends StatefulWidget {
  final int score;
  final int moves;
  final VoidCallback onNewGame;

  const WinDialog({
    super.key,
    required this.score,
    required this.moves,
    required this.onNewGame,
  });

  @override
  State<WinDialog> createState() => _WinDialogState();
}

class _WinDialogState extends State<WinDialog>
    with TickerProviderStateMixin {
  late final AnimationController _confettiCtrl;
  final _rng = Random();
  final _confettiPieces = <_ConfettiPiece>[];

  @override
  void initState() {
    super.initState();
    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    for (int i = 0; i < 60; i++) {
      _confettiPieces.add(_ConfettiPiece(_rng));
    }
  }

  @override
  void dispose() {
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Confetti layer
        AnimatedBuilder(
          animation: _confettiCtrl,
          builder: (_, __) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _ConfettiPainter(
              _confettiPieces,
              _confettiCtrl.value,
            ),
          ),
        ),
        // Dialog
        Center(
          child: Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '🎉',
                    style: TextStyle(fontSize: 48),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You Win!',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B5E20),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Score: ${widget.score}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  Text(
                    'Moves: ${widget.moves}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 28),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        widget.onNewGame();
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'New Game',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ConfettiPiece {
  final double x; // 0-1 normalized
  final double speed;
  final double size;
  final Color color;
  final double rotation;

  _ConfettiPiece(Random rng)
      : x = rng.nextDouble(),
        speed = 0.3 + rng.nextDouble() * 0.7,
        size = 6 + rng.nextDouble() * 8,
        rotation = rng.nextDouble() * 2 * pi,
        color = _colors[rng.nextInt(_colors.length)];

  static const _colors = [
    Colors.red,
    Colors.blue,
    Colors.yellow,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  _ConfettiPainter(this.pieces, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final y = (progress * piece.speed + piece.x * 0.3) % 1.2;
      final x = piece.x * size.width;
      final yPos = y * size.height;

      canvas.save();
      canvas.translate(x, yPos);
      canvas.rotate(piece.rotation + progress * 5);
      canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: piece.size, height: piece.size * 0.6),
        Paint()..color = piece.color.withOpacity(0.8),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.progress != progress;
}
