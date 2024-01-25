import 'package:cloud_firestore/cloud_firestore.dart';
class Delivery {
  final String clientId;
  final String clientName;
  final String clientEmail;
  final String clientLatitude;
  final String clientLongitude;
  final String deliveryStatus;
  final String orderedDate;
  final String? deliveryDate;
  final String? driverName;
  final String? driverId;
  final String? driverEmail;
  final String? driverLatitude;
  final String? driverLongitude;

  Delivery({
    required this.clientId,
    required this.clientName,
    required this.clientEmail,
    required this.clientLatitude,
    required this.clientLongitude,
    required this.deliveryStatus,
    required this.orderedDate,
    this.deliveryDate,
    this.driverName,
    this.driverId,
    this.driverEmail,
    this.driverLatitude,
    this.driverLongitude,
  });

  factory Delivery.fromMap(Map<String, dynamic> map) {
    return Delivery(
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? '',
      clientEmail: map['clientEmail'] ?? '',
      clientLatitude: map['clientLatitude'] ?? '',
      clientLongitude: map['clientLongitude'] ?? '',
      deliveryStatus: map['deliveryStatus'] ?? '',
      orderedDate: map['orderedDate'] != null
          ? (map['orderedDate'] as Timestamp).toDate().toString()
          : '',
      deliveryDate: map['deliveryDate'] ?? '',
      driverName: map['driverName'] ?? '',
      driverId: map['driverId'] ?? '',
      driverEmail: map['driverEmail'] ?? '',
      driverLatitude: map['driverLatitude'] ?? '',
      driverLongitude: map['driverLongitude'] ?? '',
    );
  }
}
