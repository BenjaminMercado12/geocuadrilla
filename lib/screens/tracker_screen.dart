import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/location_service.dart';
import 'services/rabbitmq_service.dart';

class LocationTracker extends StatelessWidget {
  final _crewController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tracker de Cuadrilla'),
        backgroundColor: Color(0xFFD8231F),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Consumer2<LocationService, RabbitMqService>(
          builder: (context, location, rabbitmq, child) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Estado de conexión RabbitMQ
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: rabbitmq.isConnected ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: rabbitmq.isConnected ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        rabbitmq.isConnected ? Icons.check_circle : Icons.error,
                        color: rabbitmq.isConnected ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'RabbitMQ: ${rabbitmq.isConnected ? "Conectado" : "Desconectado"}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: rabbitmq.isConnected ? Colors.green[800] : Colors.red[800],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                
                // Campo ID Cuadrilla (solo si no está trackeando)
                if (!location.isTracking) ...[
                  TextField(
                    controller: _crewController,
                    decoration: InputDecoration(
                      labelText: 'ID Cuadrilla',
                      hintText: 'Ingrese el identificador de la cuadrilla',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.group),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
                
                // Botón de control
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: location.isTracking ? Colors.red[600] : Color(0xFFD8231F),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  icon: Icon(location.isTracking ? Icons.stop : Icons.play_arrow),
                  label: Text(
                    location.isTracking ? 'Parar Tracking' : 'Iniciar Tracking',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: location.isTracking
                      ? location.stopTracking
                      : () {
                          if (_crewController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Por favor ingrese el ID de la cuadrilla'),
                                backgroundColor: Colors.red[600],
                              ),
                            );
                            return;
                          }
                          location.startTracking(_crewController.text.trim());
                        },
                ),
                
                // Estado del tracking
                if (location.isTracking) ...[
                  SizedBox(height: 24),
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue[300]!),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.location_on, color: Colors.blue[600], size: 32),
                        SizedBox(height: 8),
                        Text(
                          'Tracking Activo',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Cuadrilla: ${_crewController.text}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}
