import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/Screens/Matches/MatchScreen.dart';
import 'package:cricketapp/Screens/Matches/MatchlistScreen.dart';
import 'package:cricketapp/Screens/Matches/ScoreboardScreen.dart';
import 'package:cricketapp/Screens/Matches/match_detail.dart';
import 'package:cricketapp/Screens/Teams/TeamListScreen.dart';
import 'package:cricketapp/Screens/Teams/TeamScreen.dart';
import 'package:cricketapp/Screens/Matches/addscorescreen.dart';
import 'package:cricketapp/Screens/menubar.dart';
import 'package:cricketapp/Services/firebase_services.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'Matches/add_score_screen.dart';

class MyHomePage extends StatefulWidget {
  final String? backgroundImage ;
  final double imageOpacity;

  const MyHomePage({super.key, this.backgroundImage, this.imageOpacity = 0.3});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AuthServices _authServices;
  String _userName = "Guest";
  String _profileImageUrl = "";

  @override
  void initState() {
    super.initState();
    _authServices = Provider.of<AuthServices>(context, listen: false);
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final userProfile = await _authServices.getCurrentUserProfile();
    if (userProfile != null) {
      setState(() {
        _userName = userProfile['name'] ?? "Guest";
        _profileImageUrl = userProfile['profileimage'] ?? "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthServices>(context);
    User? user = authService.getCurrentUser();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigo[900],
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CreateMatchScreen(),
            ),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
       // drawer: NevBar(),
      backgroundColor: Colors.white,
      appBar:CustomCurvedAppBar(menuTitle: "HomePage",
        height: 170,
        showBackButton: false,
        menubar: true,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
        imageOpacity: 0.6, title: '',
      ),
      drawer: NevBar(),
      body:  Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Teams',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 250),
                  TextButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TeamListScreen(),
                      ),
                    );
                  },child: Text(
                    'Show all',
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ],
              ),
              // SizedBox(width: 7),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('teams').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(child: Text("No teams available"));
                    }

                    var teams = snapshot.data!.docs;

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Row(
                              children: teams.map((team) {
                                var teamData = team.data() as Map<String, dynamic>;
                                return SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Container(
                                    width: 110,
                                    height: 110,
                                    padding: EdgeInsets.all(8),
                                    margin: EdgeInsets.only(right: 16),
                                    decoration: BoxDecoration(

                                      color: Colors.white,
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
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        TextButton(onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => AddScoresScreen(teamName: teamData['name'])
                                              // AddScoresScreen(matchId: match.id, teamAId: match['teamAId'], teamBId: 'teamBId',),
                                            ),
                                          );
                                        },style: ButtonStyle(
                                          padding: MaterialStateProperty.all(EdgeInsets.zero),
                                        ),
                                        child: Icon(Icons.sports_cricket, color: Colors.indigo[900], size: 40)),
                                        SizedBox(height: 8),
                                        Text(
                                          teamData['name'],
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

                              }).toList(),
                            ),
                            Container(
                              height: 110,
                              width: 110,
                              child: FloatingActionButton(
                                backgroundColor: Colors.white,
                                child: Icon(Icons.add, color: Colors.indigo[900]),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CreateTeamScreen(),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height:7),
              Row(
                children: [
                  Text(
                    'Upcoming Matches',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 143),
                  TextButton(onPressed: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchListScreen(),
                      ),
                    );
                  },child: Text(
                    'Show all',
                    style: TextStyle(
                      color: Colors.indigo[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ),
                ],
              ),
              SizedBox(height: 25),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('matches')
                      .orderBy('matchDate', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var matches = snapshot.data!.docs;
                    final currentDate = DateTime.now();
                    var filteredMatches = matches.where((match) {
                      var matchData = match.data() as Map<String, dynamic>;
                      DateTime matchDate = DateTime.parse(matchData['matchDate']);
                      return matchDate.isAfter(currentDate) || matchDate.isAtSameMomentAs(currentDate);
                    }).toList();

                    if (filteredMatches.isEmpty) {
                      return Center(child: Text('No upcoming matches found.'));
                    }

                    return ListView.builder(
                      itemCount: filteredMatches.length,
                      itemBuilder: (context, index) {
                        var matchData = filteredMatches[index].data() as Map<String, dynamic>;
                        var teamAId = matchData['teamAId'] as String;
                        var teamBId = matchData['teamBId'] as String;

                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                            color: Colors.white,
                            elevation: 5,
                            margin: EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: Icon(Icons.sports_cricket, color: Colors.indigo[900]),
                              title: Text('Match at ${matchData['matchPlace']}'),
                              subtitle: Text('Date: ${matchData['matchDate']}'),
                              trailing: Icon(Icons.arrow_forward),
                              onTap: () async {
                                try {
                                  final matchDoc = await FirebaseFirestore.instance
                                      .collection('matches')
                                      .doc(filteredMatches[index].id)
                                      .get();

                                  final teamAScoreStatus = matchDoc.data()?['teamA_scoreStatus'] ?? 'notUpdated';
                                  final teamBScoreStatus = matchDoc.data()?['teamB_scoreStatus'] ?? 'notUpdated';

                                  DateTime matchDate = DateTime.parse(matchData['matchDate']);

                                  if (matchDate.isAfter(currentDate)) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => MatchDetail(
                                          matchId: filteredMatches[index].id,
                                        ),
                                      ),
                                    );
                                  } else {
                                    if (teamAScoreStatus == 'updated' && teamBScoreStatus == 'updated') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ScoreboardScreen(
                                            teamAId: teamAId,
                                            teamBId: teamBId, matchId:filteredMatches[index].id,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TeamScoreForm(
                                            matchId: filteredMatches[index].id,
                                            teamName: teamAScoreStatus == 'notUpdated' ? teamAId : teamBId,
                                          ),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  print('Error fetching match details: $e');
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error: $e')),
                                  );
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),


            ],
          ),
        ),

    );
  }

}
