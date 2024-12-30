import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'blynk_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController =
      TextEditingController(); // Controller for username input
  final TextEditingController _passwordController =
      TextEditingController(); // Controller for password input

  void _attemptLogin() {
    String username =
        _usernameController.text.trim(); // Retrieve trimmed username
    String password =
        _passwordController.text.trim(); // Retrieve trimmed password

    BlynkService blynkService =
        BlynkService(username); // Initialize Blynk service with username

    if (username == "Flat-1" && password == "Flat-1") {
      // Check for Flat-1 credentials
      blynkService.logIn(); // Log in to Blynk service
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
              flatProfile: "Flat-1"), // Navigate to Flat-1 dashboard
        ),
      );
    } else if (username == "Flat-2" && password == "Flat-2") {
      // Check for Flat-2 credentials
      blynkService.logIn(); // Log in to Blynk service
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => DashboardScreen(
              flatProfile: "Flat-2"), // Navigate to Flat-2 dashboard
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Login Failed. Incorrect username or password.'), // Show error message
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.lightBlue.shade100, // Background color
              ),
            ),
          ),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                FlutterLogo(size: 100), // App logo
                SizedBox(height: 48),
                _buildTextField(
                  controller: _usernameController,
                  labelText: 'User Name',
                  icon: Icons.person,
                ),
                SizedBox(height: 24),
                _buildTextField(
                  controller: _passwordController,
                  labelText: 'Password',
                  icon: Icons.lock,
                  obscureText: true,
                ),
                SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: ElevatedButton(
                    onPressed: _attemptLogin, // Call login function
                    child: Text('LOG IN'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget for building text fields with common styling
  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.8),
          labelText: labelText,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
