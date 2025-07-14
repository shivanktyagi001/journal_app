
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalModel{
  String id;
  String title;
  String des;
  DateTime datetime;
  String tag;
  String mood;
  JournalModel({
    required this.id,
     required this.title,
    required this.des,
    required this.datetime,
    required this.mood,
    required this.tag,
});
  Map<String,dynamic> tomap(){
    return {
       'id':id,
      'title':title,
      'des':des,
      'datetime':datetime,
      'tag':tag,
      'mood':mood,
    };
  }
  factory JournalModel.frommap(Map<String, dynamic> mp) {
    return JournalModel(
      id: mp['id'] ?? '',
      title: mp['title'] ?? '',
      des: mp['des'] ?? '',
      datetime: (mp['datetime'] as Timestamp).toDate(), // ✅ convert Timestamp to DateTime
      mood: mp['mood'] ?? '',
      tag: mp['tag'] ?? '',
    );
  }
}