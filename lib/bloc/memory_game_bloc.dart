import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:bloc/bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/memory_card_model.dart';
import '../models/score_model.dart';
import '../utils/sound_manager.dart';

import 'memory_game_event.dart';
import 'memory_game_state.dart';

class MemoryGameBloc extends Bloc<MemoryGameEvent, MemoryGameState> {
  Timer? _timer;
  DateTime? _startTime;
  MemoryCard? _firstSelected;

  MemoryGameBloc() : super(MemoryGameState.initial()) {
    on<StartGame>(_onStartGame);
    on<FlipCard>(_onFlipCard);
    on<ResetGame>(_onResetGame);
    on<UpdateTimer>(_onUpdateTimer);
  }

  Future<void> _onStartGame(StartGame event, Emitter<MemoryGameState> emit) async {
    int pairCount;
    switch(event.difficulty) {
      case Difficulty.easy: pairCount = 6; break;
      case Difficulty.hard: pairCount = 18; break;
      default: pairCount = 8;
    }

    final values = List.generate(pairCount, (i) => String.fromCharCode(65 + i));
    final paired = [...values, ...values]..shuffle(Random());
    final cards = List.generate(paired.length, (i) => MemoryCard(id: i, value: paired[i]));

    final prefs = await SharedPreferences.getInstance();
    final best = prefs.getInt('bestScore_${event.difficulty.name}');

    _startTime = DateTime.now();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds:1), (_) {
      add(UpdateTimer(DateTime.now().difference(_startTime!)));
    });

    emit(MemoryGameState(cards: cards, moves:0, bestScore: best, isGameCompleted:false, elapsed:Duration.zero, difficulty:event.difficulty));
  }

  Future<void> _onFlipCard(FlipCard event, Emitter<MemoryGameState> emit) async {
    final card = state.cards[event.index];
    if (card.isFaceUp || card.isMatched || state.isGameCompleted) return;

    final updated = List.of(state.cards);
    updated[event.index] = card.copyWith(isFaceUp:true);

    await SoundManager.playFlip();

    if (_firstSelected == null) {
      _firstSelected = updated[event.index];
      emit(state.copyWith(cards: updated));
    } else {
      emit(state.copyWith(cards: updated, moves: state.moves + 1));

      await Future.delayed(Duration(milliseconds: 800));

      if (_firstSelected?.value == card.value) {
        updated[event.index] = updated[event.index].copyWith(isMatched:true);
        final prevIndex = updated.indexWhere((c) => c.id == _firstSelected!.id);
        updated[prevIndex] = updated[prevIndex].copyWith(isMatched:true);
        await SoundManager.playMatch();
      } else {
        updated[event.index] = updated[event.index].copyWith(isFaceUp:false);
        final prevIndex = updated.indexWhere((c) => c.id == _firstSelected?.id);
        updated[prevIndex] = updated[prevIndex].copyWith(isFaceUp:false);
      }

      _firstSelected = null;

      final complete = updated.every((c) => c.isMatched);
      int? best = state.bestScore;

      if (complete) {
        _timer?.cancel();
        if (best == null || (state.moves + 1) < best) {
          final prefs = await SharedPreferences.getInstance();
          best = state.moves + 1;
          prefs.setInt('bestScore_${state.difficulty.name}', best);
        }
        await SoundManager.playWin();

        final prefsHist = await SharedPreferences.getInstance();
        final list = prefsHist.getStringList('scoreHist_${state.difficulty.name}') ?? [];
        final newScore = ScoreModel(DateTime.now(), state.moves + 1);
        list.add(jsonEncode(newScore.toJson()));
        prefsHist.setStringList('scoreHist_${state.difficulty.name}', list);
      }

      emit(state.copyWith(cards: updated, moves: state.moves + 1, isGameCompleted:complete, bestScore:best));
    }
  }

  void _onResetGame(ResetGame event, Emitter<MemoryGameState> emit) {
    add(StartGame(difficulty: state.difficulty));
  }

  void _onUpdateTimer(UpdateTimer event, Emitter<MemoryGameState> emit) {
    emit(state.copyWith(elapsed: event.elapsed));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
