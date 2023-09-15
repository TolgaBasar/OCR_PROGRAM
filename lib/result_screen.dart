import 'dart:io';
import 'package:flutter/material.dart';

class ResultScreen extends StatefulWidget {
  final String imagePath;
  final String extractedText;

  const ResultScreen({
    Key? key,
    required this.imagePath,
    required this.extractedText,
  }) : super(key: key);

  @override
  _ResultScreenState createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final TextEditingController _editingController = TextEditingController();
  late List<String> _words;
  late List<String> _originalWords; // Orjinal metin listesi

  @override
  void initState() {
    super.initState();
    _words = widget.extractedText.split('\n');
    _originalWords = List.from(_words);
  }

  void _openEditDialog(int index) {
    _editingController.text = _words[index];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Word"),
          content: TextField(
            controller: _editingController,
            decoration: const InputDecoration(hintText: "Enter new word"),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _words[index] = _editingController.text;
                  _editingController.clear();
                  Navigator.of(context).pop();
                });
              },
              child: const Text("Save"),
            ),
            ElevatedButton(
              onPressed: () {
                _editingController.clear();
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _words.removeAt(index);
                  Navigator.of(context).pop();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: const Icon(Icons.delete),
            ),
          ],
        );
      },
    );
  }

  void _undoChanges() {
    setState(() {
      _words = List.from(_originalWords);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Result'),
        backgroundColor: Colors.blueAccent,
        actions: [
          IconButton(
            onPressed: _undoChanges,
            icon: const Icon(Icons.undo),
          ),
        ],
      ),
      body: _buildContent(),
    );
  }
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImage(),
            const SizedBox(height: 20),
            _buildWordList(),
          ],
        ),
      ),
    );
  }
  Widget _buildImage() {
    return ClipRect(
      child: SizedBox(
        width: double.infinity,
        height: 300,
        child: Image.file(File(widget.imagePath)),
      ),
    );
  }
  Widget _buildWordList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _words.asMap().entries.map(
            (entry) {
          final int index = entry.key;
          final String word = entry.value;

          if (word.isNotEmpty) {
            return GestureDetector(
              onTap: () {
                _openEditDialog(index);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 1.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  word,
                ),
              ),
            );
          } else {
            return Container();
          }
        },
      ).toList(),
    );
  }
}
