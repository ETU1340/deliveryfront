class Province {
  final String name;
  final double latitude;
  final double longitude;

  Province({
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  // Convert from JSON
  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      name: json['name'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
      };
}
