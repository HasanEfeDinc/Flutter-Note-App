import 'package:hive/hive.dart';
import '../models/note_model.dart';

class LocalDataSource {
  final Box _notes = Hive.box('notes_box');
  final Box _pending = Hive.box('pending_box');

  List<NoteModel> getNotes() {
    final raw = (_notes.get('items') as List?)?.cast<Map>() ?? const [];
    return raw.map((e) => _fromMap(Map<String, dynamic>.from(e))).toList();
  }

  Future<void> saveNotes(List<NoteModel> notes) async {
    await _notes.put('items', notes.map(_toMap).toList());
  }

  Future<void> upsert(NoteModel n) async {
    final list = getNotes();
    final i = list.indexWhere((x) => x.id == n.id);
    if (i >= 0) list[i] = n; else list.add(n);
    await saveNotes(list);
  }

  Future<void> remove(String id) async {
    final list = getNotes()..removeWhere((x) => x.id == id);
    await saveNotes(list);
  }

  List<Map<String, dynamic>> getPending() {
    final raw = (_pending.get('ops') as List?)?.cast<Map>() ?? const [];
    return raw.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<void> addPending(Map<String, dynamic> op) async {
    final ops = getPending()..add(op);
    await _pending.put('ops', ops);
  }

  Future<void> overwritePending(List<Map<String, dynamic>> ops) async {
    await _pending.put('ops', ops);
  }

  Map<String, dynamic> _toMap(NoteModel n) => {
    'id': n.id,
    'title': n.title,
    'preview': n.preview,
    'createdAt': n.createdAt.toIso8601String(),
    'pinned': n.pinned,
    'pinnedAt': n.pinnedAt?.toIso8601String(),
  };

  NoteModel _fromMap(Map<String, dynamic> m) => NoteModel(
    id: m['id'] as String,
    title: m['title'] as String,
    preview: m['preview'] as String,
    createdAt: DateTime.parse(m['createdAt'] as String),
    pinned: (m['pinned'] as bool?) ?? false,
    pinnedAt: (m['pinnedAt'] != null) ? DateTime.parse(m['pinnedAt']) : null,
  );
}
