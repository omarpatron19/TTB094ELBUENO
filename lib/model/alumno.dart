class AlumnoModel {
  String nombre;
  String padre;
  String alergias;
  int edad;
  AlumnoModel({this.nombre, this.padre, this.alergias, this.edad});

  toMap() {
    return {
      'nombre': nombre,
      'padre': padre,
      'alergias': alergias,
      'edad': edad,
    };
  }

  factory AlumnoModel.fromJSON(Map<String, dynamic> json) {
    return AlumnoModel(
        nombre: json["nombre"],
        padre: json["padre"],
        alergias: json["alergias"],
        edad: json["edad"]);
  }

  factory AlumnoModel.fromMap(Map map) {
    return AlumnoModel(
      nombre: map["nombre"],
      padre: map["padre"],
      alergias: map["alergias"],
      edad: map["edad"],
    );
  }
}
