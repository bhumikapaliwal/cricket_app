import 'dart:convert';

import 'package:cricketapp/Models/Players.dart';

class Team {
  // String id;
  String name;
  List<Player> players;

  Team({
    // required this.id,
    required this.name,
    required this.players,
  });

  Map<String, dynamic> toMap() {
    return {
      // 'id': id,
      'name': name,
      'players': players.map((p) => p.toMap()).toList(),
    };
  }

  static Team fromMap(Map<String, dynamic> map) {
    return Team(
    //  id: map['id'],
      name: map['name'],
      players: List<Player>.from(map['players'].map((p) => Player.fromMap(p))),
    );
  }
  String toJson() {
    return json.encode(toMap());
  }

  static Team fromJson(String jsonString) {
    final map = json.decode(jsonString) as Map<String, dynamic>;
    return fromMap(map);
  }
}
