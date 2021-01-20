import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_statuses/model/asistencia.dart';
import 'package:my_statuses/utilities/constants.dart';

class HistorialAsistencia extends StatelessWidget {
  final DateTime fecha;
  HistorialAsistencia({this.fecha});
  @override
  Widget build(BuildContext context) {
    var today = new DateTime(fecha.year, fecha.month, fecha.day);
    var tomorrow = new DateTime(fecha.year, fecha.month, fecha.day+1);
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
              return Center(
                  child: Text("No hay asistencias el dia " +
                      fecha.toLocal().toString().split(" ")[0]));
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
        title: Text(asistencia.nombre)
      ),
    );
  }
}
