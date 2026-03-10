import 'package:flutter/material.dart';
import '../models/card_model.dart';

class CardWidget extends StatelessWidget {
  final CardModel card;
  final double width;
  final double height;
  final bool isSelected;

  const CardWidget({
    super.key,
    required this.card,
    required this.width,
    required this.height,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: card.isFaceUp
            ? _CardFacePainter(card, isSelected || card.isHighlighted)
            : _CardBackPainter(isSelected),
      ),
    );
  }
}

// ── Face painter ──────────────────────────────────────────────────────────────

class _CardFacePainter extends CustomPainter {
  final CardModel card;
  final bool highlighted;
  _CardFacePainter(this.card, this.highlighted);

  static const _cornerRadius = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));

    // Background
    canvas.drawRRect(
      rrect,
      Paint()..color = Colors.white,
    );

    // Border
    final borderColor = highlighted
        ? const Color(0xFFFFD700) // gold highlight
        : const Color(0xFFCC2222); // red border
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlighted ? 2.5 : 1.2,
    );

    final color = card.suit.isRed ? const Color(0xFFCC2222) : const Color(0xFF111111);
    final rankText = card.rank.display;
    final suitText = card.suit.symbol;

    final smallStyle = TextStyle(
      color: color,
      fontSize: size.height * 0.16,
      fontWeight: FontWeight.bold,
      height: 1.1,
    );

    final largeStyle = TextStyle(
      color: color,
      fontSize: size.height * 0.36,
      fontWeight: FontWeight.bold,
      height: 1.0,
    );

    // Top-left corner: rank + suit
    _drawText(canvas, rankText, const Offset(3, 2), smallStyle);
    _drawText(canvas, suitText, Offset(3, size.height * 0.17), smallStyle);

    // Center large suit symbol
    _drawCenteredText(canvas, suitText, size, largeStyle);

    // Bottom-right (rotated 180)
    canvas.save();
    canvas.translate(size.width, size.height);
    canvas.rotate(3.14159);
    _drawText(canvas, rankText, const Offset(3, 2), smallStyle);
    _drawText(canvas, suitText, Offset(3, size.height * 0.17), smallStyle);
    canvas.restore();
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawCenteredText(Canvas canvas, String text, Size size, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        (size.height - tp.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(_CardFacePainter old) =>
      old.card != card || old.highlighted != highlighted;
}

// ── Back painter ──────────────────────────────────────────────────────────────

class _CardBackPainter extends CustomPainter {
  final bool highlighted;
  _CardBackPainter(this.highlighted);

  static const _cornerRadius = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));

    // Red background
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFBB1111));

    // Crosshatch pattern
    final patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;

    const step = 6.0;
    // Diagonal lines top-left → bottom-right
    for (double d = -size.height; d < size.width + size.height; d += step) {
      canvas.drawLine(
        Offset(d.clamp(0.0, size.width), (d < 0 ? -d : 0.0).clamp(0.0, size.height)),
        Offset(
          (d + size.height).clamp(0.0, size.width),
          (d < 0 ? size.height : size.height - d).clamp(0.0, size.height),
        ),
        patternPaint,
      );
    }
    // Diagonal lines top-right → bottom-left
    for (double d = 0; d < size.width + size.height; d += step) {
      canvas.drawLine(
        Offset((size.width - d).clamp(0.0, size.width), 0),
        Offset(0, d.clamp(0.0, size.height)),
        patternPaint,
      );
    }

    // Border
    final borderColor = highlighted ? const Color(0xFFFFD700) : const Color(0xFF880000);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlighted ? 2.5 : 1.2,
    );
  }

  @override
  bool shouldRepaint(_CardBackPainter old) => old.highlighted != highlighted;
}

/// A placeholder empty slot (for foundations or empty column indicator).
class EmptySlotWidget extends StatelessWidget {
  final double width;
  final double height;
  final Widget? child;

  const EmptySlotWidget({
    super.key,
    required this.width,
    required this.height,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _EmptySlotPainter(),
        child: child,
      ),
    );
  }
}

class _EmptySlotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(6),
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  @override
  bool shouldRepaint(_EmptySlotPainter old) => false;
}
