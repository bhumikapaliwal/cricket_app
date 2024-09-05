import 'package:cricketapp/Models/Team.dart';
import 'package:cricketapp/Screens/Teams/TeamScreen.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../Models/Players.dart';

class TeamListScreen extends StatefulWidget {

  @override
  State<TeamListScreen> createState() => _TeamListScreenState();
}

class _TeamListScreenState extends State<TeamListScreen> {
  String? _editingTeamId;
  String _editedTeamName = '';
  List<Player> _editedPlayers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: 60.0,
          height: 60.0,
          child: FloatingActionButton(
            backgroundColor: Colors.indigo[900],
            onPressed: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CreateTeamScreen(),
              ),
            );
          }, child: Icon(Icons.add,color: Colors.white,),),
        ),
      ),
      appBar: CustomCurvedAppBar(
        backButtonTitle: "      Teams",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg',
        imageOpacity: 0.7, title: '',
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('teams').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          final teams = snapshot.data!.docs;
          return Padding(
            padding: const EdgeInsets.all(15.0),
            child: ListView.builder(
              itemCount: teams.length,
              itemBuilder: (context, index) {
                final team = teams[index];
                return Card(
                  color: Colors.white,
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListTile(
                          title: Text(team['name']),
                          subtitle: Text('Players: ${team['players'].length}'),
                          trailing: IconButton(
                            icon: Icon(Icons.edit,color: Colors.indigo[900],),
                            onPressed: () {
                              setState(() {
                                if (_editingTeamId == team.id) {
                                  _editingTeamId = null;
                                } else {
                                  _editingTeamId = team.id;
                                  _editedTeamName = team['name'];
                                  _editedPlayers = (team['players'] as List)
                                      .map((playerMap) => Player.fromMap(playerMap as Map<String, dynamic>))
                                      .toList();
                                }
                              });
                            },
                          ),
                        ),
                      ),
                      if (_editingTeamId == team.id)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.blue.shade200),
                                  borderRadius: BorderRadius.circular(8),
                                  color: Colors.blue[50],
                                ),
                                padding: const EdgeInsets.all(8.0),
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                child: TextFormField(
                                  initialValue: _editedTeamName,
                                  decoration: InputDecoration(labelText: 'Team Name'),
                                  onChanged: (value) {
                                    _editedTeamName = value;
                                  },
                                ),
                              ),
                              ..._editedPlayers.map((player) {
                                int playerIndex = _editedPlayers.indexOf(player);
                                return Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.indigo.shade200),
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.indigo[50],
                                  ),
                                  padding: const EdgeInsets.all(8.0),
                                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        initialValue: player.name,
                                        decoration: InputDecoration(labelText: 'Player Name'),
                                        onChanged: (value) {
                                          _editedPlayers[playerIndex] = Player(
                                            name: value,
                                            age: player.age,
                                            height: player.height,
                                            runs: player.runs,
                                            balls: player.balls,
                                            isOut: player.isOut,
                                          );
                                        },
                                      ),
                                      TextFormField(
                                        initialValue: player.age.toString(),
                                        decoration: InputDecoration(labelText: 'Player Age'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          _editedPlayers[playerIndex] = Player(
                                            name: player.name,
                                            age: int.parse(value),
                                            height: player.height,
                                            runs: player.runs,
                                            balls: player.balls,
                                            isOut: player.isOut,
                                          );
                                        },
                                      ),
                                      TextFormField(
                                        initialValue: player.height.toString(),
                                        decoration: InputDecoration(labelText: 'Player Height'),
                                        keyboardType: TextInputType.number,
                                        onChanged: (value) {
                                          _editedPlayers[playerIndex] = Player(
                                            name: player.name,
                                            age: player.age,
                                            height: double.parse(value),
                                            runs: player.runs,
                                            balls: player.balls,
                                            isOut: player.isOut,
                                          );
                                        },
                                      ),
                                      SizedBox(height: 10),
                                    ],
                                  ),
                                );
                              }).toList(),
                              Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo[900]!),
                                    ),
                                    onPressed: () => _saveTeam(team.id),
                                    child: Text('Save Changes', style: TextStyle(color: Colors.white)),
                                  ),
                                  const SizedBox(width: 20,),
                                  ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor: MaterialStateProperty.all<Color>(Colors.red!),
                                    ),
                                    onPressed: () => _deleteTeam(team.id),
                                    child: Text('Delete Team', style: TextStyle(color: Colors.white)),
                                  ),

                                ],
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                );

              },
            ),
          );
        },
      ),
    );
  }

  void _saveTeam(String teamId) async {
    List<Map<String, dynamic>> playerMaps = _editedPlayers.map((player) => player.toMap()).toList();
    await FirebaseFirestore.instance.collection('teams').doc(teamId).update({
      'name': _editedTeamName,
      'players': playerMaps,
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Team has been updated successfully')));
    setState(() {
      _editingTeamId = null;
    });
  }

  void _deleteTeam(String teamId) async {
    await FirebaseFirestore.instance.collection('teams').doc(teamId).delete();

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Team has been deleted successfully')));
    setState(() {
      _editingTeamId = null;
    });
  }
}


