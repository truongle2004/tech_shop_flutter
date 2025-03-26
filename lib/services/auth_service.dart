import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:tech_shop_flutter/models/auth.dart';

class AuthService {
  final String authUrl = dotenv.env['AUTH_URL'] ?? '';

  AuthService() {
    if (authUrl.isEmpty) {
      throw Exception('AUTH_URL is not defined in the .env file');
    }
  }

  Future<dynamic> _post(
      {required String endpoint, required Map<String, dynamic> body}) async {
    try {
      final response = await http.post(
        Uri.parse('$authUrl$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      final responseBody = jsonDecode(utf8.decode(response.bodyBytes));

      return {
        'statusCode': response.statusCode,
        'data': responseBody,
        'success': response.statusCode == 200
      };
    } catch (e) {
      return {
        'statusCode': 0,
        'data': null,
        'success': false,
        'message': 'Network error: ${e.toString()}'
      };
    }
  }

  Future<dynamic> register(
      {required String username,
      required String email,
      required String password}) async {
    final res = await _post(endpoint: '/register', body: {
      'username': username,
      'email': email,
      'password': password,
    });

    if (res['success']) {
      try {
        return Auth.fromJson(res['data']);
      } catch (e) {
        return {
          'success': false,
          'message': 'Error parsing registration response',
          'error': e.toString()
        };
      }
    }

    return res;
  }

  Future<dynamic> login(
      {required String username, required String password}) async {
    final res = await _post(endpoint: '/login', body: {
      'username': username,
      'password': password,
    });

    if (res['success']) {
      print(res['data']);
      try {
        return Auth.fromJson(res['data']);
      } catch (e) {
        return {
          'success': false,
          'message': 'Error parsing login response',
          'error': e.toString()
        };
      }
    }

    return res;
  }
}
