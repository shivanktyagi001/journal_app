import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:journal_app/Models/journal_model.dart';
import 'package:journal_app/provider/journal_provider.dart';
import 'package:journal_app/provider/myauth_provider.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<MyAuthProvider>(context);
    final uid = authProvider.user;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text("My Journal"),
        centerTitle: true,
        backgroundColor:Colors.teal,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: uid == null
          ? Center(child: CircularProgressIndicator())
          : FutureBuilder(
        future: Provider.of<JournalProvider>(context, listen: false).fetchJournal(uid),
        builder: (context, snapshot) {
          return Consumer<JournalProvider>(
            builder: (context, journalmodel, _) {
              final journal = journalmodel.journal;
              if (journal.isEmpty) {
                return Center(child: Text("No Journal Entries Yet"));
              }
              return ListView.builder(
                itemCount: journal.length,
                padding: const EdgeInsets.all(16),
                itemBuilder: (context, index) {
                  final ju = journal[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 6,
                    margin: EdgeInsets.only(bottom: 16),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(16),
                      title: Text(
                        ju.title,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 8),
                          Text(ju.des, style: TextStyle(fontSize: 15)),
                          SizedBox(height: 8),
                          Row(
                            children: [
                              Chip(label: Text(ju.tag)),
                              SizedBox(width: 8),
                              Chip(label: Text(ju.mood)),
                            ],
                          ),
                          SizedBox(height: 6),
                          Text(DateFormat.yMMMEd().format(ju.datetime)),
                        ],
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            _showAddOrEditBottomSheet(context, journalmodel, uid, existing: ju);
                          } else if (value == 'delete') {
                            journalmodel.deleteJournal(uid, ju.id!);
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(value: 'edit', child: Text('Edit')),
                          PopupMenuItem(value: 'delete', child: Text('Delete')),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingActionButton(
        onPressed: () {
          _showAddOrEditBottomSheet(context, Provider.of<JournalProvider>(context, listen: false), uid);
        },
        backgroundColor:Colors.teal,
        child: Icon(Icons.add),
      ),
    );
  }

  void _showAddOrEditBottomSheet(
      BuildContext context,
      JournalProvider provider,
      String uid, {
        JournalModel? existing,
      }) {
    final titleController = TextEditingController(text: existing?.title ?? "");
    final desController = TextEditingController(text: existing?.des ?? "");
    final tagController = TextEditingController(text: existing?.tag ?? "");
    final moodController = TextEditingController(text: existing?.mood ?? "");

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existing == null ? "Add Journal" : "Update Journal",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: InputDecoration(labelText: "Title", border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextField(
                controller: desController,
                decoration: InputDecoration(labelText: "Description", border: OutlineInputBorder()),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextField(
                controller: tagController,
                decoration: InputDecoration(labelText: "Tag", border: OutlineInputBorder()),
              ),
              SizedBox(height: 12),
              TextField(
                controller: moodController,
                decoration: InputDecoration(labelText: "Mood", border: OutlineInputBorder()),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                ),
                onPressed: () {
                  final title = titleController.text.trim();
                  final des = desController.text.trim();
                  final tag = tagController.text.trim();
                  final mood = moodController.text.trim();

                  if (title.isEmpty || des.isEmpty || tag.isEmpty || mood.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please fill all fields")),
                    );
                    return;
                  }

                  final newEntry = JournalModel(
                    id: existing?.id ?? "",
                    title: title,
                    des: des,
                    datetime: DateTime.now(),
                    mood: mood,
                    tag: tag,
                  );

                  if (existing == null) {
                    provider.addJournal(newEntry, uid);
                  } else {
                    provider.updateJournal(uid, existing.id!, newEntry);
                  }

                  Navigator.pop(context);
                },
                child: Text(existing == null ? "Add" : "Update"),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
