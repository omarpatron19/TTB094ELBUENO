import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:my_statuses/model/asistencia.dart';
import 'package:my_statuses/utilities/constants.dart';

class AsistenciaPadres extends StatelessWidget {
  final DateTime fecha;
  final List<String> hijos;
  AsistenciaPadres({this.fecha, this.hijos});
  @override
  Widget build(BuildContext context) {
    var today = new DateTime(fecha.year, fecha.month, fecha.day);
    var tomorrow = new DateTime(fecha.year, fecha.month, fecha.day+1);
    if (this.hijos != null) {
      return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection(Constants.asistencia)
              .where('timestamp', isGreaterThan: today)
              .where('timestamp', isLessThan: tomorrow)
              .where("idAlumno", whereIn: hijos)
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
    } else {
      return Center(
          child: Text("No hay asistencias el dia " +
              fecha.toLocal().toString().split(" ")[0]));
    }
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
