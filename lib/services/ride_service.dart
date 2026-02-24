import 'package:cloud_firestore/cloud_firestore.dart';

class RideService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ================= STREAMS =================

  /// Pending requests (for guards)
  Stream<QuerySnapshot> pendingRides() {
    return _firestore
        .collection("rides")
        .where("status", isEqualTo: "pending")
        .snapshots();
  }

  /// Accepted rides (active)
  Stream<QuerySnapshot> acceptedRides(String guardId) {
    return _firestore
        .collection("rides")
        .where("status", isEqualTo: "accepted")
        .where("guardId", isEqualTo: guardId)
        .snapshots();
  }

  /// ⭐ Scheduled rides (NEW)
  Stream<QuerySnapshot> scheduledRides(String guardId) {
    return _firestore
        .collection("rides")
        .where("status", isEqualTo: "scheduled")
        .where("guardId", isEqualTo: guardId)
        .snapshots();
  }

  /// Single ride stream
  Stream<DocumentSnapshot> rideStream(String rideId) {
    return _firestore.collection("rides").doc(rideId).snapshots();
  }

  /// Guard live location stream
  Stream<DocumentSnapshot> guardStream(String guardId) {
    return _firestore.collection("guards").doc(guardId).snapshots();
  }

  /// Online guards list
  Stream<QuerySnapshot> onlineGuards() {
    return _firestore
        .collection("guards")
        .where("isOnline", isEqualTo: true)
        .snapshots();
  }

  /// ================= ACTIONS =================

  /// ⭐ CREATE RIDE (Supports booking date & time)
  Future<DocumentReference> createRide({
    required String customerId,
    required String guardId,
    required double lat,
    required double lng,
    String? bookingDate,
    String? bookingTime,
  }) async {
    return await _firestore.collection("rides").add({
      "customerId": customerId,
      "guardId": guardId,
      "status": bookingDate == null ? "pending" : "scheduled",
      "latitude": lat,
      "longitude": lng,
      "bookingDate": bookingDate,
      "bookingTime": bookingTime,
      "timestamp": FieldValue.serverTimestamp(),
    });
  }

  /// Accept ride
  Future<void> acceptRide(String docId, String guardId) async {
    await _firestore.collection("rides").doc(docId).update({
      "status": "accepted",
      "guardId": guardId,
    });
  }

  /// Reject ride
  Future<void> rejectRide(String docId) async {
    await _firestore.collection("rides").doc(docId).update({
      "status": "rejected",
    });
  }

  /// Finish ride
  Future<void> finishRide(String docId) async {
    await _firestore.collection("rides").doc(docId).update({
      "status": "completed",
    });
  }
}
