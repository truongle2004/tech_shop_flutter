import 'package:flutter/material.dart';

import 'login_page.dart';

class RegisterPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Form(
            child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Register',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'User name',
                  border: OutlineInputBorder(),
                  prefix: Icon(Icons.person)),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                  prefix: Icon(Icons.email)),
            ),
            SizedBox(
              height: 20,
            ),
            TextFormField(
              decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  prefix: Icon(Icons.password)),
            ),
            SizedBox(height: 20, width: double.infinity),
            ElevatedButton(
              onPressed: () => print('register'),
              child: Text('register'),
              style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15)),
            ),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Already have an account?'),
              TextButton(
                child: Text('Login'),
                onPressed: () => Navigator.push(
                    context, MaterialPageRoute(builder: (_) => LoginPage())),
              ),
            ])
          ],
        )),
      ),
    ));
  }
}
