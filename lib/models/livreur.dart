import 'dart:convert';

class Livreur {
  final String id;
  final String email;
  final String userName;
  final String name;
  final String firstName;
  final String address;
  final String phone;
  final String? role;
  final Location? currentLocation; // Modifier currentLocation en un objet Location
  final List<UnavailablePeriod>? unavailablePeriods;

  Livreur({
    required this.id,
    required this.email,
    required this.userName,
    required this.name,
    required this.address,
    required this.phone,
    required this.firstName,
    this.role,
    this.currentLocation,
    this.unavailablePeriods,
  });

  // Convert from JSON
  factory Livreur.fromJson(Map<String, dynamic> json) {
    return Livreur(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      userName: json['userName'] ?? '',
      name: json['name'] ?? '',
      firstName: json['firstName'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? '',
      currentLocation: json['currentLocation'] != null
          ? Location.fromJson(json['currentLocation'])
          : null,
      unavailablePeriods: json['unavailablePeriods'] != null
          ? List<UnavailablePeriod>.from(
              json['unavailablePeriods'].map((x) => UnavailablePeriod.fromJson(x)))
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        '_id': id,
        'email': email,
        'userName': userName,
        'name': name,
        'firstName': firstName,
        'address': address,
        'phone': phone,
        'role': role,
        'currentLocation': currentLocation?.toJson(),
        'unavailablePeriods': unavailablePeriods != null
            ? List<dynamic>.from(unavailablePeriods!.map((x) => x.toJson()))
            : null,
      };
}

class Location {
  final double latitude;
  final double longitude;

  Location({
    required this.latitude,
    required this.longitude,
  });

  // Convert from JSON
  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      latitude: json['latitude']?.toDouble() ?? 0.0,
      longitude: json['longitude']?.toDouble() ?? 0.0,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}

class UnavailablePeriod {
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  UnavailablePeriod({
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  // Convert from JSON
  factory UnavailablePeriod.fromJson(Map<String, dynamic> json) {
    return UnavailablePeriod(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      reason: json['reason'] ?? '',
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'reason': reason,
      };
}
