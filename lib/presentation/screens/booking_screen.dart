import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key});

  void updateRideStatus(String rideId, String status) async {
    await FirebaseFirestore.instance.collection("rides").doc(rideId).update({
      "status": status,
    });
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Bookings")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection("rides")
            .where("guardId", isEqualTo: uid)
            .where("status", isEqualTo: "pending")
            .snapshots(),
        builder: (context, snapshot) {
          /// LOADING
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          /// NO BOOKINGS
          if (snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No pending bookings"));
          }

          /// BOOKINGS LIST
          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final ride = snapshot.data!.docs[index];
              final rideId = ride.id;

              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "New Booking",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text("Customer: ${ride["customerId"]}"),
                      Text("Status: ${ride["status"]}"),

                      const SizedBox(height: 15),

                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () =>
                                updateRideStatus(rideId, "accepted"),
                            child: const Text("Accept"),
                          ),

                          const SizedBox(width: 10),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            onPressed: () =>
                                updateRideStatus(rideId, "rejected"),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
