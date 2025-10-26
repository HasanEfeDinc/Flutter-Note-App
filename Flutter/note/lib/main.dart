import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'firebase_options.dart';

import 'src/data/local_data_source.dart';
import 'src/data/remote_data_source.dart';
import 'src/data/notes_repository_impl.dart';
import 'src/blocs/notes_cubit.dart';
import 'src/pages/auth_gate.dart';

String resolveBaseUrl() {
  if (kIsWeb) return 'http://localhost:8000';
  if (Platform.isAndroid) return 'http://10.0.2.2:8000';
  return 'http://127.0.0.1:8000';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await Hive.initFlutter();
  await Hive.openBox('notes_box');
  await Hive.openBox('pending_box');

  final dio = Dio();
  final local = LocalDataSource();
  final remote = RemoteDataSource(dio, baseUrl: resolveBaseUrl());
  final repo = NotesRepository(
    local: local,
    remote: remote,
    connectivity: Connectivity(),
  );

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => NotesCubit(repo)..load()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Note',
      theme: ThemeData(useMaterial3: true),
      home: const AuthGate(),
    );
  }
}
