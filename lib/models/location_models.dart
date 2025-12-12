// Modelos de datos para ubicación según la guía
class LocationMessage {
  final String crewId;
  final DateTime timestamp;
  final double latitude;
  final double longitude;
  final Map<String, dynamic>? metadata;
  final String source;
  
  LocationMessage({
    required this.crewId,
    required this.timestamp,
    required this.latitude,
    required this.longitude,
    this.metadata,
    this.source = 'flutter_app',
  });
  
  Map<String, dynamic> toJson() => {
    'crewId': crewId,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'latitude': latitude,
    'longitude': longitude,
    'metadata': metadata ?? {},
    'source': source,
  };
  
  factory LocationMessage.fromJson(Map<String, dynamic> json) {
    return LocationMessage(
      crewId: json['crewId'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
      metadata: json['metadata'],
      source: json['source'] ?? 'flutter_app',
    );
  }
}