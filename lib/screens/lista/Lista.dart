import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_statuses/model/asistencia.dart';
import 'package:my_statuses/utilities/constants.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_statuses/utilities/firebase_utils.dart';

class Asistencia extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var today = new DateTime.now();
    today = new DateTime(today.year, today.month, today.day);
    var tomorrow = new DateTime(today.year, today.month, today.day+1);
    return StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection(Constants.asistencia)
            .where('timestamp', isGreaterThan: today)
            .where('timestamp', isLessThan: tomorrow)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          if (snapshot == null || snapshot.data.documents.length == 0) {
            print("TAMAÑO: " + snapshot.data.documents.length.toString());
            return Center(child: Text("No hay asistencias el dia de hoy"));
          }
          return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (context, index) {
                AsistenciaModel asistencia = AsistenciaModel.fromJSON(
                    snapshot.data.documents[index].data());
                return AsistenciaTile(
                  asistencia: asistencia,
                );
              });
        });
  }
}

class AsistenciaTile extends StatelessWidget {
  final AsistenciaModel asistencia;
  AsistenciaTile({this.asistencia});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(asistencia.nombre),
        trailing: IconButton(
          icon: Icon(
            Icons.notification_important,
          ),
          onPressed: () async {
            await FirebaseUtils.enviarAlertaPadre(asistencia.idAlumno);
            Fluttertoast.showToast(msg: "Se ha enviado la notificacion");
          },
        ),
      ),
    );
  }
}
