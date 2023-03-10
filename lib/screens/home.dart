import 'package:flutter/material.dart';

import 'package:tito_flutter_sqflite/database/sql_helper.dart';
import 'package:tito_flutter_sqflite/widgets/card.dart';

import '../models/note.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  List<Map<String, dynamic>> _journals = [];

  bool _isloading = true;

  void _refreshJournals() async {
    final data = await SQLHelper.getNotes();
    setState(() {
      _journals = data;
      _isloading = false;
    });
  }

  Future<void> _addItem() async {
    await SQLHelper.createnote(_titleController.text, _bodyController.text);
    _refreshJournals();
  }

  Future<void> _updateItem(int id) async {
    await SQLHelper.updateNote(id, _titleController.text, _bodyController.text);
    _refreshJournals();
  }

  void _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          'Successfully \n deleted a Journal',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
    _refreshJournals();
  }

  void _showForm(int? id) async {
    if (id != null) {
      final existingJournal =
          _journals.firstWhere((element) => element['noteid'] == id);
      _titleController.text = existingJournal['title'];
      _bodyController.text = existingJournal['body'];
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(
            top: 15,
            left: 15,
            right:
                15, //this will prevent the soft keyboard from covering text fields
            bottom: MediaQuery.of(context).viewInsets.bottom + 120),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(hintText: 'Title'),
            ),
            const SizedBox(
              height: 15,
            ),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(hintText: 'Details'),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  if (id == null) {
                    await _addItem();
                  }
                  if (id != null) {
                    await _updateItem(id);
                  }

                  //clear textfields
                  _titleController.clear();
                  _bodyController.clear();

                  //close bottom sheet
                  Navigator.canPop(context) ? Navigator.pop(context) : null;
                },
                child: Text(id == null ? 'Create New' : 'Update'))
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _refreshJournals();
    print('..... number of items ${_journals.length} ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SQL'),
      ),
      body: sampleFromDb(),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showForm(null),
          label: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(Icons.add),
              const Text("Add Note"),
            ],
          )),
    );
  }

  Widget sampleFromDb() {
    return ListView.builder(
        itemCount: _journals.length,
        itemBuilder: (BuildContext context, index) {
          return Card(
            color: Colors.blue,
            margin: const EdgeInsets.all(15),
            child: ListTile(
              title: Text(
                _journals[index]['title'],
                style: TextStyle(color: Colors.white),
              ),
              subtitle: Text(_journals[index]['body'],
                  style: TextStyle(color: Colors.white)),
              trailing: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => _showForm(_journals[index]['noteid']),
                        icon: const Icon(Icons.edit),
                        color: Colors.white,
                      ),
                      IconButton(
                        onPressed: () =>
                            _deleteItem(_journals[index]['noteid']),
                        icon: const Icon(Icons.delete),
                        color: Colors.white,
                      )
                    ],
                  )),
            ),
          );
        });
  }

  Widget sampleFromModel() {
    return ListView.builder(
        itemCount: notes.length,
        itemBuilder: (BuildContext context, index) {
          return NoteCard(Note: notes[index]);
        });
  }

  
}
