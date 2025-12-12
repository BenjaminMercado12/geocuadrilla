import 'package:flutter/material.dart';
import 'package:dart_amqp/dart_amqp.dart';
import 'dart:convert';
import '../../config/environment_config.dart';
import '../../models/location_models.dart';

class RabbitMqService extends ChangeNotifier {
  Client? _client;
  Channel? _channel;
  bool _isConnected = false;
  String _connectionStatus = 'Desconectado';

  bool get isConnected => _isConnected;
  String get connectionStatus => _connectionStatus;

  Future<void> connect() async {
    try {
      _updateStatus('Conectando...');
      
      final settings = ConnectionSettings(
        host: EnvironmentConfig.rabbitMqHost,
        port: EnvironmentConfig.rabbitMqPort,
        authProvider: PlainAuthenticator(
          EnvironmentConfig.rabbitMqUsername,
          EnvironmentConfig.rabbitMqPassword,
        ),
      );

      _client = Client(settings: settings);
      _channel = await _client!.channel();
      
      _isConnected = true;
      _updateStatus('Conectado');
      
      debugPrint('✅ RabbitMQ conectado exitosamente');
      
    } catch (e) {
      debugPrint('❌ Error conectando RabbitMQ: $e');
      _isConnected = false;
      _updateStatus('Error: ${e.toString()}');
      
      // Reintento automático después de 5 segundos
      Future.delayed(Duration(seconds: 5), () {
        if (!_isConnected) {
          debugPrint('🔄 Reintentando conexión RabbitMQ...');
          connect();
        }
      });
    }
  }

  Future<bool> sendLocation(LocationMessage message) async {
    if (!_isConnected || _channel == null) {
      debugPrint('⚠️ No hay conexión RabbitMQ disponible');
      return false;
    }

    try {
      // Declarar y usar la queue directamente
      final queue = await _channel!.queue(
        EnvironmentConfig.locationQueue,
        durable: true,
        declare: false,
      );

      queue.publish(
        jsonEncode(message.toJson()),
      );

      debugPrint('📤 Mensaje enviado: ${message.crewId} - ${message.latitude}, ${message.longitude}');
      return true;
      
    } catch (e) {
      debugPrint('❌ Error enviando ubicación: $e');
      
      // Si hay error de conexión, intentar reconectar
      if (e.toString().contains('connection') || e.toString().contains('channel')) {
        _isConnected = false;
        _updateStatus('Desconectado - Reintentando...');
        connect();
      }
      
      return false;
    }
  }

  Future<void> disconnect() async {
    try {
      await _channel?.close();
      await _client?.close();
      _isConnected = false;
      _updateStatus('Desconectado');
      debugPrint('🔌 RabbitMQ desconectado');
    } catch (e) {
      debugPrint('Error desconectando RabbitMQ: $e');
    }
  }

  void _updateStatus(String status) {
    _connectionStatus = status;
    notifyListeners();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
