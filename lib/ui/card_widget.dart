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

  static String _suitImageName(Suit suit) {
    switch (suit) {
      case Suit.spades:
        return 'Spade';
      case Suit.hearts:
        return 'Heart';
      case Suit.diamonds:
        return 'Diamond';
      case Suit.clubs:
        return 'Club';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFaceCard = card.isFaceUp &&
        (card.rank == Rank.jack ||
            card.rank == Rank.queen ||
            card.rank == Rank.king);

    if (isFaceCard) {
      return _buildFaceCardWithImage();
    }

    if (card.isFaceUp) {
      return _buildNumberCard();
    }

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _CardBackPainter(isSelected)),
    );
  }

  Widget _buildNumberCard() {
    final highlighted = isSelected || card.isHighlighted;
    final suitPath = 'assets/cards/${_suitImageName(card.suit)}_B.png';

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // bg, border, rank TL — no suit text
          CustomPaint(
            size: Size(width, height),
            painter: _FaceCardPainter(card, highlighted, skipSuit: true),
          ),
          // Small suit PNG at top-right corner
          Positioned(
            right: 2,
            top: 5,
            width: height * 0.20,
            height: height * 0.20,
            child: Image.asset(suitPath, fit: BoxFit.contain),
          ),
          // Large suit PNG at centre
          Positioned(
            left: width * 0.15,
            top: height * 0.30,
            width: width * 0.70,
            height: height * 0.55,
            child: Image.asset(suitPath, fit: BoxFit.contain),
          ),
        ],
      ),
    );
  }

  Widget _buildFaceCardWithImage() {
    final highlighted = isSelected || card.isHighlighted;
    final rankName =
        card.rank.name[0].toUpperCase() + card.rank.name.substring(1);
    final suitName =
        card.suit.name[0].toUpperCase() + card.suit.name.substring(1);
    final assetPath = 'assets/cards/B_${rankName}_$suitName.png';

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.asset(
              assetPath,
              width: width,
              height: height,
              fit: BoxFit.fill,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: highlighted
                      ? const Color(0xFFFFD700)
                      : const Color(0xFFCC2222),
                  width: highlighted ? 2.5 : 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Face painter (all face-up cards: numbers, Ace, and J/Q/K) ─────────────────

class _FaceCardPainter extends CustomPainter {
  final CardModel card;
  final bool highlighted;
  final bool skipSuit;
  _FaceCardPainter(this.card, this.highlighted, {this.skipSuit = false});

  static const _cornerRadius = 6.0;
  static const _gold = Color(0xFFFFD700);
  static const _darkGold = Color(0xFFB8860B);
  static const _skin = Color(0xFFF5D0A0);
  static const _skinEdge = Color(0xFFD4956A);
  static const _accent = Color(0xFF0033AA);
  static const _swordGrey = Color(0xFF888888);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));

    // Background
    canvas.drawRRect(rrect, Paint()..color = Colors.white);

    // Border
    final borderColor = highlighted
        ? const Color(0xFFFFD700)
        : const Color(0xFFCC2222);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlighted ? 2.5 : 1.2,
    );

    final suitColor =
        card.suit.isRed ? const Color(0xFFCC2222) : const Color(0xFF111111);
    final rankText = card.rank.display;
    final suitText = card.suit.symbol;

    final smallStyle = TextStyle(
      color: suitColor,
      fontSize: h * 0.20,
      fontWeight: FontWeight.bold,
      height: 1.1,
    );

    // Top-left: rank only
    _drawText(canvas, rankText, const Offset(3, 2), smallStyle);

    // Top-right: suit symbol (right-aligned) — skipped when PNG overlay is used
    if (!skipSuit) {
      _drawTextRightAligned(canvas, suitText, Offset(w - 3, 2), smallStyle);
    }

    // Centre content — figure for J/Q/K, large suit symbol for others
    if (card.rank == Rank.jack ||
        card.rank == Rank.queen ||
        card.rank == Rank.king) {
      _drawFigure(canvas, size, suitColor);
    } else if (!skipSuit) {
      final largeStyle = TextStyle(
        color: suitColor,
        fontSize: h * 0.55,
        fontWeight: FontWeight.bold,
        height: 1.0,
      );
      _drawCenteredText(canvas, suitText, size, largeStyle);
    }
  }

  // ── Figure dispatch ────────────────────────────────────────────────────────

  void _drawFigure(Canvas canvas, Size size, Color suitColor) {
    switch (card.rank) {
      case Rank.king:
        _drawKing(canvas, size, suitColor);
      case Rank.queen:
        _drawQueen(canvas, size, suitColor);
      case Rank.jack:
        _drawJack(canvas, size, suitColor);
      default:
        break;
    }
  }

  // ── King ──────────────────────────────────────────────────────────────────

  void _drawKing(Canvas canvas, Size size, Color suitColor) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.50;

    // Robe body (trapezoid, suit colour)
    final robePath = Path()
      ..moveTo(w * 0.18, h * 0.60)
      ..lineTo(w * 0.82, h * 0.60)
      ..lineTo(w * 0.92, h * 0.90)
      ..lineTo(w * 0.08, h * 0.90)
      ..close();
    canvas.drawPath(robePath, Paint()..color = suitColor);

    // Robe trim (gold horizontal line)
    canvas.drawLine(
      Offset(w * 0.18, h * 0.70),
      Offset(w * 0.82, h * 0.70),
      Paint()
        ..color = _gold
        ..strokeWidth = 2.0,
    );

    // Suit symbol on chest (white, small)
    final chestStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.80),
      fontSize: h * 0.11,
      fontWeight: FontWeight.bold,
    );
    _drawTextAt(canvas, card.suit.symbol,
        Offset(cx - w * 0.06, h * 0.74), chestStyle);

    // Crown (gold, 3 peaks)
    final crownPath = Path()
      ..moveTo(w * 0.15, h * 0.41)
      ..lineTo(w * 0.15, h * 0.35)
      ..lineTo(w * 0.25, h * 0.22)
      ..lineTo(w * 0.35, h * 0.35)
      ..lineTo(w * 0.50, h * 0.18)
      ..lineTo(w * 0.65, h * 0.35)
      ..lineTo(w * 0.75, h * 0.22)
      ..lineTo(w * 0.85, h * 0.35)
      ..lineTo(w * 0.85, h * 0.41)
      ..close();
    canvas.drawPath(crownPath, Paint()..color = _gold);
    canvas.drawPath(
      crownPath,
      Paint()
        ..color = _darkGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Gem dots on crown peaks
    canvas.drawCircle(
        Offset(w * 0.25, h * 0.30), w * 0.025, Paint()..color = const Color(0xFFCC2222));
    canvas.drawCircle(
        Offset(cx, h * 0.26), w * 0.030, Paint()..color = const Color(0xFFCC2222));
    canvas.drawCircle(
        Offset(w * 0.75, h * 0.30), w * 0.025, Paint()..color = const Color(0xFFCC2222));

    // Face
    canvas.drawCircle(Offset(cx, h * 0.47), w * 0.12, Paint()..color = _skin);
    canvas.drawCircle(
      Offset(cx, h * 0.47),
      w * 0.12,
      Paint()
        ..color = _skinEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Beard (suit colour, semi-transparent half-oval below chin)
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, h * 0.58), width: w * 0.26, height: h * 0.12),
      0,
      3.14159,
      true,
      Paint()..color = suitColor.withValues(alpha: 0.55),
    );

    // Sword blade (right side)
    canvas.drawLine(
      Offset(w * 0.74, h * 0.55),
      Offset(w * 0.74, h * 0.87),
      Paint()
        ..color = _swordGrey
        ..strokeWidth = 1.5,
    );
    // Crossguard
    canvas.drawLine(
      Offset(w * 0.64, h * 0.62),
      Offset(w * 0.84, h * 0.62),
      Paint()
        ..color = _gold
        ..strokeWidth = 2.5,
    );
    // Pommel
    canvas.drawCircle(
        Offset(w * 0.74, h * 0.88), 3.0, Paint()..color = _gold);
  }

  // ── Queen ─────────────────────────────────────────────────────────────────

  void _drawQueen(Canvas canvas, Size size, Color suitColor) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.50;

    // Dress (wider trapezoid, suit colour)
    final dressPath = Path()
      ..moveTo(w * 0.22, h * 0.59)
      ..lineTo(w * 0.78, h * 0.59)
      ..lineTo(w * 0.92, h * 0.90)
      ..lineTo(w * 0.08, h * 0.90)
      ..close();
    canvas.drawPath(dressPath, Paint()..color = suitColor);

    // Dress trim (gold)
    canvas.drawLine(
      Offset(w * 0.22, h * 0.68),
      Offset(w * 0.78, h * 0.68),
      Paint()
        ..color = _gold
        ..strokeWidth = 2.0,
    );

    // Suit symbol on chest
    final chestStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.80),
      fontSize: h * 0.10,
      fontWeight: FontWeight.bold,
    );
    _drawTextAt(canvas, card.suit.symbol,
        Offset(w * 0.56, h * 0.74), chestStyle);

    // Crown base rectangle
    canvas.drawRect(
      Rect.fromLTRB(w * 0.15, h * 0.38, w * 0.85, h * 0.43),
      Paint()..color = _gold,
    );

    // Crown bumps (3 rounded arcs using cubic bezier)
    final crownPath = Path()
      ..moveTo(w * 0.15, h * 0.41)
      // left bump
      ..cubicTo(w * 0.15, h * 0.30, w * 0.20, h * 0.20, w * 0.28, h * 0.20)
      ..cubicTo(w * 0.36, h * 0.20, w * 0.37, h * 0.30, w * 0.37, h * 0.41)
      // centre bump
      ..cubicTo(w * 0.37, h * 0.30, w * 0.42, h * 0.17, w * 0.50, h * 0.17)
      ..cubicTo(w * 0.58, h * 0.17, w * 0.63, h * 0.30, w * 0.63, h * 0.41)
      // right bump
      ..cubicTo(w * 0.63, h * 0.30, w * 0.64, h * 0.20, w * 0.72, h * 0.20)
      ..cubicTo(w * 0.80, h * 0.20, w * 0.85, h * 0.30, w * 0.85, h * 0.41)
      ..close();
    canvas.drawPath(crownPath, Paint()..color = _gold);
    canvas.drawPath(
      crownPath,
      Paint()
        ..color = _darkGold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Gem on centre crown peak
    canvas.drawCircle(
        Offset(cx, h * 0.19), w * 0.025, Paint()..color = const Color(0xFFCC2222));

    // Face
    canvas.drawCircle(Offset(cx, h * 0.48), w * 0.11, Paint()..color = _skin);
    canvas.drawCircle(
      Offset(cx, h * 0.48),
      w * 0.11,
      Paint()
        ..color = _skinEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Hair arcs (suit colour, either side of face)
    final leftHair = Path()
      ..moveTo(w * 0.22, h * 0.38)
      ..cubicTo(w * 0.08, h * 0.46, w * 0.08, h * 0.54, w * 0.18, h * 0.60);
    canvas.drawPath(
        leftHair,
        Paint()
          ..color = suitColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0);
    final rightHair = Path()
      ..moveTo(w * 0.78, h * 0.38)
      ..cubicTo(w * 0.92, h * 0.46, w * 0.92, h * 0.54, w * 0.82, h * 0.60);
    canvas.drawPath(
        rightHair,
        Paint()
          ..color = suitColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0);

    // Scepter (left side, gold)
    canvas.drawLine(
      Offset(w * 0.26, h * 0.56),
      Offset(w * 0.26, h * 0.87),
      Paint()
        ..color = _gold
        ..strokeWidth = 2.0,
    );
    // Scepter ball
    canvas.drawCircle(
        Offset(w * 0.26, h * 0.54), 4.0, Paint()..color = _gold);
    // Scepter cross
    canvas.drawLine(
        Offset(w * 0.20, h * 0.60),
        Offset(w * 0.32, h * 0.60),
        Paint()
          ..color = _gold
          ..strokeWidth = 1.5);
    canvas.drawLine(
        Offset(w * 0.26, h * 0.56),
        Offset(w * 0.26, h * 0.64),
        Paint()
          ..color = _gold
          ..strokeWidth = 1.5);
  }

  // ── Jack ──────────────────────────────────────────────────────────────────

  void _drawJack(Canvas canvas, Size size, Color suitColor) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.50;

    // Tunic (suit colour)
    final tunicPath = Path()
      ..moveTo(w * 0.20, h * 0.62)
      ..lineTo(w * 0.80, h * 0.62)
      ..lineTo(w * 0.88, h * 0.90)
      ..lineTo(w * 0.12, h * 0.90)
      ..close();
    canvas.drawPath(tunicPath, Paint()..color = suitColor);

    // Belt (gold)
    canvas.drawLine(
      Offset(w * 0.20, h * 0.72),
      Offset(w * 0.80, h * 0.72),
      Paint()
        ..color = _gold
        ..strokeWidth = 2.0,
    );
    // Belt buckle
    canvas.drawRect(
      Rect.fromCenter(center: Offset(cx, h * 0.72), width: w * 0.10, height: h * 0.03),
      Paint()..color = _gold,
    );

    // Suit symbol on tunic
    final chestStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.80),
      fontSize: h * 0.10,
      fontWeight: FontWeight.bold,
    );
    _drawTextAt(canvas, card.suit.symbol, Offset(cx, h * 0.81), chestStyle);

    // Hat brim (wide flat rect, suit colour)
    canvas.drawRect(
      Rect.fromLTRB(w * 0.10, h * 0.36, w * 0.90, h * 0.42),
      Paint()..color = suitColor,
    );

    // Hat crown (tall narrow rect, suit colour)
    canvas.drawRect(
      Rect.fromLTRB(w * 0.28, h * 0.25, w * 0.72, h * 0.37),
      Paint()..color = suitColor,
    );

    // Gold band at base of hat crown
    canvas.drawRect(
      Rect.fromLTRB(w * 0.28, h * 0.34, w * 0.72, h * 0.38),
      Paint()..color = _gold,
    );

    // Feather (gold arc to the right)
    final featherPath = Path()
      ..moveTo(w * 0.72, h * 0.27)
      ..cubicTo(w * 0.96, h * 0.20, w * 0.98, h * 0.32, w * 0.88, h * 0.42);
    canvas.drawPath(
        featherPath,
        Paint()
          ..color = _gold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
          ..strokeCap = StrokeCap.round);
    // Feather inner arc (texture)
    final featherInner = Path()
      ..moveTo(w * 0.72, h * 0.29)
      ..cubicTo(w * 0.90, h * 0.23, w * 0.92, h * 0.33, w * 0.85, h * 0.41);
    canvas.drawPath(
        featherInner,
        Paint()
          ..color = _darkGold
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round);

    // Face
    canvas.drawCircle(Offset(cx, h * 0.52), w * 0.11, Paint()..color = _skin);
    canvas.drawCircle(
      Offset(cx, h * 0.52),
      w * 0.11,
      Paint()
        ..color = _skinEdge
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );

    // Collar (accent blue arc below face)
    canvas.drawArc(
      Rect.fromCenter(
          center: Offset(cx, h * 0.62), width: w * 0.30, height: h * 0.08),
      3.14159,
      3.14159,
      false,
      Paint()
        ..color = _accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );
  }

  // ── Text helpers ──────────────────────────────────────────────────────────

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, offset);
  }

  void _drawTextRightAligned(
      Canvas canvas, String text, Offset topRight, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(topRight.dx - tp.width, topRight.dy));
  }

  void _drawCenteredText(
      Canvas canvas, String text, Size size, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset(
        (size.width - tp.width) / 2,
        (size.height - tp.height) / 2 + size.height * 0.10,
      ),
    );
  }

  /// Draw text centred on [centre].
  void _drawTextAt(Canvas canvas, String text, Offset centre, TextStyle style) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
        canvas, Offset(centre.dx - tp.width / 2, centre.dy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_FaceCardPainter old) =>
      old.card != card || old.highlighted != highlighted || old.skipSuit != skipSuit;
}

