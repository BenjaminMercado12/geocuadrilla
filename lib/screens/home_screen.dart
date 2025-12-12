import 'package:flutter/material.dart';
import 'package:flutter_geocuadrilla/screens/services/location_service.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _now;
  Timer? _timer;

  final String nombreTrabajador = "Patricio"; 

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        _now = DateTime.now();
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String saludo() {
    int hora = _now.hour;
    if (hora >= 6 && hora < 12) {
      return "Buenos días";
    } else if (hora >= 12 && hora < 20) {
      return "Buenas tardes";
    } else {
      return "Buenas noches";
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaActual = DateFormat('dd-MM-yyyy').format(_now);
    final horaActual = DateFormat('HH:mm:ss').format(_now);

    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6), // Fondo app
      appBar: AppBar(
        backgroundColor: Color(0xFFD8231F),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          '${saludo()},  $nombreTrabajador',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.normal,
            color: Colors.white,
            letterSpacing: 1.1,
            ),
            ),
            ),
body: Center(
  child: SingleChildScrollView(
    padding: EdgeInsets.symmetric(horizontal: 28),
    child: Column(
      children: [
        SizedBox(height: 50),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/detalle');
            },
            child: CircleAvatar(
              radius: 44,
              backgroundImage: AssetImage('assets/Imagenes/perfil.avif'),
              backgroundColor: Color(0xFFEEE3E6),
              ),
              ),
              SizedBox(height: 10), // Menos espacio entre imagen y texto
        Text(
          'Jornada: No Iniciada',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(255, 0, 0, 0),
          ),
        ),
        SizedBox(height: 10), // Menos espacio entre texto y fecha/hora
        Container(
          padding: EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: Color(0xFFEEE3E6),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Icon(Icons.calendar_today, size: 22, color:   Color.fromARGB(255, 0, 0, 0)),
                  SizedBox(height: 6),
                  Text(
                    fechaActual,
                    style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ],
              ),
              Column(
                children: [
                  Icon(Icons.access_time, size: 22, color: Color.fromARGB(255, 0, 0, 0)),
                  SizedBox(height: 6),
                  Text(
                    horaActual,
                    style: TextStyle(fontSize: 16, color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 24), // Espacio antes de los botones

              SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: Icon(Icons.play_arrow, color: Colors.white),
                  label: Text('Iniciar Jornada'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 20, 213, 26), // Rojo principal
                    padding: EdgeInsets.symmetric(vertical: 16),
                    textStyle: TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final isMounted = mounted; // Guarda el valor actual de mounted
                    final fecha = DateFormat('dd-MM-yyyy').format(DateTime.now());
                    final hora = DateFormat('HH:mm:ss').format(DateTime.now());
                    final locationService = Provider.of<LocationService>(context, listen: false);
                    locationService.startTracking('CREW-001');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Iniciaste tu jornada correctamente\n'
                          '$fecha $hora\n'
                          'Que tengas una buena jornada',
                          textAlign: TextAlign.center,
                        ),
                        duration: Duration(seconds: 4),
                        backgroundColor: Color(0xFFD8231F),
                      ),
                    );
                    Future.delayed(Duration(seconds: 4), () {
                      if (isMounted) {
                        Navigator.pushNamed(context, '/mapa');
                      }
                    });
                  },
                ),
              ),
              SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.pause_circle_filled, color: Color(0xFFD8231F)),
                      label: Text('Pausar'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Color(0xFFD8231F)),
                        foregroundColor: Color(0xFFD8231F),
                        backgroundColor: Color(0xFFEEE3E6),
                      ),
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: Icon(Icons.check_circle, color: Color(0xFFD8231F)),
                      label: Text('Finalizar'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Color(0xFFD8231F)),
                        foregroundColor: Color(0xFFD8231F),
                        backgroundColor: Color(0xFFEEE3E6),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Botón Tracker
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: Icon(Icons.track_changes, color: Color(0xFFD8231F)),
                  label: Text('Tracker de Ubicación'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    textStyle: TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Color(0xFFD8231F)),
                    foregroundColor: Color(0xFFD8231F),
                    backgroundColor: Color(0xFFEEE3E6),
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/tracker');
                  },
                ),
              ),
              SizedBox(height: 12),
              TextButton.icon(
                icon: Icon(Icons.logout, color: Color(0xFFD8231F)),
                label: Text(
                  'Salir',
                  style: TextStyle(color: Color(0xFFD8231F), fontSize: 16),
                ),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  foregroundColor: Color(0xFFD8231F),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                icon: Icon(Icons.login),
                label: Text('Login con Microsoft'),
                onPressed: () {
                  Navigator.pushNamed(context, '/mslogin');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
