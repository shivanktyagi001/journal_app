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
        title: const Text("My Journal"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authProvider.logout();
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          )
        ],
      ),
      body: uid == null
          ? const Center(child: CircularProgressIndicator())
          : StreamBuilder<List<JournalModel>>(
        stream: Provider.of<JournalProvider>(context, listen: false).journalStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No Journal Entries Yet"));
          }

          final journal = snapshot.data!;
          return ListView.builder(
            itemCount: journal.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final ju = journal[index];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 6,
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    ju.title,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Text(ju.des, style: const TextStyle(fontSize: 15)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Chip(label: Text(ju.tag)),
                          const SizedBox(width: 8),
                          Chip(label: Text(ju.mood)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(DateFormat.yMMMEd().format(ju.datetime)),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      final provider = Provider.of<JournalProvider>(context, listen: false);
                      if (value == 'edit') {
                        _showAddOrEditBottomSheet(context, provider, uid, existing: ju);
                      } else if (value == 'delete') {
                        provider.deleteJournal(uid, ju.id!);
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      const PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: uid == null
          ? null
          : FloatingActionButton(
        onPressed: () {
          _showAddOrEditBottomSheet(
            context,
            Provider.of<JournalProvider>(context, listen: false),
            uid,
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                existing == null ? "Add Journal" : "Update Journal",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: "Title",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: desController,
                decoration: const InputDecoration(
                  labelText: "Description",
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 12),
              TextField(
                controller: tagController,
                decoration:  InputDecoration(
                  labelText: "Tag",
                  border: OutlineInputBorder(),
                ),
              ),
               SizedBox(height: 12),
              TextField(
                controller: moodController,
                decoration:  InputDecoration(
                  labelText: "Mood",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding:  EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
