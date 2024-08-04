class User {
  final String id;
  final String email;
  final String password;
  final String name;
  final String address;
  final String phone;
  final String role;

  User({
    required this.id,
    required this.email,
    required this.password,
    required this.name,
    required this.address,
    required this.phone,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      email: json['email'],
      password: json['password'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      role: json['role'],
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
    };
  }
}
