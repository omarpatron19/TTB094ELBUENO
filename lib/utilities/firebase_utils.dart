import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:my_statuses/model/alumno.dart';
import 'package:my_statuses/model/post_model.dart';
import 'package:my_statuses/model/asistencia.dart';
import 'package:my_statuses/model/user_model.dart';
import 'package:my_statuses/utilities/constants.dart';
import 'package:my_statuses/utilities/utilities.dart';
import 'package:http/http.dart' as http;

class FirebaseUtils {
  static final StorageReference notificationsStorageReference =
      FirebaseStorage.instance.ref().child(Constants.statues);
  static CollectionReference statuesCollectionsReference =
      FirebaseFirestore.instance.collection(Constants.statues);
  static CollectionReference asistenciaCollectionsReference =
      FirebaseFirestore.instance.collection(Constants.asistencia);
  static CollectionReference alumnosCollectionsReference =
      FirebaseFirestore.instance.collection(Constants.alumno);
  static CollectionReference userCollectionsReference =
      FirebaseFirestore.instance.collection(Constants.usuario);

  static Future<String> uploadImageToStorage(File file) async {
    print("uploadImageToStorage");
    final StorageUploadTask storageUploadTask = notificationsStorageReference
        .child(Utilities.getFileName(file))
        .putFile(file);
    final StorageTaskSnapshot storageTaskSnapshot =
        (await storageUploadTask.onComplete);
    final url = (await storageTaskSnapshot.ref.getDownloadURL());
    print("url : $url");
    return url;
  }

  static Future postNotification(PostModel model, String filePath) async {
    if (filePath != null) {
      if (model.imageURL != null && model.imageURL.contains("https://")) {
        await FirebaseStorage.instance
            .getReferenceFromUrl(model.imageURL)
            .then((onValue) {
          onValue.delete();
        });
      }
      model.imageURL = await uploadImageToStorage(File(filePath));
      print("addProdcut url ${model.imageURL}");
    }
    DocumentReference ref = statuesCollectionsReference.doc();
    if (model.docid != null) {
      ref = statuesCollectionsReference.doc(model.docid);
    }
    model.docid = ref.id;
    model.imageURL = model.imageURL;
    return await ref.set(model.toMap());
  }

  static agregarAsistencia(AsistenciaModel model) async {
    DocumentReference ref = asistenciaCollectionsReference.doc();
    await ref.set(model.toMap());
  }

  static Future<AlumnoModel> datosAlumno(String uid) async {
    DocumentSnapshot ref = await alumnosCollectionsReference.doc(uid).get();
    return AlumnoModel.fromMap(ref.data());
  }

  static Future<UserModel> datosPadre(String uid) async {
    DocumentSnapshot ref = await userCollectionsReference.doc(uid).get();
    return UserModel.fromMap(ref.data());
  }

  static enviarAlertaPadre(String uid) async {
    AlumnoModel alumno = await datosAlumno(uid);
    UserModel padre = await datosPadre(alumno.padre);
    http.Response response = await http.post(
      'https://fcm.googleapis.com/fcm/send',
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization': "key=" + Constants.serverToken,
      },
      body: jsonEncode(
        <String, dynamic>{
          'notification': <String, dynamic>{
            'body': 'Su hijo ' + alumno.nombre + " ha pasado lista.",
            'title': 'Asistencia',
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
          },
          'data': <String, dynamic>{
            "sound": "default",
            "screen": "screenA",
            'status': 'done'
          },
          'to': padre.firebaseToken,
        },
      ),
    );
    if (response.statusCode == 200) {
      print("OK");
    } else {
      print("ERROR: " + response.reasonPhrase);
    }
  }

  static updateFirebaseToken() async {
    FirebaseMessaging firebaseMessaging = FirebaseMessaging();
    String token = await firebaseMessaging.getToken();
    print("updateFirebaseToken $token");
    User user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)
        .update({'firebaseToken': token});
  }

  static actualizarDatos(nombre, telefono) async {
    User user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)
        .update({'name': nombre, 'mobileNumber': telefono});
  }

  static removeFirebaseToken() async {
    User user = FirebaseAuth.instance.currentUser;
    await FirebaseFirestore.instance
        .collection("user")
        .doc(user.uid)
        .update({'firebaseToken': ''});
  }

  static Future<List<String>> getHijos(uid) async {
    QuerySnapshot ref =
        await alumnosCollectionsReference.where("padre", isEqualTo: uid).get();
    if (ref.size == 0) {
      print("VACIO");
      return [];
    } else {
      List<String> resultado = [];
      ref.docs.forEach((element) {
        resultado.add(element.id);
        print(element.id);
      });
      return resultado;
    }
  }
}
