import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tech_shop_flutter/main.dart';
import 'package:tech_shop_flutter/models/auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tech_shop_flutter/provider/auth_provider.dart';
import 'package:tech_shop_flutter/services/auth_service.dart';
import 'package:tech_shop_flutter/utils/toast_notification.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FToast fToast = FToast();
  late ToastNotification toast;
  String username = '';
  String password = '';
  bool isObscure = true; // Password visibility toggle

  // Add text controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late Future<Auth> authFuture;

  void login() async {
    if (username.isEmpty && password.isEmpty) {
      toast.error('Please enter username and password');
    } else if (username.isEmpty) {
      toast.error('Please enter username');
    } else if (password.isEmpty) {
      toast.error('Please enter password');
    } else {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final res =
            await AuthService().login(username: username, password: password);

        if (res is Auth) {
          await authProvider.handleLoginSuccess({
            'access_token': res.accessToken,
            'refresh_token': res.refreshToken,
            'roles': res.roles
          });
        }
      } catch (e) {
        toast.error('An error occurred during login $e');
      }
    }
  }

  void _setUsername(String value) {
    setState(() {
      username = value;
    });
  }

  void _setPassword(String value) {
    setState(() {
      password = value;
    });
  }

  @override
  void initState() {
    super.initState();
    toast = ToastNotification(fToast.init(context));
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),

              Text(
                'Login',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              SizedBox(height: 30),

              TextField(
                controller: _usernameController, // Add controller
                onChanged: _setUsername,
                decoration: InputDecoration(
                  labelText: 'User name',
                  prefixIcon: Icon(Icons.person, color: Colors.blue),
                  suffixIcon: IconButton(
                    // Add clear button
                    icon: Icon(Icons.clear, color: Colors.blue),
                    onPressed: () {
                      _usernameController.clear();
                      _setUsername('');
                    },
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 15),

              TextField(
                controller: _passwordController, // Add controller
                obscureText: isObscure,
                onChanged: _setPassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock, color: Colors.blue),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        // Add clear button
                        icon: Icon(Icons.clear, color: Colors.blue),
                        onPressed: () {
                          _passwordController.clear();
                          _setPassword('');
                        },
                      ),
                      IconButton(
                        // Existing visibility toggle
                        icon: Icon(
                          isObscure ? Icons.visibility : Icons.visibility_off,
                          color: Colors.blue,
                        ),
                        onPressed: () {
                          setState(() {
                            isObscure = !isObscure;
                          });
                        },
                      ),
                    ],
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
              ),
              SizedBox(height: 20),

              // Rest of the code remains the same
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    padding: EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: login,
                  child: Text(
                    'Login',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?",
                      style: TextStyle(fontSize: 14)),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 14, color: Colors.blue),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
