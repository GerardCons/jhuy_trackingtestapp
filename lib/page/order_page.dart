// order_page.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:jhuy_trackingtestapp/page/driver_MyOrder.dart';

class OrderPage extends StatefulWidget {
  final double clientLat;
  final double clientLong;
  final String orderId;
  final String userEmail;

  OrderPage({
    required this.clientLat,
    required this.clientLong,
    required this.orderId,
    required this.userEmail,
  });

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  late CameraPosition _kGooglePlex;
  late Marker _clientMarker;

  @override
  void initState() {
    super.initState();
    _kGooglePlex = CameraPosition(
      target: LatLng(widget.clientLat, widget.clientLong),
      zoom: 18,
    );
    _clientMarker = Marker(
      markerId: MarkerId('client_location'),
      position: LatLng(widget.clientLat, widget.clientLong),
      infoWindow: InfoWindow(title: 'Client Location'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _kGooglePlex,
        markers: {_clientMarker},
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: acceptOrder,
        label: const Text('Accept Order'),
        icon: const Icon(Icons.approval),
      ),
    );
  }

  Future<void> acceptOrder() async {
    try {
      print(widget.userEmail);

      // Fetch user information from the "User" collection
      final QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('driver')
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

      // Create a new document in the "Delivery" collection
      final docOrder =
          FirebaseFirestore.instance.collection('Delivery').doc(widget.orderId);

      final data = {
        'deliveryDate': Timestamp.now(),
        'driverId': userId,
        'driverName': '$firstName $lastName',
        'driverEmail': widget.userEmail,
        'driverLatitude': latitude.toString(),
        'driverLongitude': longitude.toString(),
        'deliveryStatus': 'Accepted - Waiting to be delivered',
      };

      await docOrder.update(data);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (context) =>
                DriverMyOrderPage(userEmail: widget.userEmail)),
      );
      print(data);
    } catch (e) {
      print('Error creating order: $e');
    }
  }
}
