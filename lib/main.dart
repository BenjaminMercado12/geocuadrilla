import 'package:flutter/material.dart';
import 'package:flutter_geocuadrilla/screens/tracker_screen.dart';
import 'package:provider/provider.dart';
import 'screens/services/auth_service.dart';
import 'screens/services/rabbitmq_service.dart';
import 'screens/services/location_service.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registro_screen.dart';
import 'screens/map_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/ms_login_screen.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) {
            final authService = AuthService();
            // Cargar token guardado al iniciar
            authService.loadSavedAuth();
            return authService;
          },
        ),
        ChangeNotifierProvider(
          create: (_) {
            final rabbitMqService = RabbitMqService();
            // Conectar automáticamente al iniciar la app
            rabbitMqService.connect();
            return rabbitMqService;
          },
        ),
        ChangeNotifierProxyProvider<RabbitMqService, LocationService>(
          create: (context) => LocationService(
            Provider.of<RabbitMqService>(context, listen: false),
          ),
          update: (context, rabbitmq, location) => location ?? LocationService(rabbitmq),
        ),
      ],
      child: MaterialApp(
        initialRoute: '/login',
        routes: {
          '/login': (context) => LoginScreen(),
          '/home': (context) => HomeScreen(),
          '/registro': (context) => RegistroScreen(),
          '/mapa': (context) => MapScreen(),
          '/detalle': (context) => DetalleScreen(),
          '/tracker': (context) => LocationTracker(),
          '/mslogin': (context) => MsLoginScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

