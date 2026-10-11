import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_task_manager/others/app_startup.dart';
import 'package:firebase_task_manager/screens/tasks/task_list_screen.dart';
import 'package:firebase_task_manager/screens/user/login_screen.dart';
import 'package:firebase_task_manager/service/auth_service.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppStartup.firebaseReady) {
      return Scaffold(body: Text("Error"));
    }

    return StreamBuilder(
      stream: AuthService.authChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final User? user = snapshot.data;

        if (user == null) {
          return LoginScreen();
        }

        //return ProfileScreen(user: user);
        return TaskListScreen();
      },
    );
  }
}
