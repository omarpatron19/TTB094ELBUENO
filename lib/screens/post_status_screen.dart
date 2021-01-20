import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_statuses/model/post_model.dart';
import 'package:my_statuses/utilities/circle_loading.dart';
import 'package:my_statuses/utilities/constants.dart';
import 'package:my_statuses/utilities/firebase_utils.dart';
import 'package:my_statuses/utilities/styles.dart';

class PostStatusScreen extends StatefulWidget {
  @override
  _PostStatusScreenState createState() => _PostStatusScreenState();
}

class _PostStatusScreenState extends State<PostStatusScreen> {
  TextEditingController titleEditingController = TextEditingController();
  TextEditingController messageEditingController = TextEditingController();

  bool isLoading = false;

  PostModel postModel;

  BuildContext context;
  var globalKey = GlobalKey<ScaffoldState>();

  String _imagePath;
  Future<File> imageFile;

  @override
  void initState() {
    super.initState();

    if (postModel != null) {
    } else {
      postModel = PostModel();
    }
  }

  @override
  Widget build(BuildContext context) {
    this.context = context;
    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        title: Text("Publicar anuncio"),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(8),
          child: Column(
            children: [
              TextField(
                controller: titleEditingController,
                textInputAction: TextInputAction.next,
                minLines: 2,
                maxLines: 100,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                    labelText: "Titulo",
                    counterText: "",
                    hintText: "Tarea...",
                    border: OutlineInputBorder()),
              ),
              defalutSizedBox,
              TextField(
                controller: messageEditingController,
                textInputAction: TextInputAction.next,
                minLines: 5,
                maxLines: 100,
                textAlign: TextAlign.start,
                onEditingComplete: () => FocusScope.of(context).nextFocus(),
                decoration: InputDecoration(
                    labelText: "Descripcion",
                    counterText: "",
                    hintText: "El niño debe...",
                    border: OutlineInputBorder()),
              ),
              defalutSizedBox,
              isLoading
                  ? MyCircleLoading()
                  : Container(
                      width: double.infinity,
                      child: RaisedButton(
                        color: Colors.lightBlue,
                        shape: StadiumBorder(),
                        onPressed: () {
                          var timeStamp =
                              FieldValue.serverTimestamp().toString();
                          print("timeStamp: $timeStamp");
                          validateMobileNumber();
                        },
                        child: Text(
                          "Publicar",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  void validateMobileNumber() async {
    FocusScope.of(context).unfocus();
    if (titleEditingController.text == null ||
        titleEditingController.text.length == 0) {
      Fluttertoast.showToast(msg: "Enter title");
      return;
    }
    if (messageEditingController.text == null ||
        messageEditingController.text.length == 0) {
      Fluttertoast.showToast(msg: "Enter description");
      return;
    }
    post();
  }

  void post() async {
    setState(() {
      isLoading = true;
    });
    try {
      postModel.title = titleEditingController.text;
      postModel.message = messageEditingController.text;
      int id = 0;
      DocumentReference countDocumentReference = FirebaseFirestore.instance
          .collection(Constants.statues)
          .doc(Constants.count);
      await FirebaseUtils.postNotification(postModel, _imagePath);
      //notificationModel.docId = postDocumentReference.documentID;
      //await postDocumentReference.setData(notificationModel.toMap());
      if (id == 0) {
        await countDocumentReference.set({"id": id});
      } else {
        await countDocumentReference.update({"id": id});
      }
      Fluttertoast.showToast(msg: "Se ha publicado el aviso.");
      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: "Error al publicar el aviso.");
    }
    setState(() {
      isLoading = false;
    });
  }

  pickImagesFromGallery(ImageSource source) {
    setState(() {
      ImagePicker.pickImage(source: source).then((onValue) {
        setState(() {
          _imagePath = onValue.path;
          print("_imagePath : " + _imagePath);
        });
      });
    });
  }

  showImage() {
    print("showImage : " + postModel.imageURL.toString());

    if (imageFile != null) {
      return FutureBuilder<File>(
          future: imageFile,
          builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.data != null) {
              return Image.file(snapshot.data, width: 250, height: 250);
            } else if (snapshot.error != null) {
              print("snapshot.error : ${snapshot.error} ");
              return Text("Error Picking Image", textAlign: TextAlign.center);
            } else {
              return Text("No Image Selected", textAlign: TextAlign.center);
            }
          });
    } else {
      if (postModel != null && postModel.imageURL != null) {
        return Image.network(postModel.imageURL, width: 250, height: 250);
      } else
        return Text("No Image Selected", textAlign: TextAlign.center);
    }
  }
}
