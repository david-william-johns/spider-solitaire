import 'dart:math';
import '../models/card_model.dart';
import '../models/settings_model.dart';

class DealManager {
  /// Build the 104-card deck based on suit count setting.
  static List<CardModel> buildDeck(SuitCount suitCount) {
    final deck = <CardModel>[];
    final suits = _suitsForMode(suitCount);
    // Spider uses 2 full decks (104 cards), distributed among the allowed suits
    final cardsPerSuit = 104 ~/ suits.length;
    for (final suit in suits) {
      for (int i = 0; i < cardsPerSuit ~/ 13; i++) {
        for (final rank in Rank.values) {
          deck.add(CardModel(suit: suit, rank: rank));
        }
      }
    }
    return deck;
  }

  static List<Suit> _suitsForMode(SuitCount suitCount) {
    switch (suitCount) {
      case SuitCount.one:
        return [Suit.spades];
      case SuitCount.two:
        return [Suit.spades, Suit.hearts];
      case SuitCount.four:
        return Suit.values.toList();
    }
  }

  /// Shuffle and deal initial tableau + stock.
  /// Returns (columns, stock) where stock is 5 groups of 10.
  static (List<List<CardModel>>, List<List<CardModel>>) dealInitial(
    SuitCount suitCount, {
    int? seed,
  }) {
    final rng = seed != null ? Random(seed) : Random();
    final deck = buildDeck(suitCount);
    deck.shuffle(rng);

    // Columns 0-3 get 6 cards, columns 4-9 get 5 cards = 54 total dealt
    final columns = List.generate(10, (_) => <CardModel>[]);
    int idx = 0;
    for (int col = 0; col < 10; col++) {
      final count = col < 4 ? 6 : 5;
      for (int i = 0; i < count; i++) {
        final card = deck[idx++];
        card.isFaceUp = false;
        columns[col].add(card);
      }
      // Flip last card face up
      columns[col].last.isFaceUp = true;
    }

    // Remaining 50 cards → 5 groups of 10
    final stock = <List<CardModel>>[];
    while (idx < deck.length) {
      final group = <CardModel>[];
      for (int i = 0; i < 10 && idx < deck.length; i++) {
        final card = deck[idx++];
        card.isFaceUp = true;
        group.add(card);
      }
      stock.add(group);
    }

    return (columns, stock);
  }
}
