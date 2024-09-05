import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/Models/Players.dart';
import 'package:flutter/material.dart';
import 'package:cricketapp/Models/Team.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class MatchDetail extends StatefulWidget {
  final String matchId;

  MatchDetail({required this.matchId});

  @override
  State<MatchDetail> createState() => _MatchDetailState();
}

class _MatchDetailState extends State<MatchDetail> {
  Team? _teamA;
  Team? _teamB;
  List<Player>? _teamAPlayers;
  List<Player>? _teamBPlayers;
  String? _matchDate;
  String? _matchPlace;
  String? _locationUrl;

  @override
  void initState() {
    super.initState();
    _fetchMatchDetails();
  }

  Future<void> _fetchMatchDetails() async {
    try {
      final matchDoc = await FirebaseFirestore.instance.collection('matches').doc(widget.matchId).get();

      if (matchDoc.exists) {
        final matchData = matchDoc.data()!;
        final String matchDate = matchData['matchDate'];
        final String matchPlace = matchData['matchPlace'];
        final String teamAId = matchData['teamAId']; // Assuming this is a string
        final String teamBId = matchData['teamBId']; // Assuming this is a string

        print('Match Data: $matchData');

        final prefs = await SharedPreferences.getInstance();
        _locationUrl = 'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(matchPlace)}';

        // Fetch team details from Firestore using teamAId and teamBId
        final teamADoc = await FirebaseFirestore.instance.collection('teams').doc(teamAId).get();
        final teamBDoc = await FirebaseFirestore.instance.collection('teams').doc(teamBId).get();

        final teamAData = teamADoc.data() as Map<String, dynamic>;
        final teamBData = teamBDoc.data() as Map<String, dynamic>;

        final teamAPlayers = (teamAData['players'] as List<dynamic>).map((playerData) => Player.fromMap(playerData as Map<String, dynamic>)).toList();
        final teamBPlayers = (teamBData['players'] as List<dynamic>).map((playerData) => Player.fromMap(playerData as Map<String, dynamic>)).toList();

        setState(() {
          _matchDate = matchDate;
          _matchPlace = matchPlace;
          _teamA = Team.fromMap(teamAData);
          _teamB = Team.fromMap(teamBData);
          _teamAPlayers = teamAPlayers;
          _teamBPlayers = teamBPlayers;
        });
      } else {
        print('Match not found with the ID ${widget.matchId}');
      }
    } catch (e) {
      print('Error fetching match details: $e');
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        backButtonTitle: "      Match Details",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg',
        imageOpacity: 0.7, title: '',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(23.0),
          child: _teamA == null || _teamB == null || _matchDate == null || _matchPlace == null
              ? Center(child: CircularProgressIndicator())
              : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                TextButton(onPressed: (){}, child: Text("Add Scores")),
                SizedBox(width: 30,),
                TextButton(onPressed: (){}, child: Text("")),
              ],),
              Center(
                child: Text(
                  "Teams",
                  style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[900]),
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: _buildTeamContainer(_teamA!),
                  ),
                  SizedBox(width: 20),
                  Text(
                    'Vs',
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 25,
                    ),
                  ),
                  SizedBox(width: 20),
                  Expanded(
                    child: _buildTeamContainer(_teamB!),
                  ),
                ],
              ),
              SizedBox(height: 30),
              Container(
                height: 50, width: 400,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    "Match Date: $_matchDate",
                    style: TextStyle(
                        fontSize: 18,
                        color: Colors.indigo[900]),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 40,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Wrap(
                    children: [
                      Text(
                        "Match Place: $_matchPlace",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.indigo[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 10),
              _locationUrl != null
                  ? Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 40,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                    child: TextButton(
                      onPressed: () async {
                        if (_locationUrl != null) {
                          final url = _locationUrl!;
                          print('Attempting to launch URL: $url');
                          if (await canLaunch(url)) {
                            await launch(url);
                          } else {
                            print('Could not launch $url');
                          }
                        } else {
                          print('Location URL is null');
                        }
                      },
                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.location_on,color: Colors.indigo[900],),
                                          SizedBox(width:10,),
                                          Text(
                                            'View Location on Map',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              // decoration: TextDecoration.underline,
                                            ),
                                          ),

                        ],
                      ),
                    ),
                  )

                  : Container(),
              SizedBox(height: 20),
              Card(color: Colors.white,
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 0.6),
                    borderRadius: BorderRadius.circular(10),),
                  child: ExpansionTile(
                      title: Text(
                        "Team A Players",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                      children: [_buildPlayersList("Team A Players", _teamAPlayers)]),
                ),),
              SizedBox(height: 20),
              Card(color: Colors.white,
                elevation: 2,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey, width: 0.6),
                    borderRadius: BorderRadius.circular(10),),
                  child: ExpansionTile(
                      title: Text(
                        "Team B Players",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[900],
                        ),
                      ),
                      children: [_buildPlayersList("Team B Players", _teamBPlayers)]),
                ),)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamContainer(Team team) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.6),
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
      child: TextButton(
        onPressed: () {
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sports_cricket, color: Colors.indigo[900], size: 40),
            SizedBox(height: 8),
            Text(
              team.name, // Display the team name
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayersList(String title, List<Player>? players) {
    return ListView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: players?.length ?? 0,
      itemBuilder: (context, index) {
        final player = players![index];
        return Card(
          color: Colors.white,
          margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.grey, width: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${player.name}',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Age: ${player.age}',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Height: ${player.height}',
                    style: TextStyle(color: Colors.black, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
