import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:guard_app/logic/guard_status/guard_status_bloc.dart';
import 'package:guard_app/logic/guard_status/guard_status_event.dart';
import 'package:guard_app/logic/guard_status/guard_status_state.dart';

import 'package:guard_app/presentation/screens/guard_request_screen.dart';
import 'package:guard_app/presentation/screens/login_screen.dart';

class GuardHomeScreen extends StatelessWidget {
  const GuardHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      // Load status when screen opens
      create: (_) => GuardStatusBloc()..add(LoadGuardStatus()),

      child: Scaffold(
        appBar: AppBar(
          title: const Text("Guard Home"),

          /// 🔴 LOGOUT BUTTON
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),

        body: Center(
          child: BlocBuilder<GuardStatusBloc, GuardStatusState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  /// ONLINE / OFFLINE SWITCH
                  SwitchListTile(
                    title: const Text("Go Online"),
                    value: state.isOnline,
                    onChanged: (value) {
                      context.read<GuardStatusBloc>().add(
                        ToggleGuardStatus(value),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  /// REQUEST BUTTON (ONLY ONLINE)
                  if (state.isOnline)
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const GuardRequestScreen(),
                          ),
                        );
                      },
                      child: const Text("View Requests"),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
