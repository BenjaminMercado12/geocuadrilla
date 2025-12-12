import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  CameraPosition? _initialPosition;
  GoogleMapController? _mapController;
  bool _trafficEnabled = true;
  Timer? _trafficTimer;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    // Iniciar la obtención de la ubicación al entrar en la pantalla
    _getCurrentLocation();
    _startTrafficTimer();
    _startLocationTimer();
  }

  @override
  void dispose() {
    _trafficTimer?.cancel();
    _locationTimer?.cancel();
    super.dispose();
  }

  void _startLocationTimer() {
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getCurrentLocation();
    });
  }

  void _startTrafficTimer() {
    _trafficTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      setState(() {
        _trafficEnabled = false;
      });
      Future.delayed(const Duration(milliseconds: 500), () {
        setState(() {
          _trafficEnabled = true;
        });
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El servicio de ubicación está deshabilitado. Por favor, actívalo.'),
        ),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes permitir el acceso a la ubicación para ver el mapa.'),
          ),
        );
        return;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Permiso de ubicación denegado permanentemente. Actívalo en ajustes.'),
        ),
      );
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _initialPosition = CameraPosition(
        target: LatLng(position.latitude, position.longitude),
        zoom: 15,
      );
    });

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(
          LatLng(position.latitude, position.longitude),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa Google')),
      body: _initialPosition == null
          ? const Center(child: CircularProgressIndicator())
          : GoogleMap(
              initialCameraPosition: _initialPosition!,
              markers: <Marker>{}, // ✅ ahora es un Set, no un Map
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              trafficEnabled: _trafficEnabled,
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _trafficEnabled = !_trafficEnabled;
          });
        },
        backgroundColor: Colors.white,
        child: Icon(
          _trafficEnabled ? Icons.traffic : Icons.traffic_outlined,
          color: Colors.red,
        ),
      ),
    );
  }
}