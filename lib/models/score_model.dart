class ScoreModel {
  final DateTime date;
  final int moves;

  ScoreModel(this.date, this.moves);

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'moves': moves,
  };

  static ScoreModel fromJson(Map<String, dynamic> json) =>
      ScoreModel(DateTime.parse(json['date']), json['moves']);
}
