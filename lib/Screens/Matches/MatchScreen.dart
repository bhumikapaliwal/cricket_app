import 'package:cricketapp/Models/Players.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/costumappbar.dart';
import 'locationscreen.dart';

class CreateMatchScreen extends StatefulWidget {
  @override
  _CreateMatchScreenState createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  String _matchPlace = '';
  String _selectedLocation = '';
  DateTime? _matchDate;
  String? _teamAId;
  String? _teamBId;
  int _totalOvers = 0;
  bool _isLoading = false;

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: Lottie.asset('assets/success.json', width: 300, height: 300),
        );
      },
    );
  }

  Future<void> _saveMatch() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      _showLoadingDialog();
      try {
        String formattedDate = _matchDate != null
            ? "${_matchDate!.year.toString().padLeft(4, '0')}-${_matchDate!.month.toString().padLeft(2, '0')}-${_matchDate!.day.toString().padLeft(2, '0')}"
            : '';

        var teamADoc = await FirebaseFirestore.instance.collection('teams').doc(_teamAId).get();
        var teamBDoc = await FirebaseFirestore.instance.collection('teams').doc(_teamBId).get();

        if (teamADoc.exists && teamBDoc.exists) {
          Map<String, dynamic> teamAData = teamADoc.data() as Map<String, dynamic>;
          Map<String, dynamic> teamBData = teamBDoc.data() as Map<String, dynamic>;

          // Initialize players for both teams
          List<Player> teamAPlayers = List<Player>.from(
            (teamAData['players'] as List<dynamic>).map((playerData) => Player.fromMap(playerData)),
          );
          List<Player> teamBPlayers = List<Player>.from(
            (teamBData['players'] as List<dynamic>).map((playerData) => Player.fromMap(playerData)),
          );

          // Ensure players' stats are initialized to zero (this is optional if default values are used)
          teamAPlayers = teamAPlayers.map((player) {
            return Player(
              name: player.name,
              age: player.age,
              height: player.height,
              runs: 0,
              balls: 0,
              isOut: false,
            );
          }).toList();

          teamBPlayers = teamBPlayers.map((player) {
            return Player(
              name: player.name,
              age: player.age,
              height: player.height,
              runs: 0,
              balls: 0,
              isOut: false,
            );
          }).toList();

          await FirebaseFirestore.instance.collection('matches').add({
            'matchPlace': _matchPlace,
            'matchDate': formattedDate,
            'teamAId': _teamAId,
            'teamBId': _teamBId,
            'totalOvers': _totalOvers,
            'teamA_scoreStatus': 'notUpdated',
            'teamB_scoreStatus': 'notUpdated',
            'teamA': teamAPlayers.map((player) => player.toMap()).toList(),
            'teamB': teamBPlayers.map((player) => player.toMap()).toList(),
          });

          if (_selectedLocation.isNotEmpty) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('locationUrl', _selectedLocation);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Match added successfully')),
          );
          Navigator.of(context).pop();

          await Future.delayed(Duration(seconds: 3));
          Navigator.pop(context);
        } else {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Team data could not be retrieved')),
          );
        }
      } catch (error) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding match')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        title: "",
        backButtonTitle: "      Add Match",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
        imageOpacity: 0.7,
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 40.0,right: 20.0,left: 20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    dividerColor: Colors.transparent,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: ExpansionTile(
                      title: Text('Add match location'),
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 2.0),
                            ),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(12.0),
                              bottomRight: Radius.circular(12.0),
                            ),
                          ),
                          child: TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Add Address Description',
                              hintStyle: TextStyle(
                                fontSize: 16.0,
                                fontWeight: FontWeight.normal,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Please enter a location description';
                              return null;
                            },
                            onSaved: (value) => _matchPlace = value!,
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            border: Border(
                              top: BorderSide(color: Colors.grey, width: 2.0),
                            ),
                          ),
                          child: ListTile(
                            title: Text(
                              _selectedLocation.isEmpty ? 'Select Match Location' : 'Match Place: $_selectedLocation',
                            ),
                            trailing: Icon(Icons.location_on, color: Colors.indigo.shade800),
                            onTap: () async {
                              final selectedLocation = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LocationScreen(),
                                ),
                              );
                              if (selectedLocation != null) {
                                setState(() {
                                  _selectedLocation = selectedLocation;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height:10),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: ListTile(
                  title: Text(_matchDate == null
                      ? 'Select Match Date'
                      : 'Match Date: ${_matchDate.toString().split(' ')[0]}'),
                  trailing: Icon(Icons.calendar_today, color: Colors.indigo.shade800),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null && pickedDate != _matchDate) {
                      setState(() {
                        _matchDate = pickedDate;
                      });
                    }
                  },
                ),
              ),
              SizedBox(height:10),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('teams').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) return CircularProgressIndicator();
                  final teams = snapshot.data!.docs;
                  return Column(
                    children: [
                      DropdownButtonFormField(
                        decoration: InputDecoration(labelText: 'Select Team A',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey,),
                              borderRadius: BorderRadius.circular(12)
                          ),
                        ),dropdownColor: Colors.white,
                        items: teams.map((team) {
                          return DropdownMenuItem(
                            value: team.id,
                            child: Text(team['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _teamAId = value as String;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select Team A';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height:10),
                      DropdownButtonFormField(
                        decoration: InputDecoration(labelText: 'Select Team B',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.grey,),
                              borderRadius: BorderRadius.circular(12)
                          ),),dropdownColor: Colors.white,
                        isDense: true,
                        itemHeight: 50.0,
                        items: teams.where((team) => team.id != _teamAId).map((team) {
                          return DropdownMenuItem(
                            value: team.id,
                            child: Text(team['name']),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _teamBId = value as String;
                          });
                        },
                        validator: (value) {
                          if (value == null) {
                            return 'Please select Team B';
                          }
                          return null;
                        },
                      ),
                    ],
                  );
                },
              ),
              SizedBox(height:10),
              TextFormField(
                decoration: InputDecoration(labelText: 'Total Overs',
                  border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.indigo.shade200, width: 1.0),
                      borderRadius: BorderRadius.circular(12)
                  ),),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter total overs';
                  }
                  return null;
                },
                onSaved: (value) => _totalOvers = int.parse(value!),
              ),
              // SizedBox(height: 20),
              SizedBox(height: 20),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo[800]!),
                ),
                onPressed: _saveMatch,
                child: Text(
                  'Save Match',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
