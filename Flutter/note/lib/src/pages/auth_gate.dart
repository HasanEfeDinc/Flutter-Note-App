import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'notes_page.dart';
import 'login_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (_, s) {
        if (s.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        return s.data == null ? const LoginPage() : const NotesPage();
      },
    );
  }
}
