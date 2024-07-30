class ApiUrls {
  static const String baseUrl = 'localhost:7000/api/';

  // Auth URLs
  static const String register = '$baseUrl/register';
  static const String login = '$baseUrl/login';

  // Manager URLs
  static const String getManagers = '$baseUrl/managers';
  static const String getManagerById = '$baseUrl/managers/';

  // Livreur URLs
  static const String getLivreurs = '$baseUrl/livreurs';
  static const String getLivreurById = '$baseUrl/livreurs/';

  // Client URLs
  static const String getClients = '$baseUrl/clients';
  static const String getClientById = '$baseUrl/clients/';

  // Exemple d'URL avec un paramètre
  static String getLivreurDetails(String id) => '$baseUrl/livreurs/$id';
}
