import 'package:flutter/material.dart';
import 'card_widget.dart';
import '../utils/responsive.dart';

class FoundationWidget extends StatelessWidget {
  final List<int> foundationCount; // 8 piles, each 0-13
  final CardSizing sizing;

  const FoundationWidget({
    super.key,
    required this.foundationCount,
    required this.sizing,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        for (int i = 0; i < 8; i++)
          Padding(
            padding: EdgeInsets.only(left: sizing.columnGap),
            child: foundationCount[i] == 0
                ? EmptySlotWidget(
                    width: sizing.cardWidth,
                    height: sizing.cardHeight,
                    child: Center(
                      child: Text(
                        '♠',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.3),
                          fontSize: sizing.cardWidth * 0.5,
                        ),
                      ),
                    ),
                  )
                : _CompletedPileWidget(
                    count: foundationCount[i],
                    sizing: sizing,
                    pileIndex: i,
                  ),
          ),
      ],
    );
  }
}

class _CompletedPileWidget extends StatelessWidget {
  final int count;
  final CardSizing sizing;
  final int pileIndex;

  const _CompletedPileWidget({
    required this.count,
    required this.sizing,
    required this.pileIndex,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: sizing.cardWidth,
      height: sizing.cardHeight,
      child: CustomPaint(
        painter: _CompletedPilePainter(count, pileIndex),
      ),
    );
  }
}

// ── Vertical stacked foundation panel (right-side column) ────────────────────

class VerticalFoundationPanel extends StatelessWidget {
  final List<int> foundationCount;
  final CardSizing sizing;

  const VerticalFoundationPanel({
    super.key,
    required this.foundationCount,
    required this.sizing,
  });

  @override
  Widget build(BuildContext context) {
    const overlapFraction = 0.10; // only 10% of each card visible (90% overlap)
    final step = sizing.cardHeight * overlapFraction;
    final totalH = sizing.cardHeight + 7 * step;

    return SizedBox(
      width: sizing.cardWidth,
      height: totalH,
      child: Stack(
        children: [
          for (int i = 0; i < 8; i++)
            Positioned(
              top: i * step,
              child: foundationCount[i] == 0
                  ? EmptySlotWidget(
                      width: sizing.cardWidth,
                      height: sizing.cardHeight,
                      child: Center(
                        child: Text(
                          '♠',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.3),
                            fontSize: sizing.cardWidth * 0.5,
                          ),
                        ),
                      ),
                    )
                  : _CompletedPileWidget(
                      count: foundationCount[i],
                      sizing: sizing,
                      pileIndex: i,
                    ),
            ),
        ],
      ),
    );
  }
}

class _CompletedPilePainter extends CustomPainter {
  final int count;
  final int pileIndex;
  _CompletedPilePainter(this.count, this.pileIndex);

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );

    // Green background for completed pile
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFF1B5E20));
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = const Color(0xFF4CAF50)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Show count
    final tp = TextPainter(
      text: TextSpan(
        text: '$count',
        style: TextStyle(
          color: Colors.white,
          fontSize: size.height * 0.3,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
  }

  @override
  bool shouldRepaint(_CompletedPilePainter old) =>
      old.count != count;
}
