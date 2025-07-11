
class JournalModel{
  String title;
  String des;
  DateTime datetime;
  String tag;
  String mood;
  JournalModel({
     required this.title,
    required this.des,
    required this.datetime,
    required this.mood,
    required this.tag,
});
  Map<String,dynamic> tomap(){
    return {
      'title':title,
      'des':des,
      'datetime':datetime,
      'tag':tag,
      'mood':mood,
    };
  }
  factory JournalModel.frommap(Map<String,dynamic>mp){
    return JournalModel(title:mp['title'] ,
        des: mp['des'], datetime: mp['datetime'], mood: mp['mood'], tag: mp['tag']);
  }
}