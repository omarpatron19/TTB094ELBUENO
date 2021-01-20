import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  String docid;
  String imageURL;
  String message;
  String title;
  Timestamp timestamp;
  PostModel(
      {this.docid, this.imageURL, this.message, this.title, this.timestamp});
  factory PostModel.fromJSON(Map<String, dynamic> json) {
    return PostModel(
        docid: json["docid"],
        imageURL: json["imageURL"],
        message: json["message"],
        title: json["title"],
        timestamp: json["timestamp"]);
  }
  toMap() {
    Map<String, dynamic> map = Map();
    map['docid'] = docid;
    map['imageURL'] = imageURL;
    map['message'] = message;
    map['title'] = title;
    map["timestamp"] = FieldValue.serverTimestamp();
    return map;
  }
}
