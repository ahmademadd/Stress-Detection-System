import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';
import 'admin_home.dart';
import 'user_home.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // user is logged in -> fetch role and route
        return FutureBuilder<Map<String, dynamic>?>(
          future: auth.fetchUserDoc(),
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Scaffold(body: Center(child: CircularProgressIndicator()));
            }
            final userDoc = snap.data;
            if (userDoc == null) {
              // no user doc — fallback to login
              return const LoginScreen();
            }

            final role = (userDoc['role'] ?? 'user') as String;

            if (role == 'admin') {
              return const AdminHome();
            } else {
              return const UserHome();
            }
          },
        );
      },
    );
  }
}
