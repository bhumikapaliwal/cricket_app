import 'package:cricketapp/Models/Players.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesUtil {
  static Future<void> saveTeamScores(String matchId, String teamName, List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final playersData = players.map((player) => player.toMap()).toList();
    final key = '$matchId-$teamName';
    await prefs.setString(key, json.encode(playersData));
  }

  static Future<List<Player>> getTeamScores(String matchId, String teamName) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('$matchId-$teamName') ?? '[]';

    final List<dynamic> jsonList = jsonDecode(jsonString);
    final List<Player> players = jsonList.map((json) => Player.fromMap(json)).toList();

    return players;
  }

}
