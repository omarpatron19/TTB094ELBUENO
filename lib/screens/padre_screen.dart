import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_statuses/model/post_model.dart';
import 'package:my_statuses/screens/lista/ListaPadres.dart';
import 'package:my_statuses/screens/splash_screen.dart';
import 'package:my_statuses/screens/auth/actualizarDatos.dart';
import 'package:my_statuses/utilities/constants.dart';
import 'package:my_statuses/utilities/firebase_utils.dart';
import 'package:barcode_scan/barcode_scan.dart';

class PadreScreen extends StatefulWidget {
  @override
  _PadreScreenState createState() => _PadreScreenState();
}

class _PadreScreenState extends State<PadreScreen> {
  ScanResult scanResult;
  int _selectedIndex = 0;
  DateTime selectedDate = new DateTime.now();
  User padre = FirebaseAuth.instance.currentUser;
  List<String> hijos;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    getHijos();
    super.initState();
  }

  void getHijos() async {
    var data = await FirebaseUtils.getHijos(padre.uid);
    setState(() {
      hijos = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("APP Padre de familia"),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.exit_to_app),
              onPressed: () async {
                await FirebaseUtils.removeFirebaseToken();
                FirebaseAuth.instance.signOut().then((onValue) {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => SplashScreen()));
                });
              })
        ],
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () async {
                Navigator.push(context,
                    MaterialPageRoute(builder: (c) => ActualizarScreen()));
              },
              child: Icon(Icons.person),
            )
          : FloatingActionButton(
              onPressed: () async {
                _selectDate(this.context);
              },
              child: Icon(Icons.calendar_today),
            ),
      body: [
        ListaHijos(),
        AsistenciaPadres(fecha: selectedDate, hijos: hijos),
      ].elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.add_alert),
            label: 'Avisos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_turned_in_sharp),
            label: 'Asistencia',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
      ),
    );
  }

  _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
      context: context,
      initialDate: selectedDate, // Refer step 1
      firstDate: DateTime(2000),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }
}

class ListaHijos extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.statues)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot == null || snapshot.data.documents.length == 0) {
            return Center(child: Text("No hay avisos"));
          }
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                PostModel postModel =
                    PostModel.fromJSON(snapshot.data.documents[index].data());
                if(postModel.message!=null){
                  return PostTile(
                    postModel: postModel,
                  );
                }
              });
        });
  }
}

class PostTile extends StatelessWidget {
  final PostModel postModel;
  PostTile({this.postModel});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              new Text(postModel.timestamp.toDate().toString()),
              new Text(postModel.title),
              new Text(
                postModel.message,
                textAlign: TextAlign.justify,
                textDirection: TextDirection.ltr,
              )
            ],
          )),
    );
  }
}
