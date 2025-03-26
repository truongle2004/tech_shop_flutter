import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProvider with ChangeNotifier {
  String? _accessToken;
  String? _refreshToken;
  List<String> _roles = [];
  bool _isAuthenticated = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  List<String> get roles => _roles;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state from storage
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('access_token');
    _refreshToken = prefs.getString('refresh_token');
    _roles = prefs.getStringList('roles') ?? [];
    _isAuthenticated = _accessToken != null;
    notifyListeners();
  }

  // Handle successful login
  Future<void> handleLoginSuccess(Map<String, dynamic> response) async {
    _accessToken = response['access_token'];
    _refreshToken = response['refresh_token'];
    _roles = List<String>.from(response['roles'] ?? []);
    _isAuthenticated = true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', _accessToken!);
    await prefs.setString('refresh_token', _refreshToken!);
    await prefs.setStringList('roles', _roles);

    notifyListeners();
  }

  // Handle logout
  Future<void> logout() async {
    _accessToken = null;
    _refreshToken = null;
    _roles = [];
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('roles');

    notifyListeners();
  }

  // Check if user has a specific role
  bool hasRole(String role) {
    return _roles.contains(role);
  }

  // Check if user has any of the specified roles
  bool hasAnyRole(List<String> roles) {
    return _roles.any((role) => roles.contains(role));
  }

  // Check if user has all of the specified roles
  bool hasAllRoles(List<String> roles) {
    return roles.every((role) => _roles.contains(role));
  }

  // Get authorization header for API requests
  Map<String, String> getAuthHeader() {
    return {
      'Authorization': 'Bearer $_accessToken',
      'Content-Type': 'application/json',
    };
  }
}
