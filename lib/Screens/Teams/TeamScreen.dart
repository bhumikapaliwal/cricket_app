import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cricketapp/Models/Players.dart';
import 'package:cricketapp/Models/Team.dart';
import 'package:cricketapp/utils/costumappbar.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class CreateTeamScreen extends StatefulWidget {
  @override
  _CreateTeamScreenState createState() => _CreateTeamScreenState();
}

class _CreateTeamScreenState extends State<CreateTeamScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<GlobalKey<FormState>> _playerFormKeys = List.generate(11, (_) => GlobalKey<FormState>());
  String teamName = '';
  List<Player> players = List.generate(11, (index) => Player(name: '', age: 0, height: 0.0));
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

  Future<void> _saveTeam() async {
    if (_formKey.currentState?.validate() ?? false) {
      bool allPlayersValid = true;

      for (final key in _playerFormKeys) {
        if (!(key.currentState?.validate() ?? false)) {
          allPlayersValid = false;
        }
      }

      if (!allPlayersValid) {
        return;
      }

      _formKey.currentState?.save();

      for (final key in _playerFormKeys) {
        key.currentState?.save();
      }

      Team team = Team(name: teamName, players: players);

      _showLoadingDialog();

      try {
        await FirebaseFirestore.instance.collection('teams').doc(team.name).set(team.toMap());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Team has been created successfully')),
        );
        await Future.delayed(Duration(seconds: 1));

        Navigator.of(context).pop();
        await Future.delayed(Duration(seconds: 3));
        Navigator.pop(context);
      } catch (error) {
        Navigator.of(context).pop();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating team')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a team name')),
      );
    }
  }


  void _checkPlayerFormValidation(int index) {
    if (_playerFormKeys[index].currentState != null && !_playerFormKeys[index].currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all player details for Player ${index + 1}')),
      );
    }
  }

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a name';
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.isEmpty) return 'Please enter an age';
    final int? age = int.tryParse(value);
    if (age == null || age <= 0) return 'Please enter a valid age';
    return null;
  }

  String? _validateHeight(String? value) {
    if (value == null || value.isEmpty) return 'Please enter a height';
    final double? height = double.tryParse(value);
    if (height == null || height <= 0) return 'Please enter a valid height';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomCurvedAppBar(
        backButtonTitle: "Add Team",
        height: 170,
        showBackButton: true,
        menubar: false,
        backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg',
        imageOpacity: 0.7,
        title: '',
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Team Name',
                      labelStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    style: TextStyle(color: Colors.black),
                    validator: _validateName,
                    onSaved: (value) => teamName = value!,
                  ),
                ),
                SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: 11,
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.5),
                                spreadRadius: 1,
                                blurRadius: 2,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                          child: ExpansionTile(
                            title: Text(
                              'Player ${index + 1} Details',
                              style: TextStyle(color: Colors.black),
                            ),
                            onExpansionChanged: (isExpanded) {
                              if (!isExpanded) {
                                // Trigger validation when collapsing the tile
                                _checkPlayerFormValidation(index);
                              }
                            },
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Form(
                                  key: _playerFormKeys[index],
                                  child: Column(
                                    children: [
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Name',
                                          labelStyle: TextStyle(color: Colors.black),
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.indigo.shade200, width: 1.0),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                        style: TextStyle(color: Colors.black),
                                        validator: _validateName,
                                        onSaved: (value) => players[index].name = value!,
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Age',
                                          labelStyle: TextStyle(color: Colors.black),
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.indigo.shade200, width: 1.0),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(color: Colors.black),
                                        validator: _validateAge,
                                        onSaved: (value) => players[index].age = int.parse(value!),
                                      ),
                                      SizedBox(height: 8),
                                      TextFormField(
                                        decoration: InputDecoration(
                                          labelText: 'Height',
                                          labelStyle: TextStyle(color: Colors.black),
                                          fillColor: Colors.white,
                                          filled: true,
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.indigo.shade200, width: 1.0),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        ),
                                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                                        style: TextStyle(color: Colors.black),
                                        validator: _validateHeight,
                                        onSaved: (value) => players[index].height = double.parse(value!),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.indigo[800]!),
                  ),
                  onPressed: _saveTeam,
                  child: Text('Save Team', style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
