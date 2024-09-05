import 'package:cricketapp/Models/Players.dart';

class Match {
  String id;
  String teamA;
  String teamB;
  DateTime matchDate;
  String matchPlace;
  int totalOvers;
  Map<String, List<Player>> scores;

  Match({
    required this.id,
    required this.teamA,
    required this.teamB,
    required this.matchDate,
    required this.matchPlace,
    required this.totalOvers,
    required this.scores,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'teamA': teamA,
      'teamB': teamB,
      'matchDate': matchDate.toIso8601String(),
      'matchPlace': matchPlace,
      'totalOvers': totalOvers,
      'scores': scores.map((key, value) => MapEntry(key, value.map((p) => p.toMap()).toList())),
    };
  }

  static Match fromMap(Map<String, dynamic> map) {
    return Match(
      id: map['id'],
      teamA: map['teamA'],
      teamB: map['teamB'],
      matchDate: DateTime.parse(map['matchDate']),
      matchPlace: map['matchPlace'],
      totalOvers: map['totalOvers'],
      scores: Map<String, List<Player>>.from(map['scores'].map((key, value) =>
          MapEntry(key, List<Player>.from(value.map((p) => Player.fromMap(p)))))),
    );
  }
}