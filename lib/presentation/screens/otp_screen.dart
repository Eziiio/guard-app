import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:guard_app/presentation/screens/guard_home_screen.dart';
import 'profile_setup_screen.dart';

class OtpScreen extends StatelessWidget {
  final String verificationId;

  OtpScreen({super.key, required this.verificationId});

  final TextEditingController otpController = TextEditingController();

  void verifyOTP(BuildContext context) async {
    try {
      // 🔹 Create credential from OTP
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpController.text.trim(),
      );

      // 🔹 Sign in user
      await FirebaseAuth.instance.signInWithCredential(credential);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Login Success")));

      // 🔹 Get current user UID
      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 🔹 Check if guard profile exists
      final doc = await FirebaseFirestore.instance
          .collection("guards")
          .doc(uid)
          .get();

      if (doc.exists) {
        // ✅ Profile exists → go Home
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GuardHomeScreen()),
        );
      } else {
        // 🟢 First login → setup profile
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileSetupScreen()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid OTP")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => verifyOTP(context),
              child: const Text("Verify"),
            ),
          ],
        ),
      ),
    );
  }
}
