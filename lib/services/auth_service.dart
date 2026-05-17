import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/usuario.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  Usuario? currentUser;

  // Reemplaza estas URLs con los webhooks reales de n8n
  final String loginUrl = 'http://localhost:5678/webhook/login';
  final String registerUrl = 'http://localhost:5678/webhook/register';

  Future<bool> login(String usernameOrEmail, String password) async {
    try {
      final payload = {
        'usernameOrEmail': usernameOrEmail,
        'password': password,
      };

      print('📤 ENVIANDO LOGIN A N8N');
      print('URL: $loginUrl');

      final response = await http.post(
        Uri.parse(loginUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('📥 RESPUESTA DE LOGIN (${response.statusCode})');
      print(response.body);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        
        // Asumiendo que n8n devuelve el objeto del usuario si el login es exitoso
        // El webhook puede devolver { success: true, data: { usuario: {...} } } o { data: {...} }
        if (body is Map<String, dynamic>) {
          if (body['success'] == true || body.containsKey('data')) {
            Map<String, dynamic> userData = {};
            if (body['data'] is Map<String, dynamic>) {
              if (body['data'].containsKey('usuario')) {
                userData = body['data']['usuario'];
              } else {
                userData = body['data'];
              }
            } else {
              userData = body;
            }

            if (userData.containsKey('id')) {
              currentUser = Usuario.fromJson(userData);
              return true;
            }
          } else if (body.containsKey('id')) {
            currentUser = Usuario.fromJson(body);
            return true;
          }
        } else if (body is List && body.isNotEmpty) {
          currentUser = Usuario.fromJson(body[0]);
          return true;
        }
      }
      return false;
    } catch (e) {
      print('❌ ERROR EN LOGIN: $e');
      return false;
    }
  }

  Future<bool> register(Usuario usuario) async {
    try {
      final payload = usuario.toJson();
      // Remover ID para que la DB lo autogenere
      payload.remove('id');

      print('📤 ENVIANDO REGISTRO A N8N');
      print('URL: $registerUrl');

      final response = await http.post(
        Uri.parse(registerUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      print('📥 RESPUESTA DE REGISTRO (${response.statusCode})');
      print(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      print('❌ ERROR EN REGISTRO: $e');
      return false;
    }
  }

  void logout() {
    currentUser = null;
  }
}
