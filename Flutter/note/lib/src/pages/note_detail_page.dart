import 'package:flutter/material.dart';

class NoteDetailResult {
  final String title;
  final String content;
  final bool deleted;
  const NoteDetailResult({
    required this.title,
    required this.content,
    this.deleted = false,
  });
}

class NoteDetailPage extends StatefulWidget {
  final String initialTitle;
  final String initialContent;

  const NoteDetailPage({
    super.key,
    required this.initialTitle,
    required this.initialContent,
  });

  @override
  State<NoteDetailPage> createState() => _NoteDetailPageState();
}

class _NoteDetailPageState extends State<NoteDetailPage> {
  late final TextEditingController _titleCtrl =
  TextEditingController(text: widget.initialTitle);
  late final TextEditingController _contentCtrl =
  TextEditingController(text: widget.initialContent);

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleCtrl.text.trim().isEmpty ? 'New Note' : _titleCtrl.text.trim();
    Navigator.pop(
      context,
      NoteDetailResult(title: title, content: _contentCtrl.text.trim()),
    );
  }

  void _delete() {
    Navigator.pop(
      context,
      const NoteDetailResult(title: '', content: '', deleted: true),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: TextField(
                      controller: _titleCtrl,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),


              Expanded(
                child: TextField(
                  controller: _contentCtrl,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade400),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: _save,
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _delete,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        side: BorderSide(color: Colors.red.shade400),
                        foregroundColor: Colors.red.shade400,
                      ),
                      child: const Text('Delete'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
