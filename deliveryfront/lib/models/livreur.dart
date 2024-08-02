// models/livreur.dart
import 'dart:convert';

class Livreur {
  final String id;
  final String email;
  final String password;
  final String name;
  final String address;
  final String phone;
  final String role;
  final List<double> currentLocation;
  final List<UnavailablePeriod> unavailablePeriods;

  Livreur({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.address,
    required this.phone,
    required this.role,
    required this.currentLocation,
    required this.unavailablePeriods,
  });

  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['_id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      role: json['role'],
      currentLocation: List<double>.from(json['currentLocation']['coordinates']),
      unavailablePeriods: (json['unavailablePeriods'] as List)
          .map((e) => UnavailablePeriod.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'password': password,
      'name': name,
      'address': address,
      'phone': phone,
      'role': role,
      'currentLocation': {
        'type': 'Point',
        'coordinates': currentLocation,
      },
      'unavailablePeriods':
          unavailablePeriods.map((e) => e.toJson()).toList(),
    };
  }
}

class UnavailablePeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String   reason;

  UnavailablePeriod({
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  factory UnavailablePeriod.fromJson(Map<String, dynamic> json) {
    return UnavailablePeriod(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }
}
