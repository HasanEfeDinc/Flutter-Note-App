import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/note_model.dart';
import '../data/notes_repository_impl.dart';

class NotesState {
  final List<NoteModel> notes;
  final String query;
  final NoteModel? lastDeleted;
  final bool loading;
  final String? error;

  const NotesState({
    this.notes = const [],
    this.query = '',
    this.lastDeleted,
    this.loading = false,
    this.error,
  });

  List<NoteModel> get visibleNotes {
    Iterable<NoteModel> src = notes;

    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      src = src.where((n) {
        final inTitle = n.title.toLowerCase().contains(q);
        final inContent = n.preview.toLowerCase().contains(q);
        return inTitle || inContent;
      });
    }

    final list = src.toList();
    list.sort((a, b) {
      if (a.pinned != b.pinned) return a.pinned ? -1 : 1;
      if (a.pinned && b.pinned) {
        final at = a.pinnedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bt = b.pinnedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bt.compareTo(at);
      }
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  NotesState copyWith({
    List<NoteModel>? notes,
    String? query,
    NoteModel? lastDeleted,
    bool? loading,
    String? error,
    bool clearLastDeleted = false,
    bool clearError = false,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      query: query ?? this.query,
      lastDeleted: clearLastDeleted ? null : (lastDeleted ?? this.lastDeleted),
      loading: loading ?? this.loading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class NotesCubit extends Cubit<NotesState> {
  final NotesRepository repo;
  NotesCubit(this.repo) : super(const NotesState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final cached = await repo.load();
      emit(state.copyWith(notes: cached, loading: false));

      await repo.fullRefreshFromRemote();
      final refreshed = await repo.load();
      emit(state.copyWith(notes: refreshed));
    } catch (e) {
      emit(state.copyWith(loading: false, error: '$e'));
    }
  }

  void setQuery(String q) => emit(state.copyWith(query: q));

  Future<void> create(String title) async {
    final n = NoteModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: (title.isEmpty) ? 'New Note' : title,
      preview: 'No additional text',
      createdAt: DateTime.now(),
    );

    final next = List<NoteModel>.from(state.notes)..add(n);
    emit(state.copyWith(notes: next, clearLastDeleted: true));

    await repo.create(n);
    emit(state.copyWith(notes: await repo.load()));
  }

  Future<void> update(String id, {String? title, String? preview}) async {
    final list = state.notes
        .map((n) => n.id == id
        ? n.copyWith(title: title ?? n.title, preview: preview ?? n.preview)
        : n)
        .toList();
    emit(state.copyWith(notes: list));

    final changed = list.firstWhere((x) => x.id == id);
    await repo.update(changed);
    emit(state.copyWith(notes: await repo.load()));
  }

  Future<void> togglePin(String id) async {
    final now = DateTime.now();
    final list = state.notes
        .map((n) => n.id == id
        ? n.copyWith(pinned: !n.pinned, pinnedAt: n.pinned ? null : now)
        : n)
        .toList();
    emit(state.copyWith(notes: list));

    await repo.update(list.firstWhere((x) => x.id == id));
    emit(state.copyWith(notes: await repo.load()));
  }

  Future<void> delete(String id) async {
    final n = state.notes.firstWhere((x) => x.id == id);
    final list = List<NoteModel>.from(state.notes)..removeWhere((x) => x.id == id);
    emit(state.copyWith(notes: list, lastDeleted: n));

    await repo.delete(id);
    emit(state.copyWith(notes: await repo.load()));
  }

  Future<void> undoDelete() async {
    final n = state.lastDeleted;
    if (n == null) return;

    final list = List<NoteModel>.from(state.notes)..add(n);
    emit(state.copyWith(notes: list, clearLastDeleted: true));

    await repo.create(n);
    emit(state.copyWith(notes: await repo.load()));
  }
}
