import 'package:flutter/material.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'rabbitmq_service.dart';
import '../../models/location_models.dart';

class LocationService extends ChangeNotifier {
  final RabbitMqService _rabbitMq;
  bool _isTracking = false;
  String? _crewId;
  Timer? _locationTimer;
  Position? _lastPosition;

  LocationService(this._rabbitMq);

  bool get isTracking => _isTracking;
  String? get currentCrewId => _crewId;
  Position? get lastPosition => _lastPosition;

  Future<void> startTracking(String crewId) async {
    if (crewId.trim().isEmpty) {
      debugPrint('❌ ID de cuadrilla vacío');
      return;
    }

    // Verificar permisos de ubicación
    final permission = await _checkLocationPermission();
    if (!permission) {
      debugPrint('❌ Permisos de ubicación denegados');
      return;
    }

    _crewId = crewId.trim();
    _isTracking = true;
    notifyListeners();

    // Conectar RabbitMQ si no está conectado
    if (!_rabbitMq.isConnected) {
      await _rabbitMq.connect();
    }

    // Iniciar timer para enviar ubicación cada 30 segundos (según la guía)
    _startLocationUpdates();

    debugPrint('✅ Tracking iniciado para cuadrilla: $_crewId');
  }

  void _startLocationUpdates() {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (!_isTracking) {
        timer.cancel();
        return;
      }

      try {
        final position = await Geolocator.getCurrentPosition();
        final message = LocationMessage(
          crewId: _crewId!,
          timestamp: DateTime.now(),
          latitude: position.latitude,
          longitude: position.longitude,
          metadata: {'accuracy': position.accuracy},
        );

        await _rabbitMq.sendLocation(message);
      } catch (e) {
        debugPrint('❌ Error obteniendo ubicación: $e');
      }
    });

    // Enviar ubicación inicial inmediatamente
    _sendInitialLocation();
  }

  Future<void> _sendInitialLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      _lastPosition = position;

      final message = LocationMessage(
        crewId: _crewId!,
        timestamp: DateTime.now().toUtc(),
        latitude: position.latitude,
        longitude: position.longitude,
        metadata: {
          'accuracy': position.accuracy,
          'initial': true, // Marcar como posición inicial
        },
      );

      await _rabbitMq.sendLocation(message);
      debugPrint('📤 Ubicación inicial enviada');
      
    } catch (e) {
      debugPrint('❌ Error enviando ubicación inicial: $e');
    }
  }

  Future<bool> _checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void stopTracking() {
    _isTracking = false;
    _crewId = null;
    _locationTimer?.cancel();
    _locationTimer = null;
    notifyListeners();
    
    debugPrint('🛑 Tracking detenido');
  }

  @override
  void dispose() {
    stopTracking();
    super.dispose();
  }
}
