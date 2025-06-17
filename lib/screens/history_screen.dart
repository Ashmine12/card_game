import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../bloc/memory_game_event.dart';
import '../models/score_model.dart';

class HistoryScreen extends StatelessWidget {
  final Difficulty difficulty;

  const HistoryScreen({super.key, required this.difficulty});

  Future<List<ScoreModel>> _loadScores() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('scoreHist_${difficulty.name}') ?? [];
    return list
        .map((e) => ScoreModel.fromJson(jsonDecode(e)))
        .toList()
        .reversed
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final timeFormatter = DateFormat('h:mm a');

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          '${difficulty.name.toUpperCase()} Score History',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: FutureBuilder<List<ScoreModel>>(
        future: _loadScores(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final scores = snapshot.data!;

          if (scores.isEmpty) {
            return const Center(
              child: Text("No data", style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.separated(
            itemCount: scores.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (_, i) {
              final s = scores[i];
              final localDateTime = s.date.toLocal();
              final formattedDate = dateFormatter.format(localDateTime);
              final formattedTime = timeFormatter.format(localDateTime);
              return ListTile(
                leading: const Icon(Icons.star),
                title: Text("Moves: ${s.moves}"),
                subtitle: Text("Date: $formattedDate\nTime: $formattedTime"),
              );
            },
          );
        },
      ),
    );
  }
}
