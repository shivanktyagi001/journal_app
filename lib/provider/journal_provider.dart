import 'package:flutter/material.dart';
import 'package:journal_app/Models/journal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JournalProvider extends ChangeNotifier {
  final _ju = FirebaseFirestore.instance;

  List<JournalModel> _journal = [];
  List<JournalModel> get journal => _journal;

  /// ✅ Add Journal Entry
  Future<void> addJournal(JournalModel journal, String uid) async {
    final docf = await _ju
        .collection("users")
        .doc(uid)
        .collection("journal")
        .add(journal.tomap());

    await docf.update({'id': docf.id});

    _journal.add(JournalModel(
      id: docf.id,
      title: journal.title,
      des: journal.des,
      datetime: journal.datetime,
      mood: journal.mood,
      tag: journal.tag,
    ));

    notifyListeners();
  }

  /// ✅ Fetch All Journals
  Future<void> fetchJournal(String uid) async {
    final snap =
    await _ju.collection("users").doc(uid).collection('journal').get();

    _journal = snap.docs
        .map((doc) => JournalModel.frommap(doc.data()))
        .toList();

    notifyListeners();
  }

  /// ✅ Update a Journal Entry
  Future<void> updateJournal(
      String uid, String journalId, JournalModel updatedJournal) async {
    await _ju
        .collection("users")
        .doc(uid)
        .collection("journal")
        .doc(journalId)
        .update(updatedJournal.tomap());

    final index = _journal.indexWhere((j) => j.id == journalId);
    if (index != -1) {
      _journal[index] = updatedJournal;
      notifyListeners();
    }
  }

  /// ✅ Delete a Journal Entry
  Future<void> deleteJournal(String uid, String journalId) async {
    await _ju
        .collection("users")
        .doc(uid)
        .collection("journal")
        .doc(journalId)
        .delete();

    _journal.removeWhere((j) => j.id == journalId);
    notifyListeners();
  }
}
