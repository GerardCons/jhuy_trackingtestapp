import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:jhuy_trackingtestapp/class/delivery.dart';
import 'package:jhuy_trackingtestapp/main.dart';
import 'package:uuid/uuid.dart';

class UserHomePage extends StatefulWidget {
  final String userEmail;
  UserHomePage({required this.userEmail});

  @override
  _UserHomePageState createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  late Stream<List<Delivery>> deliveryStream;
  var uuid = const Uuid();
  String _uid = "";

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) =>
            MyApp())); // Replace MyApp with your main page widget
    // You can add navigation logic to the login or home page after logout
  }

  Future<void> createOrder() async {
    try {
      print(widget.userEmail);

      // Fetch user information from the "User" collection
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: widget.userEmail)
          .get();

      if (userQuery.docs.isEmpty) {
        return; // User not found in the "User" collection
      }

      final String userId = userQuery.docs.first.id;
      final String firstName = userQuery.docs.first['firstName'];
      final String lastName = userQuery.docs.first['lastName'];

      // Check if location services are enabled
      bool isLocationServiceEnabled =
          await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        // Location services are not enabled, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please turn on location services.'),
          ),
        );
        return;
      }

      // Request location permissions
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse) {
        // Location permission not granted, show a message to the user
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location permission not granted.'),
          ),
        );
        return;
      }

      // Get user's location (latitude and longitude)
      final Position position = await Geolocator.getCurrentPosition();
      final double latitude = position.latitude;
      final double longitude = position.longitude;

      // Generate a unique ID for the order
      final String orderId = Uuid().v4();

      // Create a new document in the "Delivery" collection
      final docOrder =
          FirebaseFirestore.instance.collection('Delivery').doc(orderId);

      final data = {
        'id': orderId,
        'clientId': userId,
        'clientName': '$firstName $lastName',
        'clientEmail': widget.userEmail,
        'clientLatitude': latitude.toString(),
        'clientLongitude': longitude.toString(),
        'deliveryStatus': 'Pending',
        'orderedDate': Timestamp.now(), // Current timestamp
      };

      await docOrder.set(data);
      print(data);
    } catch (e) {
      print('Error creating order: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Initialize deliveryStream here to ensure it gets updated every time the widget rebuilds
    deliveryStream = FirebaseFirestore.instance
        .collection('Delivery')
        .where('clientEmail', isEqualTo: widget.userEmail)
        .snapshots()
        .map((querySnapshot) => querySnapshot.docs
            .map((doc) => Delivery.fromMap(doc.data()))
            .toList());

    return Scaffold(
      appBar: AppBar(
        title: Text('User Home'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Delivery>>(
              stream: deliveryStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No delivery data available.'));
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      final delivery = snapshot.data![index];
                      // Parse the orderedDate string to a DateTime object
                      final orderedDate = DateTime.parse(delivery.orderedDate);

                      // Format the orderedDate as a date string
                      final formattedDate =
                          DateFormat('MMMM dd, yyyy').format(orderedDate);

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Status: ${delivery.deliveryStatus}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Order Date: ${formattedDate}'),
                              Text(
                                'Rider: ${delivery.driverName!.isEmpty ? 'Pending' : delivery.driverName}',
                              ),
                              Text(
                                'Delivery Date: ${delivery.deliveryDate!.isEmpty ? 'Pending' : delivery.deliveryDate}',
                              ),
                            ],
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
            onPressed: createOrder,
            child: Text('Create Order'),
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
