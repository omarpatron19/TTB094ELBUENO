import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:my_statuses/model/alumno.dart';
import 'package:my_statuses/model/user_model.dart';
import 'package:url_launcher/url_launcher.dart';

class AlumnoScreen extends StatefulWidget {
  final AlumnoModel alumno;
  final UserModel padre;
  AlumnoScreen({this.alumno, this.padre});
  @override
  _AlumnoScreenState createState() =>
      _AlumnoScreenState(alumno: alumno, padre: padre);
}

class _AlumnoScreenState extends State<AlumnoScreen> {
  _AlumnoScreenState({this.alumno, this.padre});
  User firebaseUser;
  getData() {
    firebaseUser = FirebaseAuth.instance.currentUser;
  }

  AlumnoModel alumno;
  UserModel padre;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Datos del alumno"),
        ),
        body: Center(
            child: Container(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    new Text("Nombre del alumno: " + alumno.nombre),
                    new Text("Edad del alumno: " + alumno.edad.toString()),
                    new Text("Alergias: " + alumno.alergias),
                    new Text("Nombre del padre: " + padre.name),
                    new Text("Numero de telefono: " + padre.mobileNumber),
                    RaisedButton(
                      color: Colors.blue,
                      onPressed: () {
                        launch("tel://" + padre.mobileNumber);
                      },
                      child: Text(
                        "Llamar al padre.",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ))));
  }
}
