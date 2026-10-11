import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_task_manager/others/app_navigator.dart';
import 'package:firebase_task_manager/others/app_startup.dart';
import 'package:firebase_task_manager/others/firebase_options.dart';
import 'package:firebase_task_manager/screens/splash_screen.dart';
import 'package:firebase_task_manager/service/notification_service.dart';
import 'package:firebase_task_manager/service/push_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    AppStartup.firebaseReady = true;
  } catch (e) {
    AppStartup.firebaseError = e.toString();
  }

  await NotificationService.init();

  if (AppStartup.firebaseReady) {
    await PushService.init();
    try {
      await GoogleSignIn.instance.initialize();
    } catch (e) {
      debugPrint('Google Sign In not configured $e');
    }
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
      home: const SplashScreen(),
      navigatorKey: AppNavigator.key,
    );
  }
}
