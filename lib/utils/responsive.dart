import 'package:flutter/material.dart';

class CardSizing {
  final double cardWidth;
  final double cardHeight;
  final double faceDownOffset;
  final double faceUpOffset;
  final double columnGap;

  const CardSizing({
    required this.cardWidth,
    required this.cardHeight,
    required this.faceDownOffset,
    required this.faceUpOffset,
    required this.columnGap,
  });
}

CardSizing computeCardSizing(BoxConstraints constraints) {
  // 10 columns + small gaps
  const numColumns = 10;
  const gapFraction = 0.008; // gap as fraction of available width
  final totalWidth = constraints.maxWidth;
  final gap = totalWidth * gapFraction;
  final cardWidth = (totalWidth - gap * (numColumns + 1)) / numColumns;
  final cardHeight = cardWidth * 1.4; // standard card aspect ratio

  return CardSizing(
    cardWidth: cardWidth,
    cardHeight: cardHeight,
    faceDownOffset: cardHeight * 0.18,
    faceUpOffset: cardHeight * 0.28,
    columnGap: gap,
  );
}
