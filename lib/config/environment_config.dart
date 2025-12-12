class EnvironmentConfig {
  // API Configuration (según la guía)
  static const String apiBaseUrl = 'http://10.10.0.7:8081';
  static const String authEndpoint = '$apiBaseUrl/api/Auth/login';
  
  // Configuración RabbitMQ (según la guía)
  static const String rabbitMqHost = '10.10.0.7';
  static const int rabbitMqPort = 5672;
  static const String rabbitMqUsername = 'admin';
  static const String rabbitMqPassword = 'Admin123!';
  
  // Configuración de colas (según la guía)
  static const String locationQueue = 'location_updates';
  static const String statusQueue = 'geocuadrilla_status';
  static const String exchangeName = 'geocuadrilla_exchange';
}