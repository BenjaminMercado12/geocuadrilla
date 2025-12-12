// Modelos de datos para autenticación según la guía
class LoginRequest {
  final String userName;
  final String password;
  final bool rememberMe;
  
  LoginRequest({
    required this.userName, 
    required this.password, 
    this.rememberMe = false
  });
  
  Map<String, dynamic> toJson() => {
    'userName': userName,
    'password': password,
    'rememberMe': rememberMe,
  };
}

class AuthResult {
  final bool success;
  final String token;
  final String refreshToken;
  final DateTime expiresAt;
  final UserInfo user;
  
  AuthResult.fromJson(Map<String, dynamic> json)
    : success = json['success'] ?? false,
      token = json['token'] ?? '',
      refreshToken = json['refreshToken'] ?? '',
      expiresAt = DateTime.tryParse(json['expiresAt'] ?? '') ?? DateTime.now(),
      user = UserInfo.fromJson(json['user'] ?? {});
}

class UserInfo {
  final String id;
  final String userName;
  final String email;
  final String role;
  
  UserInfo({
    required this.id,
    required this.userName,
    required this.email,
    required this.role,
  });
  
  UserInfo.fromJson(Map<String, dynamic> json)
    : id = json['id'] ?? '',
      userName = json['userName'] ?? '',
      email = json['email'] ?? '',
      role = json['role'] ?? '';
}