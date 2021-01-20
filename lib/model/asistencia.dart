import 'package:cloud_firestore/cloud_firestore.dart';

class AsistenciaModel {
  String idAlumno;
  String nombre;
  String timestamp;
  AsistenciaModel({this.idAlumno, this.nombre});
  toMap() {
    return {
      'idAlumno': idAlumno,
      'nombre': nombre,
      'timestamp': FieldValue.serverTimestamp(),
    };
  }

  factory AsistenciaModel.fromJSON(Map<String, dynamic> json) {
    return AsistenciaModel(idAlumno: json["idAlumno"], nombre: json["nombre"]);
  }

  factory AsistenciaModel.fromMap(Map map) {
    return AsistenciaModel(
      idAlumno: map["idAlumno"],
      nombre: map["nombre"],
    );
  }
}
