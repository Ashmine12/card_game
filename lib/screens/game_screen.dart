import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../bloc/memory_game_bloc.dart';
import '../bloc/memory_game_event.dart';
import '../bloc/memory_game_state.dart';
import '../models/score_model.dart';
import 'history_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A237E), Color(0xFF64B5F6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: () {
                        final currentDifficulty = context.read<MemoryGameBloc>().state.difficulty;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => HistoryScreen(difficulty: currentDifficulty),
                          ),
                        );
                      },
                    ),
                    const Text(
                      "Memory Match Game",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    IconButton(
                      icon: const Icon(Icons.restart_alt, color: Colors.white),
                      onPressed: () => context.read<MemoryGameBloc>().add(ResetGame()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              BlocBuilder<MemoryGameBloc, MemoryGameState>(
                builder: (context, state) {
                  if (state.isGameCompleted) {
                    Future.delayed(Duration.zero, () async {
                      final prefs = await SharedPreferences.getInstance();
                      final bestKey = 'bestScore_${state.difficulty.name}';
                      final storedBest = prefs.getInt(bestKey);
                      if (storedBest == null || state.moves < storedBest) {
                        await prefs.setInt(bestKey, state.moves);
                      }

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("🎉 You Won!"),
                          content: Text("Moves: ${state.moves}\nTime: ${state.elapsed.inSeconds}s"),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text("Close"),
                            ),
                          ],
                        ),
                      );
                    });
                  }

                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _difficultyButton(context, "3×4", Difficulty.easy),
                          _difficultyButton(context, "4×4", Difficulty.medium),
                          _difficultyButton(context, "6×6", Difficulty.hard),
                        ],
                      ),
                      const SizedBox(height: 16),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 500),
                        opacity: 1.0,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoBox("Moves", state.moves.toString()),
                            _infoBox("Time", "${state.elapsed.inSeconds}s"),
                            FutureBuilder<int?>(
                              future: SharedPreferences.getInstance().then(
                                      (prefs) => prefs.getInt('bestScore_${state.difficulty.name}')),
                              builder: (context, snapshot) {
                                return _infoBox("Best", snapshot.data?.toString() ?? "-");
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              Expanded(child: _GameGrid()),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _difficultyButton(BuildContext context, String label, Difficulty difficulty) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: () {
        context.read<MemoryGameBloc>().add(StartGame(difficulty: difficulty));
      },
      child: Text(label),
    );
  }

  Widget _infoBox(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _GameGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MemoryGameBloc, MemoryGameState>(
      builder: (context, state) {
        final crossAxisCount = state.difficulty == Difficulty.easy
            ? 3
            : state.difficulty == Difficulty.medium
            ? 4
            : 6;

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount, crossAxisSpacing: 8, mainAxisSpacing: 8),
          itemCount: state.cards.length,
          itemBuilder: (_, i) {
            final card = state.cards[i];
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder: (child, animation) => RotationTransition(
                turns: Tween(begin: 0.5, end: 1.0).animate(animation),
                child: child,
              ),
              child: GestureDetector(
                key: ValueKey(card.isFaceUp || card.isMatched),
                onTap: () => context.read<MemoryGameBloc>().add(FlipCard(i)),
                child: Container(
                  decoration: BoxDecoration(
                    color: card.isFaceUp || card.isMatched ? Colors.white : Colors.yellowAccent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(2, 2),
                        blurRadius: 4,
                      )
                    ],
                  ),
                  child: Center(
                    child: Text(
                      card.isFaceUp || card.isMatched ? card.value : '',
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
