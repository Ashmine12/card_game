import 'package:card_game/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/memory_game_bloc.dart';
import '../bloc/memory_game_event.dart';

void main() {
  runApp(const MemoryGameApp());
}

class MemoryGameApp extends StatelessWidget {
  const MemoryGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BlocProvider(
        create: (_) => MemoryGameBloc()..add(StartGame()),
        child: const GameScreen(),
      ),
    );
  }
}
