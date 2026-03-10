enum Suit { spades, hearts, diamonds, clubs }

enum Rank {
  ace,
  two,
  three,
  four,
  five,
  six,
  seven,
  eight,
  nine,
  ten,
  jack,
  queen,
  king,
}

extension RankExt on Rank {
  int get value => index + 1; // ace=1, king=13
  String get display {
    switch (this) {
      case Rank.ace:
        return 'A';
      case Rank.jack:
        return 'J';
      case Rank.queen:
        return 'Q';
      case Rank.king:
        return 'K';
      default:
        return value.toString();
    }
  }
}

extension SuitExt on Suit {
  String get symbol {
    switch (this) {
      case Suit.spades:
        return '♠';
      case Suit.hearts:
        return '♥';
      case Suit.diamonds:
        return '♦';
      case Suit.clubs:
        return '♣';
    }
  }

  bool get isRed => this == Suit.hearts || this == Suit.diamonds;
}

class CardModel {
  final Suit suit;
  final Rank rank;
  bool isFaceUp;
  bool isHighlighted;

  CardModel({
    required this.suit,
    required this.rank,
    this.isFaceUp = false,
    this.isHighlighted = false,
  });

  CardModel copyWith({
    Suit? suit,
    Rank? rank,
    bool? isFaceUp,
    bool? isHighlighted,
  }) {
    return CardModel(
      suit: suit ?? this.suit,
      rank: rank ?? this.rank,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isHighlighted: isHighlighted ?? this.isHighlighted,
    );
  }

  @override
  String toString() => '${rank.display}${suit.symbol}(${isFaceUp ? "up" : "dn"})';
}
