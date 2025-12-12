//import 'package:aad_oauth/aad_oauth.dart';//
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/environment_config.dart'; 

/*
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
final Config config = Config(
  tenant: "Your TenantId", // Set this to "common" for multi-tenant apps
  clientId: "Your clientId",
  scope: MicrosoftConfig().scope,
  redirectUri: kIsWeb
      ? "your local host URL"
      : "your native client URL",
  navigatorKey: navigatorKey, // Ensure this key is defined in your main file under MaterialApp.
);
 class AuthService extends ChangeNotifier {
  // ...existing code...

  Future<void> azureSignInApi(BuildContext context, {bool redirect = true}) async {
    final AadOAuth oauth = AadOAuth(config);

    config.webUseRedirect = redirect;
    final result = await oauth.login();

    result.fold(
      (l) => showError("Microsoft Authentication Failed!", context),
      (r) async {
        // Aquí deberías implementar el método fetchAzureUserDetails en AuthService
        await fetchAzureUserDetails(r.accessToken);
      },
    );
  }

  Future<void> fetchAzureUserDetails(String accessToken) async {
    // Implementa aquí la lógica para obtener los datos del usuario desde Azure AD
    debugPrint('🔑 AccessToken recibido: $accessToken');
    // Ejemplo: llamada a tu API con el accessToken
  }
   Future<Map<String, dynamic>?> fetchAzureUserDetails(String accessToken) async {
    try {
      final response = await http.get(
        Uri.parse("https://graph.microsoft.com/v1.0/me"),
        headers: {"Authorization": "Bearer $accessToken"},
      );

      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      } else {
        debugPrint('❌ Error obteniendo datos de usuario Azure: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      debugPrint('💥 Excepción en fetchAzureUserDetails: $e');
      return null;
    }
  }

*/
  void showError(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
class AuthService extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final http.Client _client = http.Client();
  String? _token;
  
  bool get isAuthenticated => _token != null;

  Future<bool> login(String userName, String password) async {
    final request = {
      'userName': userName,
      'password': password,
      'rememberMe': false,
    };

    try {
      debugPrint('🔄 Intentando login con usuario: $userName');
      debugPrint('🌐 Endpoint: ${EnvironmentConfig.authEndpoint}');
      debugPrint('📦 Request body: ${jsonEncode(request)}');
      
      final response = await _client.post(
        Uri.parse(EnvironmentConfig.authEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request),
      ).timeout(Duration(seconds: 10));

      debugPrint('📊 Status Code: ${response.statusCode}');
      debugPrint('📄 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        
        if (result.containsKey('token') && result['token'] != null) {
          _token = result['token'];
          await _storage.write(key: 'token', value: _token);
          debugPrint('✅ Login exitoso, token guardado');
          notifyListeners();
          return true;
        } else {
          debugPrint('❌ Respuesta exitosa pero sin token válido');
          return false;
        }
      } else {
        debugPrint('❌ Login fallido - Status: ${response.statusCode}');
        debugPrint('❌ Error response: ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('💥 Excepción durante login: $e');
      return false;
    }
  }

  // Cargar token guardado al iniciar la app
  Future<void> loadSavedAuth() async {
    try {
      final token = await _storage.read(key: 'token');
      
      if (token != null) {
        _token = token;
        notifyListeners();
        debugPrint('✅ Token cargado desde almacenamiento seguro');
      }
    } catch (e) {
      debugPrint('❌ Error cargando auth: $e');
    }
  }

  void logout() async {
    _token = null;
    await _storage.delete(key: 'token');
    notifyListeners();
  }
}
