import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guard_app/presentation/screens/guard_home_screen.dart';

class ProfileSetupScreen extends StatelessWidget {
  ProfileSetupScreen({super.key});

  final TextEditingController nameController = TextEditingController();

  void saveProfile(BuildContext context) async {
    try {
      print("SAVE BUTTON CLICKED");

      // 🔹 Get current user
      final uid = FirebaseAuth.instance.currentUser?.uid;

      print("UID = $uid");

      if (uid == null) {
        print("USER NOT LOGGED IN");
        return;
      }

      // 🔹 Save guard profile in Firestore
      await FirebaseFirestore.instance.collection("guards").doc(uid).set({
        "uid": uid,
        "name": nameController.text.trim(),
        "isOnline": false,
      });

      print("FIRESTORE SAVE SUCCESS");

      // 🔹 Navigate to Guard Home
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GuardHomeScreen()),
      );
    } catch (e) {
      print("FIRESTORE ERROR: $e");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Setup Profile")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Name"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => saveProfile(context),
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }
}
