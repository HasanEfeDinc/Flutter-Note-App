import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/note_model.dart';

class RemoteDataSource {
  final Dio _dio;
  final String baseUrl;
  RemoteDataSource(this._dio, {required this.baseUrl});

  Future<List<NoteModel>> fetchNotes() async {
    final res = await _dio.get('$baseUrl/notes', options: await _auth());
    final data = (res.data as List).cast<Map<String, dynamic>>();
    return data.map(_fromJson).toList();
  }

  Future<void> create(NoteModel n) async {
    await _dio.post('$baseUrl/notes',
      data: {
        'id': n.id,
        'title': n.title,
        'content': n.preview,
        'pinned': n.pinned,
        'pinnedAt': n.pinnedAt?.toIso8601String(),
        'createdAt': n.createdAt.toIso8601String(),
      },
      options: await _auth(),
    );
  }

  Future<void> update(NoteModel n) async {
    await _dio.put('$baseUrl/notes/${n.id}',
      data: {
        'title': n.title,
        'content': n.preview,
        'pinned': n.pinned,
        'pinnedAt': n.pinnedAt?.toIso8601String(),
      },
      options: await _auth(),
    );
  }

  Future<void> delete(String id) async {
    await _dio.delete('$baseUrl/notes/$id', options: await _auth());
  }

  Future<Options> _auth() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  NoteModel _fromJson(Map<String, dynamic> j) {
    return NoteModel(
      id: j['id'] as String,
      title: j['title'] as String? ?? 'New Note',
      preview: j['content'] as String? ?? 'No additional text',
      createdAt: DateTime.parse(j['createdAt'] as String),
      pinned: j['pinned'] as bool? ?? false,
      pinnedAt: j['pinnedAt'] != null ? DateTime.parse(j['pinnedAt']) : null,
    );
  }
}
