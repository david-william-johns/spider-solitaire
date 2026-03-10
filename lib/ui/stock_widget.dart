import 'package:flutter/material.dart';
import 'card_widget.dart';
import '../models/card_model.dart';
import '../utils/responsive.dart';

class StockWidget extends StatelessWidget {
  final int dealsRemaining;
  final bool canDeal;
  final CardSizing sizing;
  final VoidCallback onTap;

  const StockWidget({
    super.key,
    required this.dealsRemaining,
    required this.canDeal,
    required this.sizing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (dealsRemaining == 0) {
      return SizedBox(
        width: sizing.cardWidth,
        height: sizing.cardHeight + 20,
      );
    }

    // Show stacked cards with offset to indicate count
    return GestureDetector(
      onTap: canDeal ? onTap : null,
      child: SizedBox(
        width: sizing.cardWidth + 6,
        height: sizing.cardHeight + (dealsRemaining - 1) * 4.0,
        child: Stack(
          children: [
            for (int i = 0; i < dealsRemaining.clamp(0, 5); i++)
              Positioned(
                top: (dealsRemaining.clamp(0, 5) - 1 - i) * 4.0,
                left: i * 1.0,
                child: Opacity(
                  opacity: canDeal ? 1.0 : 0.5,
                  child: _buildCardBack(),
                ),
              ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 6,
              child: Center(
                child: Text(
                  '$dealsRemaining',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: sizing.cardWidth * 0.25,
                    fontWeight: FontWeight.bold,
                    shadows: const [
                      Shadow(color: Colors.black, blurRadius: 3),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return CardWidget(
      card: CardModel(suit: Suit.spades, rank: Rank.ace),
      width: sizing.cardWidth,
      height: sizing.cardHeight,
    );
  }
}
