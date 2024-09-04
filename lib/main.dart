import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'config/theme.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'services/socket_service.dart';
import 'utils/api_urls.dart';
//flutter run -d chrome --web-port=65309
void main() {
  // Configurer le logger
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
      print('Stack trace: ${record.stackTrace}');
    }
  });

  FlutterError.onError = (FlutterErrorDetails details) {
  FlutterError.presentError(details);
  Logger('FlutterError').severe(details.exceptionAsString(), details.exception, details.stack);
  };

  runZonedGuarded(() {
    runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SocketService(ApiUrls.socketUrl)),
      ],
      child: MyApp(),
    ),);
  }, (error, stackTrace) {
    Logger('runZonedGuarded').severe('Uncaught error', error, stackTrace);
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Delivery Management App',
      theme: appTheme(),
      initialRoute: '/',
      routes: AppRoutes.getRoutes(),
    );
  }
}
