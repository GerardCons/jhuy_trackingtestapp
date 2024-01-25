// order_page.dart

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverViewOrder extends StatefulWidget {
  final double clientLat;
  final double clientLong;
  final String orderId;
  final String userEmail;

  DriverViewOrder({
    required this.clientLat,
    required this.clientLong,
    required this.orderId,
    required this.userEmail,
  });

  @override
  _DriverViewOrderState createState() => _DriverViewOrderState();
}

class _DriverViewOrderState extends State<DriverViewOrder> {
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
        label: const Text('Deliver Now'),
        icon: const Icon(Icons.approval),
      ),
    );
  }

  Future<void> acceptOrder() async {
    try {
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

      final docOrder =
          FirebaseFirestore.instance.collection('Delivery').doc(widget.orderId);

      final data = {
        'deliveryDate': Timestamp.now(),
        'deliveryStatus': 'In Transit',
      };

      await docOrder.update(data);

      // Open Waze with the specified destination coordinates
      final wazeUrl = Uri.parse(
          'https://www.waze.com/ul?ll=${widget.clientLat},${widget.clientLong}&navigate=yes');
      if (await canLaunchUrl(wazeUrl)) {
        await launchUrl(wazeUrl);
      } else {
        // Handle the case where Waze cannot be opened
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open Waze. Please install the Waze app.'),
          ),
        );
      }
    } catch (e) {
      print('Error creating order: $e');
    }
  }
}
