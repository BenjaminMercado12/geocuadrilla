import 'package:flutter/material.dart';

class DetalleScreen extends StatelessWidget {
  final String nombre = "Patricio";
  final String correo = "patricio@email.com";

  const DetalleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFD8231F),
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'Configuración de cuenta',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Color(0xFFEEE3E6),
                backgroundImage: AssetImage('assets/images/perfil.png'),
              ),
            ),
            SizedBox(height: 18),
            Center(
              child: Text(
                nombre,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFD8231F),
                ),
              ),
            ),
            SizedBox(height: 6),
            Center(
              child: Text(
                correo,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 24),
            Divider(color: Color(0xFFD8C2C8)),
            ListTile(
              leading: Icon(Icons.person, color: Color(0xFFD8231F)),
              title: Text('Editar perfil'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Color(0xFFD8231F)),
              title: Text('Cambiar contraseña'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.notifications, color: Color(0xFFD8231F)),
              title: Text('Notificaciones'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.help_outline, color: Color(0xFFD8231F)),
              title: Text('Ayuda'),
              trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () {},
            ),
            Divider(color: Color(0xFFD8C2C8)),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red[400]),
              title: Text('Cerrar sesión', style: TextStyle(color: Colors.red[400])),
              onTap: () {
                Navigator.pushNamed(context, '/login');
              },
            ),
          ],
        ),
      ),
    );
  }
}