class ApiUrls {
  static const String baseUrl = 'http://localhost:7000/api';
  //static const String baseUrl = 'https://delivery.psad.hco.mg/api';
  // Auth URLs
  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';

  // Manager URLs
  static const String getManagers = '$baseUrl/managers';
  static const String getManagerById = '$baseUrl/managers/';

  // Livreur URLs
  static const String livreurs = '$baseUrl/livreurs';

  static const String chats = '$baseUrl/chats';

  static const String deliveries = '$baseUrl/deliveries';

  // Client URLs
  static const String getClients = '$baseUrl/clients';
  static const String getClientById = '$baseUrl/clients/';
  static const String socketUrl = 'https://location.psad.hco.mg';
  //static const String socketUrl = 'http://localhost:8080';


  // Exemple d'URL avec un paramètre
  static String getLivreurDetails(String id) => '$baseUrl/livreurs/$id';
}
