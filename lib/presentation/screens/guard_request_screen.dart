import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/ride_service.dart';

class GuardRequestScreen extends StatefulWidget {
  const GuardRequestScreen({super.key});

  @override
  State<GuardRequestScreen> createState() => _GuardRequestScreenState();
}

class _GuardRequestScreenState extends State<GuardRequestScreen> {
  bool notified = false;

  final RideService rideService = RideService();

  /// FORMAT TIME FROM TIMESTAMP
  Map<String, String> formatScheduled(dynamic timestamp) {
    if (timestamp == null) {
      return {"date": "Not set", "time": "Not set"};
    }

    final dt = (timestamp as Timestamp).toDate();

    return {
      "date": "${dt.day}/${dt.month}/${dt.year}",
      "time": "${dt.hour}:${dt.minute.toString().padLeft(2, '0')}",
    };
  }

  @override
  Widget build(BuildContext context) {
    final guardId = FirebaseAuth.instance.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Guard Requests")),
      body: Column(
        children: [
          /// ================= PENDING REQUESTS =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: rideService.pendingRides(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final requests = snapshot.data!.docs;

                if (requests.isNotEmpty && !notified) {
                  notified = true;

                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("🚨 New Ride Request"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  });
                }

                if (requests.isEmpty) {
                  notified = false;
                  return const Center(child: Text("No Pending Requests"));
                }

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final doc = requests[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final formatted = formatScheduled(data["scheduledTime"]);

                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: Text("Customer: ${data["customerId"]}"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Pending Request"),
                            Text("Date: ${formatted["date"]}"),
                            Text("Time: ${formatted["time"]}"),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.green,
                              ),
                              onPressed: () =>
                                  rideService.acceptRide(doc.id, guardId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => rideService.rejectRide(doc.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(),

          /// ================= SCHEDULED RIDES =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: rideService.scheduledRides(guardId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rides = snapshot.data!.docs;

                if (rides.isEmpty) {
                  return const Center(child: Text("No Scheduled Bookings"));
                }

                return ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final doc = rides[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final formatted = formatScheduled(data["scheduledTime"]);

                    return Card(
                      color: Colors.orange.shade50,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: const Text("Scheduled Booking"),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Customer: ${data["customerId"]}"),
                            Text("Date: ${formatted["date"]}"),
                            Text("Time: ${formatted["time"]}"),
                          ],
                        ),

                        /// ⭐ THIS FIXES YOUR PROBLEM
                        trailing: ElevatedButton(
                          onPressed: () =>
                              rideService.acceptRide(doc.id, guardId),
                          child: const Text("ACCEPT"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          const Divider(),

          /// ================= ACTIVE RIDES =================
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: rideService.acceptedRides(guardId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final rides = snapshot.data!.docs;

                if (rides.isEmpty) {
                  return const Center(child: Text("No Active Ride"));
                }

                return ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    final doc = rides[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Card(
                      color: Colors.green.shade50,
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title: const Text("Active Ride"),
                        subtitle: Text("Customer: ${data["customerId"]}"),
                        trailing: ElevatedButton(
                          onPressed: () => rideService.finishRide(doc.id),
                          child: const Text("FINISH"),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
