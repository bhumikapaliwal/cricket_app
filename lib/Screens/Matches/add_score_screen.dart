// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cricketapp/Models/Players.dart';
// import 'package:cricketapp/Models/Team.dart';
// import 'package:cricketapp/utils/costumappbar.dart';
// import 'package:flutter/material.dart';
//
// class AddScoresScreen extends StatefulWidget {
//   final String teamName;
//
//   AddScoresScreen({required this.teamName});
//
//   @override
//   _AddScoresScreenState createState() => _AddScoresScreenState();
// }
//
// class _AddScoresScreenState extends State<AddScoresScreen> {
//   final _formKey = GlobalKey<FormState>();
//   Team? _team;
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchTeam();
//   }
//
//   Future<void> _fetchTeam() async {
//     try {
//       final doc = await FirebaseFirestore.instance.collection('teams').doc(widget.teamName).get();
//       if (doc.exists) {
//         setState(() {
//           _team = Team.fromMap(doc.data()!);
//           print('Team fetched successfully: ${_team?.name}');
//         });
//       } else {
//         print('No team found with the name ${widget.teamName}');
//       }
//     } catch (e) {
//       print('Error fetching team: $e');
//     }
//   }
//
//   void _saveScores() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();
//       try {
//         await FirebaseFirestore.instance.collection('teams').doc(_team!.name).set(_team!.toMap());
//         print('Scores saved successfully for team ${_team?.name}');
//         Navigator.pop(context);
//       } catch (e) {
//         print('Error saving scores: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: CustomCurvedAppBar(
//         backButtonTitle: "     Add Scores",
//         height: 170,
//         showBackButton: true,
//         menubar: false,
//         backgroundImage: 'assets/pexels-mam-ashfaq-1314585-3452356.jpg', // Replace with your image path
//         imageOpacity: 0.7, title: '',
//       ),
//       body: _team != null
//           ? SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               children: [
//                 Text(
//                   'Add Scores for ${_team!.name}',
//                   style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     color: Colors.indigo[900],
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 20,),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: NeverScrollableScrollPhysics(),
//                   itemCount: _team!.players.length,
//                   itemBuilder: (context, index) {
//                     final player = _team!.players[index];
//                     return Container(
//                       margin: EdgeInsets.symmetric(vertical: 8),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.indigo[800]!),
//                         borderRadius: BorderRadius.circular(8),
//                         color: Colors.blue[50],
//                       ),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(8), // Apply the same border radius
//                         child: Column(
//                           children: [
//                             Row(
//                               children: [
//                                 Expanded(
//                                   child: Container(
//                                     padding: EdgeInsets.all(12),
//                                     decoration: BoxDecoration(
//                                       color: Colors.indigo[200],
//                                       border: Border(
//                                         right: BorderSide(color: Colors.indigo[800]!),
//                                       ),
//                                     ),
//                                     child: Text(
//                                       player.name,
//                                       style: TextStyle(
//                                         color: Colors.indigo[900],
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                                 Expanded(
//                                   child: Container(
//                                     padding: EdgeInsets.all(12),
//                                     color: Colors.white,
//                                     child: Text(
//                                       'Scores',
//                                       style: TextStyle(
//                                         color: Colors.indigo[900],
//                                         fontWeight: FontWeight.bold,
//                                       ),
//                                       textAlign: TextAlign.center,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                             ExpansionTile(
//                               title: Text(
//                                 'Details for ${player.name}',
//                                 style: TextStyle(color: Colors.indigo[800]),
//                               ),
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment: CrossAxisAlignment.start,
//                                     children: [
//                                       Container(
//                                         margin: EdgeInsets.only(bottom: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: Colors.indigo[800]!),
//                                           borderRadius: BorderRadius.circular(4),
//                                           color: Colors.white,
//                                         ),
//                                         child: TextFormField(
//                                           initialValue: player.runs.toString(),
//                                           decoration: InputDecoration(
//                                             labelText: 'Runs',
//                                             labelStyle: TextStyle(color: Colors.indigo[800]),
//                                             border: InputBorder.none,
//                                             contentPadding: EdgeInsets.all(12),
//                                           ),
//                                           keyboardType: TextInputType.number,
//                                           validator: (value) {
//                                             if (value == null || value.isEmpty)
//                                               return 'Please enter runs';
//                                             return null;
//                                           },
//                                           onSaved: (value) =>
//                                           player.runs = int.parse(value!),
//                                         ),
//                                       ),
//                                       Container(
//                                         margin: EdgeInsets.only(bottom: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: Colors.indigo[800]!),
//                                           borderRadius: BorderRadius.circular(4),
//                                           color: Colors.white,
//                                         ),
//                                         child: TextFormField(
//                                           initialValue: player.balls.toString(),
//                                           decoration: InputDecoration(
//                                             labelText: 'Balls',
//                                             labelStyle: TextStyle(color: Colors.indigo[800]),
//                                             border: InputBorder.none,
//                                             contentPadding: EdgeInsets.all(12),
//                                           ),
//                                           keyboardType: TextInputType.number,
//                                           validator: (value) {
//                                             if (value == null || value.isEmpty)
//                                               return 'Please enter balls';
//                                             return null;
//                                           },
//                                           onSaved: (value) =>
//                                           player.balls = int.parse(value!),
//                                         ),
//                                       ),
//                                       Container(
//                                         margin: EdgeInsets.only(bottom: 8),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(color: Colors.indigo[800]!),
//                                           borderRadius: BorderRadius.circular(4),
//                                           color: Colors.white,
//                                         ),
//                                         child: Row(
//                                           children: [
//                                             Checkbox(
//                                               value: player.isOut,
//                                               onChanged: (bool? value) {
//                                                 setState(() {
//                                                   player.isOut = value!;
//                                                 });
//                                               },
//                                             ),
//                                             Text("Is Out"),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   style: ButtonStyle(
//                     backgroundColor:
//                     MaterialStateProperty.all<Color>(Colors.indigo[800]!),
//                   ),
//                   onPressed: _saveScores,
//                   child: Text(
//                     'Save Scores',
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       )
//           : Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }