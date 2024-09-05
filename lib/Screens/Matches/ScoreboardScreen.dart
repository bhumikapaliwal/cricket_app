import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:flutter/material.dart';
import 'package:cricketapp/Models/Players.dart';
import 'package:cricketapp/Models/Team.dart';

class ScoreboardScreen extends StatefulWidget {
  final String teamAId;
  final String teamBId;
  final String matchId;

  ScoreboardScreen({required this.teamAId, required this.teamBId, required this.matchId});

  @override
  _ScoreboardScreenState createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  Team? _teamA;
  Team? _teamB;
  int _totalScoreA = 0;
  int _totalScoreB = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMatchData();
  }

  Future<void> _fetchMatchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final matchDoc = await FirebaseFirestore.instance
          .collection('matches')
          .doc(widget.matchId)
          .get();

      if (matchDoc.exists) {
        final matchData = matchDoc.data() as Map<String, dynamic>;

        // print('Match Data: $matchData');
        final teamAData = matchData['teamA'] as Map<String, dynamic>;
        final teamBData = matchData['teamB'] as Map<String, dynamic>;

        // print('Team A Data: $teamAData');
        // print('Team B Data: $teamBData');

        final teamAPlayers = (teamAData['players'] as List<dynamic>)
            .map((playerData) => Player.fromMap(playerData as Map<String, dynamic>))
            .toList();

        final teamBPlayers = (teamBData['players'] as List<dynamic>)
            .map((playerData) => Player.fromMap(playerData as Map<String, dynamic>))
            .toList();

        _teamA = Team(
          name: widget.teamAId,
          players: teamAPlayers,
        );
        _teamB = Team(
          name: widget.teamBId,
          players: teamBPlayers,
        );

        _totalScoreA = _calculateTotalScore(teamAPlayers);
        _totalScoreB = _calculateTotalScore(teamBPlayers);

        print('Total Score A: $_totalScoreA, Total Score B: $_totalScoreB');
      } else {
        print('Match not found with the ID ${widget.matchId}');
      }
    } catch (e) {
      print('Error fetching match data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int _calculateTotalScore(List<Player> players) {
    int totalScore = 0;

    for (var player in players) {
      totalScore += player.runs;
    }
    print("Calculated Total Score: $totalScore");
    return totalScore;
  }

  String _getMatchResult() {
    print('Comparing scores - Team A: $_totalScoreA, Team B: $_totalScoreB');  // Debug print

    if (_totalScoreA > _totalScoreB) {
      return "${_teamA!.name} won this match by ${_totalScoreA - _totalScoreB} runs";
    } else if (_totalScoreB > _totalScoreA) {
      return "${_teamB!.name} won this match by ${_totalScoreB - _totalScoreA} runs";
    } else {
      return "MATCH TIED";
    }
  }

  Color _getTeamCardBorderColor(bool isTeamA) {
    if (_totalScoreA > _totalScoreB) {
      return isTeamA ? Colors.green : Colors.red;
    } else if (_totalScoreB > _totalScoreA) {
      return isTeamA ? Colors.red : Colors.green;
    } else {
      return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        backButtonTitle: "      Scoreboard",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg',
        imageOpacity: 0.7,
        title: '',
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _teamA == null || _teamB == null
          ? Center(child: Text('Error loading teams'))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildTeamIconCard(widget.teamAId, true),
                SizedBox(width: 25),
                Text(
                  'Vs',
                  style: TextStyle(
                    color: Colors.indigo[900],
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                ),
                SizedBox(width: 25),
                _buildTeamIconCard(widget.teamBId, false),
              ],
            ),
            SizedBox(height: 25),
            Text(
              _getMatchResult(),
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _buildTeamScoreCard(_teamA!, _totalScoreA, isTeamA: true),
            SizedBox(height: 20),
            _buildTeamScoreCard(_teamB!, _totalScoreB, isTeamA: false),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamIconCard(String teamId, bool isTeamA) {
    return Container(
      height: 130,
      width: 130,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.sports_cricket, color: Colors.indigo[900], size: 40),
          SizedBox(height: 8),
          Text(
            teamId,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: _getTeamCardBorderColor(isTeamA), width: 2),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreCard(Team team, int totalScore, {required bool isTeamA}) {
    return Card(
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: _getTeamCardBorderColor(isTeamA), width: 2),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              team.name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: _getTeamCardBorderColor(isTeamA),
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Total Score: $totalScore',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: totalScore == _totalScoreA || totalScore == _totalScoreB
                    ? Colors.green
                    : Colors.black,
              ),
            ),
            SizedBox(height: 10),
            ...team.players.map((player) => ListTile(
              title: Text(player.name),
              subtitle: Text('Runs: ${player.runs}, Balls: ${player.balls}, Out: ${player.isOut ? "Yes" : "No"}'),
              trailing: Text(
                '${player.runs}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[900],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
