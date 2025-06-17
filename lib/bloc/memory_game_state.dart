import '../models/memory_card_model.dart';
import 'memory_game_event.dart';

class MemoryGameState {
  final List<MemoryCard> cards;
  final int moves;
  final int? bestScore;
  final bool isGameCompleted;
  final Duration elapsed;
  final Difficulty difficulty;

  MemoryGameState({
    required this.cards,
    required this.moves,
    required this.bestScore,
    required this.isGameCompleted,
    required this.elapsed,
    required this.difficulty,
  });

  factory MemoryGameState.initial() => MemoryGameState(
    cards: [],
    moves: 0,
    bestScore: null,
    isGameCompleted: false,
    elapsed: Duration.zero,
    difficulty: Difficulty.medium,
  );

  MemoryGameState copyWith({
    List<MemoryCard>? cards,
    int? moves,
    int? bestScore,
    bool? isGameCompleted,
    Duration? elapsed,
    Difficulty? difficulty,
  }) {
    return MemoryGameState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      bestScore: bestScore ?? this.bestScore,
      isGameCompleted: isGameCompleted ?? this.isGameCompleted,
      elapsed: elapsed ?? this.elapsed,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
