class MemoryCard {
  final int id;
  final String value;
  bool isFaceUp;
  bool isMatched;

  MemoryCard({
    required this.id,
    required this.value,
    this.isFaceUp = false,
    this.isMatched = false,
  });

  MemoryCard copyWith({bool? isFaceUp, bool? isMatched}) {
    return MemoryCard(
      id: id, value: value,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
