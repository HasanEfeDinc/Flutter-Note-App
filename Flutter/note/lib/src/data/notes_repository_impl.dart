import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/note_model.dart';
import 'local_data_source.dart';
import 'remote_data_source.dart';

class NotesRepository {
  final LocalDataSource local;
  final RemoteDataSource remote;
  final Connectivity connectivity;

  NotesRepository({required this.local, required this.remote, required this.connectivity});

  Future<List<NoteModel>> load() async {
    return local.getNotes();
  }

  Future<void> create(NoteModel n) async {
    await local.upsert(n);
    await local.addPending({'op': 'create', 'note': _toMap(n)});
    await _trySync();
  }

  Future<void> update(NoteModel n) async {
    await local.upsert(n);
    await local.addPending({'op': 'update', 'note': _toMap(n)});
    await _trySync();
  }

  Future<void> delete(String id) async {
    final list = local.getNotes();
    final found = list.firstWhere((x) => x.id == id, orElse: () => throw 'not found');
    await local.remove(id);
    await local.addPending({'op': 'delete', 'note': _toMap(found)});
    await _trySync();
  }

  Future<void> fullRefreshFromRemote() async {
    final online = await _isOnline();
    if (!online) return;
    final remoteList = await remote.fetchNotes();
    await local.saveNotes(remoteList);
  }

  Future<void> _trySync() async {
    if (!await _isOnline()) return;
    final ops = local.getPending();
    if (ops.isEmpty) return;

    final remaining = <Map<String, dynamic>>[];
    for (final op in ops) {
      try {
        final note = _fromMap(op['note'] as Map<String, dynamic>);
        switch (op['op']) {
          case 'create': await remote.create(note); break;
          case 'update': await remote.update(note); break;
          case 'delete': await remote.delete(note.id); break;
        }
      } catch (_) {
        remaining.add(op);
      }
    }
    await local.overwritePending(remaining);
    if (remaining.isEmpty) await fullRefreshFromRemote();
  }

  Future<bool> _isOnline() async {
    final res = await connectivity.checkConnectivity();
    return res.contains(ConnectivityResult.mobile) || res.contains(ConnectivityResult.wifi);
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
    createdAt: DateTime.parse(m['createdAt']),
    pinned: m['pinned'] as bool? ?? false,
    pinnedAt: m['pinnedAt'] != null ? DateTime.parse(m['pinnedAt']) : null,
  );
}
