import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

import 'guard_status_event.dart';
import 'guard_status_state.dart';

class GuardStatusBloc extends Bloc<GuardStatusEvent, GuardStatusState> {
  GuardStatusBloc() : super(GuardStatusState(isOnline: false)) {
    /// LOAD CURRENT STATUS
    on<LoadGuardStatus>((event, emit) async {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      final doc = await FirebaseFirestore.instance
          .collection("guards")
          .doc(uid)
          .get();

      if (doc.exists) {
        final online = doc["isOnline"] ?? false;

        // Start background service ONLY if online

        emit(GuardStatusState(isOnline: online));
      }
    });

    /// TOGGLE ONLINE/OFFLINE
    on<ToggleGuardStatus>((event, emit) async {
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await FirebaseFirestore.instance.collection("guards").doc(uid).update({
        "isOnline": event.isOnline,
      });
      if (event.isOnline) {
        LocationPermission permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          return;
        }

        final service = FlutterBackgroundService();

        bool isRunning = await service.isRunning();

        if (!isRunning) {
          service.startService();
        }
      } else {
        FlutterBackgroundService().invoke("stopService");
      }

      emit(GuardStatusState(isOnline: event.isOnline));
    });
  }
}
