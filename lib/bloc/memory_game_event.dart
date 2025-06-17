import 'package:equatable/equatable.dart';

abstract class MemoryGameEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class StartGame extends MemoryGameEvent {
  final Difficulty difficulty;
  StartGame({this.difficulty = Difficulty.easy});

  @override
  List<Object?> get props => [difficulty];
}

class FlipCard extends MemoryGameEvent {
  final int index;
  FlipCard(this.index);

  @override
  List<Object?> get props => [index];
}

class ResetGame extends MemoryGameEvent {}

class UpdateTimer extends MemoryGameEvent {
  final Duration elapsed;
  UpdateTimer(this.elapsed);

  @override
  List<Object?> get props => [elapsed];
}

enum Difficulty { easy, medium, hard }