// ── Back painter ──────────────────────────────────────────────────────────────

class _CardBackPainter extends CustomPainter {
  final bool highlighted;
  _CardBackPainter(this.highlighted);

  static const _cornerRadius = 6.0;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect =
        RRect.fromRectAndRadius(rect, const Radius.circular(_cornerRadius));

    // Red background
    canvas.drawRRect(rrect, Paint()..color = const Color(0xFFBB1111));

    // Crosshatch pattern
    final patternPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.25)
      ..strokeWidth = 1.0;

    const step = 6.0;
    for (double d = -size.height; d < size.width + size.height; d += step) {
      canvas.drawLine(
        Offset(d.clamp(0.0, size.width),
            (d < 0 ? -d : 0.0).clamp(0.0, size.height)),
        Offset(
          (d + size.height).clamp(0.0, size.width),
          (d < 0 ? size.height : size.height - d).clamp(0.0, size.height),
        ),
        patternPaint,
      );
    }
    for (double d = 0; d < size.width + size.height; d += step) {
      canvas.drawLine(
        Offset((size.width - d).clamp(0.0, size.width), 0),
        Offset(0, d.clamp(0.0, size.height)),
        patternPaint,
      );
    }

    // Border
    final borderColor =
        highlighted ? const Color(0xFFFFD700) : const Color(0xFF880000);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = highlighted ? 2.5 : 1.2,
    );

    // Dark shade overlay — makes stacked back-cards look "behind" face-up cards
    canvas.drawRRect(
        rrect, Paint()..color = Colors.black.withValues(alpha: 0.28));
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
