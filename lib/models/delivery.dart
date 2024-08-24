import 'location.dart';
import 'livreur.dart';

class Delivery {
  final String id;
  final String clientName;
  final String clientSurname;
  final String clientEmail;
  final String validationCode;
  final String reference;
  final Location deliveryAddress;
  final DateTime deliveryDateTime;  // Combined DateTime field
  final String deliveryType;
  final String status;
  final String livreurId;
  final Livreur? livreur;
  final String managerId;

  Delivery({
    required this.id,
    required this.clientName,
    required this.clientSurname,
    required this.clientEmail,
    required this.validationCode,
    required this.reference,
    required this.deliveryAddress,
    required this.deliveryDateTime,  // Combined DateTime field
    required this.deliveryType,
    required this.status,
    required this.livreurId,
    this.livreur,
    required this.managerId,
  });

factory Delivery.fromJson(Map<String, dynamic> json) {
  return Delivery(
    id: json['_id'] ?? '',
    clientName: json['clientName'] ?? '',
    clientSurname: json['clientSurname'] ?? '',
    clientEmail: json['clientEmail'] ?? '',
    validationCode: json['validationCode'] ?? '',
    reference: json['reference'] ?? '',
    deliveryAddress: Location.fromJson(json['deliveryAddress'] ?? {}),
    deliveryDateTime: DateTime.parse(json['deliveryDateTime'] ?? ''),
    deliveryType: json['deliveryType'] ?? '',
    status: json['status'] ?? '',
    livreurId: json['livreurId'] != null && json['livreurId'] is Map<String, dynamic> 
        ? (json['livreurId']['_id'] ?? '')
        : '',
    livreur: json['livreurId'] != null && json['livreurId'] is Map<String, dynamic> 
        ? Livreur.fromJson(json['livreurId'] as Map<String, dynamic>)
        : null,
    managerId: json['managerId'] ?? '',
  );
}



  Map<String, dynamic> toJson() {
    return {
      'clientName': clientName,
      'clientSurname': clientSurname,
      'clientEmail': clientEmail,
      'validationCode': validationCode,
      'reference': reference,
      'deliveryAddress': deliveryAddress.toJson(),
      'deliveryDateTime': deliveryDateTime.toIso8601String(),  // Combined DateTime field
      'deliveryType': deliveryType,
      'status': status,
      'livreurId': livreurId,
      'livreur': livreur?.toJson(),  // Serializing the nested Livreur object
      'managerId': managerId,
    };
  }
}
