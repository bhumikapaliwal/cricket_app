import 'package:cricketapp/Screens/Matches/MatchScreen.dart';
import 'package:cricketapp/Screens/Matches/addscorescreen.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:cricketapp/Screens/Matches/add_score_screen.dart';
import 'package:cricketapp/Screens/Matches/match_detail.dart';
import 'package:cricketapp/Screens/Matches/ScoreboardScreen.dart';

class MatchListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      appBar: CustomCurvedAppBar(
        backButtonTitle: "       Matches",
        height: 170,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg',
        menubar: false,
        imageOpacity: 0.4, title: '',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('matches')
            .orderBy('matchDate', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No matches found.'));
          }

          final matches = snapshot.data!.docs;

          return ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final match = matches[index];
              return MatchCard(match: match);
            },
          );
        },
      ),
    );
  }
}


class MatchCard extends StatelessWidget {
  final QueryDocumentSnapshot match;

  const MatchCard({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = match.data() as Map<String, dynamic>;

    // Check if teamAId and teamBId are String or Map<String, dynamic>
    String teamAName;
    String teamBName;

    if (data['teamAId'] is String) {
      // If teamAId is a String, use it as the team name
      teamAName = data['teamAId'] as String;
    } else if (data['teamAId'] is Map<String, dynamic>) {
      // If teamAId is a Map, extract the 'name' field
      teamAName = (data['teamAId'] as Map<String, dynamic>)['name'] ?? 'Unknown Team A';
    } else {
      // Fallback in case neither condition is met
      teamAName = 'Unknown Team A';
    }

    if (data['teamBId'] is String) {
      // If teamBId is a String, use it as the team name
      teamBName = data['teamBId'] as String;
    } else if (data['teamBId'] is Map<String, dynamic>) {
      // If teamBId is a Map, extract the 'name' field
      teamBName = (data['teamBId'] as Map<String, dynamic>)['name'] ?? 'Unknown Team B';
    } else {
      // Fallback in case neither condition is met
      teamBName = 'Unknown Team B';
    }

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        height: 267,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0, left: 15.0, right: 15.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TeamButton(
                    teamName: teamAName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddScoresScreen(teamName: teamAName),
                        ),
                      );
                    },
                  ),
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
                  TeamButton(
                    teamName: teamBName,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddScoresScreen(teamName: teamBName),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 10.0),
              MatchDetailsTile(match: match),
            ],
          ),
        ),
      ),
    );
  }
}

class TeamButton extends StatelessWidget {
  final String teamName;
  final VoidCallback onTap;

  const TeamButton({Key? key, required this.teamName, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: 130,
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
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.sports_cricket, color: Colors.indigo[900], size: 40),
            SizedBox(height: 8),
            Text(
              teamName,
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
}

class MatchDetailsTile extends StatelessWidget {
  final QueryDocumentSnapshot match;

  const MatchDetailsTile({Key? key, required this.match}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      // elevation: 5,
      // margin: EdgeInsets.symmetric(vertical: 8),
      child: Container(decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey, width: 0.6),
        borderRadius: BorderRadius.circular(10),),
        child: ListTile(
          leading: Icon(Icons.sports_cricket, color: Colors.indigo[900]),
          title: Text('Match at ${match['matchPlace']}'),
          subtitle: Text('Date: ${match['matchDate']}'),
          trailing: Icon(Icons.arrow_forward),
          onTap: ()
          => _handleMatchTap(context, match),
        ),
      ),
    );
  }

  Future<void> _handleMatchTap(BuildContext context, QueryDocumentSnapshot match) async {
    // Access match data as a map
    final data = match.data() as Map<String, dynamic>;

    // Safely handle teamAId and teamBId based on their types
    final teamAId = data['teamAId'] is String
        ? data['teamAId'] as String
        : (data['teamAId'] as Map<String, dynamic>)['name'] as String?;

    final teamBId = data['teamBId'] is String
        ? data['teamBId'] as String
        : (data['teamBId'] as Map<String, dynamic>)['name'] as String?;

    if (teamAId == null || teamBId == null) {
      print('Error: teamAId or teamBId is null');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: Unable to retrieve team information')),
      );
      return;
    }

    try {
      final matchDoc = await FirebaseFirestore.instance.collection('matches').doc(match.id).get();

      final teamAScoreStatus = matchDoc.data()?['teamA_scoreStatus'] ?? 'notUpdated';
      final teamBScoreStatus = matchDoc.data()?['teamB_scoreStatus'] ?? 'notUpdated';

      final currentDate = DateTime.now();
      final matchDate = DateTime.parse(data['matchDate']);

      if (matchDate.isAfter(currentDate)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MatchDetail(matchId: match.id),
          ),
        );
      } else {
        if (teamAScoreStatus == 'updated' && teamBScoreStatus == 'updated') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScoreboardScreen(
                teamAId: teamAId,
                teamBId: teamBId, matchId: match.id,
              ),
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TeamScoreForm(
                teamName: teamAScoreStatus == 'notUpdated' ? teamAId : teamBId,
                matchId: match.id,
              ),
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _handleMatchTap: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }



}

