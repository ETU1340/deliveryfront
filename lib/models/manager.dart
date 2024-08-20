import 'location.dart';
class Manager {
  final String id;
  final String email;
  final String password;
  final String name;
  final String address;
  final String phone;
  final String role;
  final String companyName;
  final String province;
  final Location location; // Utilisation de la classe Location

  Manager({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.address,
    required this.phone,
    required this.role,
    required this.companyName,
    required this.province,
    required this.location,
  });

  factory Manager.fromJson(Map<String, dynamic> json) {
    return Manager(
      id: json['_id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      role: json['role'],
      companyName: json['companyName'],
      province: json['province'],
      location: Location.fromJson(json['location']), // Conversion à partir de JSON
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'password': password,
      'name': name,
      'address': address,
      'phone': phone,
      'role': role,
      'companyName': companyName,
      'province': province,
      'location': location.toJson(), // Conversion en JSON
    };
  }
}