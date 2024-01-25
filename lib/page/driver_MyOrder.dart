import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:jhuy_trackingtestapp/page/driver_home.dart';
import 'package:jhuy_trackingtestapp/page/myOrder_page.dart';

class DriverMyOrderPage extends StatefulWidget {
  final String userEmail;
  DriverMyOrderPage({required this.userEmail});
  @override
  _DriverMyOrderPageState createState() => _DriverMyOrderPageState();
}

class _DriverMyOrderPageState extends State<DriverMyOrderPage> {
  late Stream<QuerySnapshot> deliveryStream;

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    // You can add navigation logic to the login or home page after logout
  }

  @override
  Widget build(BuildContext context) {
    // Initialize deliveryStream here to ensure it gets updated every time the widget rebuilds
    deliveryStream = FirebaseFirestore.instance
        .collection('Delivery')
        .where('driverEmail', isEqualTo: widget.userEmail)
        .snapshots();

    return Scaffold(
      appBar: AppBar(
        title: Text('My Orders'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: deliveryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No pending deliveries.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final delivery = snapshot.data!.docs[index];
                      final orderId = delivery.id;
                      final clientName = delivery['clientName'];
                      final orderedDate = delivery['orderedDate'] as Timestamp;
                      final clientlat = delivery['clientLatitude'];
                      final clientLong = delivery['clientLongitude'];
                      // Convert orderedDate (Timestamp) to a DateTime
                      final date = orderedDate.toDate();

                      // Format the DateTime as a date string
                      final formattedDate =
                          DateFormat('MMMM dd, yyyy').format(date);

                      return InkWell(
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => DriverViewOrder(
                                  clientLat: double.parse(clientlat),
                                  clientLong: double.parse(clientLong),
                                  orderId: orderId,
                                  userEmail: widget.userEmail),
                            ),
                          );
                        },
                        child: Card(
                          margin: EdgeInsets.all(8.0),
                          child: ListTile(
                            title: Text('Order Id: $orderId'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Client Name: $clientName'),
                                Text('Order Date: $formattedDate'),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) =>
                        DriverHomePage(userEmail: widget.userEmail)),
              );
            },
            child: Text('View Orders'),
          ),
          ElevatedButton(
            onPressed: _logout,
            child: Text('Logout'),
          ),
        ],
      ),
    );
  }
}
