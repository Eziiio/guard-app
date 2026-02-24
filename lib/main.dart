import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'presentation/screens/login_screen.dart';
import 'presentation/screens/guard_home_screen.dart';
import 'background_service.dart';

Future<void> saveFcmToken() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return;

  final token = await FirebaseMessaging.instance.getToken();

  await FirebaseFirestore.instance.collection("guards").doc(user.uid).update({
    "fcmToken": token,
  });
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await initializeService();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      saveFcmToken();
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: user == null ? LoginScreen() : const GuardHomeScreen(),
    );
  }
}
