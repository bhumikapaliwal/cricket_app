import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/Models/Players.dart';
import 'package:cricketapp/Models/Team.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:flutter/material.dart';

import 'ScoreboardScreen.dart';

class TeamScoreForm extends StatefulWidget {
  final String matchId;
  final String teamName;

  TeamScoreForm({required this.matchId,required this.teamName,});

  @override
  _TeamScoreFormState createState() => _TeamScoreFormState();
}

class _TeamScoreFormState extends State<TeamScoreForm> with SingleTickerProviderStateMixin {
  final _formKeyTeamA = GlobalKey<FormState>();
  final _formKeyTeamB = GlobalKey<FormState>();
  Team? _teamA;
  Team? _teamB;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _fetchMatch();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _fetchMatch() async {
    try {
      final matchDoc = await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).get();

      if (matchDoc.exists) {
        final matchData = matchDoc.data() as Map<String, dynamic>;

        // Extract match details
        final matchPlace = matchData['matchPlace'] as String;
        final matchDate = matchData['matchDate'] as String;
        final teamAId = matchData['teamAId'] as String;
        final teamBId = matchData['teamBId'] as String;
        final totalOvers = matchData['totalOvers'] as int;
        final teamAScoreStatus = matchData['teamA_scoreStatus'] as String;
        final teamBScoreStatus = matchData['teamB_scoreStatus'] as String;

        // Extract player data for both teams
        final teamAPlayersData = matchData['teamA'] as List<dynamic>;
        final teamBPlayersData = matchData['teamB'] as List<dynamic>;

        // Convert player data to Player objects
        final teamAPlayers = teamAPlayersData.map((playerData) => Player.fromMap(playerData)).toList();
        final teamBPlayers = teamBPlayersData.map((playerData) => Player.fromMap(playerData)).toList();

        // Create Team objects (if needed)
        _teamA = Team(
          name: teamAId,
          players: teamAPlayers,
        );

        _teamB = Team(
          name: teamBId,
          players: teamBPlayers,
        );

        // Update state with the fetched data
        setState(() {});
      } else {
        print('Match not found with the ID ${widget.matchId}');
      }
    } catch (e) {
      print('Error fetching match: $e');
    }
  }



  void _saveScores(Team team, GlobalKey<FormState> formKey) async {
    if (formKey.currentState?.validate() ?? false) {
      formKey.currentState?.save();

      try {
        final totalRuns = team.players.fold(0, (sum, player) => sum + player.runs);
        final totalBalls = team.players.fold(0, (sum, player) => sum + player.balls);

        final playersData = team.players.map((player) => player.toMap()).toList();

        final teamField = team.name == _teamA?.name ? 'teamA' : 'teamB';

        await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).update({
          '$teamField.players': playersData,
          '$teamField.totalRuns': totalRuns,
          '$teamField.totalBalls': totalBalls,
          '${teamField}_scoreStatus': 'updated',
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scores added successfully')),
        );

        final matchData = await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).get();
        final teamAScoreStatus = matchData['teamA_scoreStatus'];
        final teamBScoreStatus = matchData['teamB_scoreStatus'];

        final teamAId = matchData['teamAId'];
        final teamBId = matchData['teamBId'];

        if (teamAScoreStatus == 'updated' && teamBScoreStatus == 'updated') {
          await Future.delayed(Duration(seconds: 3));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScoreboardScreen(
                teamAId: teamAId,
                teamBId: teamBId, matchId: widget.matchId,
              ),
            ),
          );
        } else if (team.name == _teamB?.name) {
          await Future.delayed(Duration(seconds: 3));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScoreboardScreen(
                teamAId: teamAId,
                teamBId: teamBId, matchId:widget.matchId,
              ),
            ),
          );
        }
      } catch (e) {
        print('Error saving scores: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving scores')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    if (_teamA == null || _teamB == null) {
      return Scaffold(
        appBar: CustomCurvedAppBar(
          backButtonTitle: "      Add Scores",
          height: 170,
          showBackButton: true,
          menubar: false,
          backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
          imageOpacity: 0.7, title: '',
        ),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        backButtonTitle: "      Add Scores",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
        imageOpacity: 0.7, title: '',
      ),
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            tabs: [
              Tab(text: _teamA?.name ?? 'Team A'),
              Tab(text: _teamB?.name ?? 'Team B'),
            ],
            labelColor: Colors.indigo[900],
            indicatorColor: Colors.indigo[900],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildTeamScoreForm(_teamA!, _formKeyTeamA),
                _buildTeamScoreForm(_teamB!, _formKeyTeamB),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScoreForm(Team team, GlobalKey<FormState> formKey) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              SizedBox(height: 20,),
              Text(
                'Enter Scores for ${team.name}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.indigo[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20,),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: team.players.length,
                itemBuilder: (context, index) {
                  final player = team.players[index];
                  return Container(
                    margin: EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.indigo[800]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.blue[50],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.indigo[200],
                                    border: Border(
                                      right: BorderSide(color: Colors.indigo[800]!),
                                    ),
                                  ),
                                  child: Text(
                                    player.name,
                                    style: TextStyle(
                                      color: Colors.indigo[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(12),
                                  color: Colors.white,
                                  child: Text(
                                    'Scores',
                                    style: TextStyle(
                                      color: Colors.indigo[900],
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          ExpansionTile(
                            title: Text(
                              'Details for ${player.name}',
                              style: TextStyle(color: Colors.indigo[800]),
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.indigo[800]!),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      child: TextFormField(
                                        initialValue: player.runs.toString(),
                                        decoration: InputDecoration(
                                          labelText: 'Runs',
                                          labelStyle: TextStyle(color: Colors.indigo[800]),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return 'Please enter runs';
                                          return null;
                                        },
                                        onSaved: (value) => player.runs = int.parse(value!),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.indigo[800]!),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      child: TextFormField(
                                        initialValue: player.balls.toString(),
                                        decoration: InputDecoration(
                                          labelText: 'Balls',
                                          labelStyle: TextStyle(color: Colors.indigo[800]),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.all(12),
                                        ),
                                        keyboardType: TextInputType.number,
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return 'Please enter balls';
                                          return null;
                                        },
                                        onSaved: (value) => player.balls = int.parse(value!),
                                      ),
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(bottom: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(color: Colors.indigo[800]!),
                                        borderRadius: BorderRadius.circular(4),
                                        color: Colors.white,
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: player.isOut,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                player.isOut = value!;
                                              });
                                            },
                                          ),
                                          Text(
                                            'Is Out?',
                                            style: TextStyle(color: Colors.indigo[800]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _saveScores(team, formKey),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo[900],
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                child: Text(
                  'Save Scores',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),);
  }

}