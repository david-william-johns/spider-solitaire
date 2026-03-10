import 'package:flutter/material.dart';
import '../models/card_model.dart';
import '../logic/game_logic.dart';
import '../utils/responsive.dart';
import 'card_widget.dart';

class ColumnWidget extends StatelessWidget {
  final int columnIndex;
  final List<CardModel> cards;
  final CardSizing sizing;
  final int hintColumn;
  final int hintCard;
  final void Function(CardMoveData data, int toColumn) onDrop;

  const ColumnWidget({
    super.key,
    required this.columnIndex,
    required this.cards,
    required this.sizing,
    required this.hintColumn,
    required this.hintCard,
    required this.onDrop,
  });

  @override
  Widget build(BuildContext context) {
    final totalHeight = _totalHeight();

    return DragTarget<CardMoveData>(
      onWillAcceptWithDetails: (details) {
        final data = details.data;
        // Validate using GameLogic — we'll let the provider handle final validation
        return data.fromColumn != columnIndex;
      },
      onAcceptWithDetails: (details) {
        onDrop(details.data, columnIndex);
      },
      builder: (context, candidateData, rejectedData) {
        final isDropTarget = candidateData.isNotEmpty;

        return Container(
          width: sizing.cardWidth,
          height: totalHeight,
          decoration: isDropTarget
              ? BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.yellow.withValues(alpha: 0.6),
                    width: 2,
                  ),
                )
              : null,
          child: cards.isEmpty
              ? EmptySlotWidget(
                  width: sizing.cardWidth,
                  height: sizing.cardHeight,
                )
              : _buildStack(),
        );
      },
    );
  }

  double _totalHeight() {
    if (cards.isEmpty) return sizing.cardHeight;
    double h = 0;
    for (int i = 0; i < cards.length - 1; i++) {
      h += cards[i].isFaceUp ? sizing.faceUpOffset : sizing.faceDownOffset;
    }
    h += sizing.cardHeight; // last card is full height
    return h.clamp(sizing.cardHeight, double.infinity);
  }

  Widget _buildStack() {
    final List<Widget> positioned = [];
    double top = 0;

    for (int i = 0; i < cards.length; i++) {
      final card = cards[i];
      final isHinted = (columnIndex == hintColumn && i >= hintCard);

      final cardWidget = CardWidget(
        card: card,
        width: sizing.cardWidth,
        height: sizing.cardHeight,
        isSelected: isHinted,
      );

      final offset = top;

      if (card.isFaceUp) {
        // Make face-up cards draggable (only if they form a valid sequence from here)
        positioned.add(
          Positioned(
            top: offset,
            child: Draggable<CardMoveData>(
              data: CardMoveData(fromColumn: columnIndex, fromIndex: i),
              feedback: _buildDragFeedback(i),
              childWhenDragging: Opacity(
                opacity: 0.3,
                child: cardWidget,
              ),
              child: cardWidget,
            ),
          ),
        );
      } else {
        positioned.add(
          Positioned(
            top: offset,
            child: cardWidget,
          ),
        );
      }

      if (i < cards.length - 1) {
        top += card.isFaceUp ? sizing.faceUpOffset : sizing.faceDownOffset;
      }
    }

    return Stack(
      clipBehavior: Clip.none,
      children: positioned,
    );
  }

  Widget _buildDragFeedback(int fromIndex) {
    final dragCards = cards.sublist(fromIndex);
    double h = 0;
    for (int i = 0; i < dragCards.length - 1; i++) {
      h += sizing.faceUpOffset;
    }
    h += sizing.cardHeight;

    final List<Widget> positioned = [];
    double top = 0;
    for (int i = 0; i < dragCards.length; i++) {
      positioned.add(
        Positioned(
          top: top,
          child: CardWidget(
            card: dragCards[i],
            width: sizing.cardWidth,
            height: sizing.cardHeight,
          ),
        ),
      );
      if (i < dragCards.length - 1) top += sizing.faceUpOffset;
    }

    return Opacity(
      opacity: 0.85,
      child: SizedBox(
        width: sizing.cardWidth,
        height: h,
        child: Stack(clipBehavior: Clip.none, children: positioned),
      ),
    );
  }
}
