import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/note_item.dart';
import '../pages/note_detail_page.dart';
import '../blocs/notes_cubit.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({super.key});
  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  final _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      context.read<NotesCubit>().setQuery(text);
    });
  }

  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Logout failed: $e')));
      }
    }
  }

  Future<void> _showCreateDialog() async {
    final ctrl = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Create note'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(labelText: 'Title', hintText: 'Enter a title'),
          onSubmitted: (_) => Navigator.of(ctx).pop(ctrl.text.trim()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(ctx).pop(ctrl.text.trim()), child: const Text('Create')),
        ],
      ),
    );
    if (!mounted) return;
    context.read<NotesCubit>().create(title?.trim() ?? '');
  }

  String _firstLine(String text, {int maxLength = 40}) {
    if (text.isEmpty) return 'No additional text';
    final first = text.split('\n').first.trim();
    return first.length <= maxLength ? first : '${first.substring(0, maxLength)}...';
  }

  void _showUndoSnack() {
    final cubit = context.read<NotesCubit>();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Note Deleted'),
          action: SnackBarAction(label: 'UNDO', onPressed: cubit.undoDelete),
          duration: const Duration(seconds: 6),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Notes', style: TextStyle(fontWeight: FontWeight.w600)),
        actions: [
          Tooltip(
            message: 'Logout (${user?.email ?? 'user'})',
            child: IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade300, height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: _onSearchChanged,
                      textInputAction: TextInputAction.search,
                      decoration: const InputDecoration(
                        hintText: 'Search notes…',
                        prefixIcon: Icon(Icons.search),
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showCreateDialog,
                  borderRadius: BorderRadius.circular(50),
                  child: Container(
                    decoration: const BoxDecoration(color: Color(0xFF1976D2), shape: BoxShape.circle),
                    padding: const EdgeInsets.all(12),
                    child: const Icon(Icons.add, color: Colors.white, size: 28),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<NotesCubit, NotesState>(
              builder: (context, state) {
                final items = state.visibleNotes;
                if (state.loading && items.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (items.isEmpty) return const Center(child: Text('No notes yet'));
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: items.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (ctx, i) {
                    final n = items[i];
                    return NoteItem(
                      note: n,
                      onTap: () async {
                        final res = await Navigator.push<NoteDetailResult>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailPage(
                              initialTitle: n.title,
                              initialContent: n.preview == 'No additional text' ? '' : n.preview,
                            ),
                          ),
                        );
                        if (res == null) return;
                        if (res.deleted) {
                          context.read<NotesCubit>().delete(n.id);
                          _showUndoSnack();
                        } else {
                          context.read<NotesCubit>().update(
                            n.id,
                            title: res.title,
                            preview: _firstLine(res.content),
                          );
                        }
                      },
                      onPinToggle: () => context.read<NotesCubit>().togglePin(n.id),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
