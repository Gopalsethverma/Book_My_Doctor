import 'dart:convert';

import 'package:doctor_booking/screens/home.dart';
import 'package:doctor_booking/screens/signupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class loginScreen extends StatefulWidget {
  @override
  State<loginScreen> createState() => _loginScreenState();
}

class _loginScreenState extends State<loginScreen> {
  bool passToggle = true;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('userId');
    int? loginTimestamp = prefs.getInt('loginTimestamp');
    if (userId != null && loginTimestamp != null) {
      // Check if session is still valid (within 30 days)
      final now = DateTime.now().millisecondsSinceEpoch;
      final thirtyDaysMs = 30 * 24 * 60 * 60 * 1000;
      if (now - loginTimestamp < thirtyDaysMs) {
        _fetchPatientDetails(userId);
      } else {
        // Session expired, clear it
        await prefs.remove('userId');
        await prefs.remove('loginTimestamp');
      }
    }
  }

  Future<void> _fetchPatientDetails(String patientId) async {
    try {
      final response = await http.get(Uri.parse(
          'https://advanced-app.netlify.app/.netlify/functions/api/patients/$patientId'));

      if (response.statusCode == 200) {
        // Extract patient name from the response
        Map<String, dynamic> patientData = json.decode(response.body);
        String patientName = patientData['Name'];

        // Navigate to home screen with patient name
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Home(patientName: patientName),
          ),
        );
      } else {
        print('Failed to fetch patient details: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching patient details: $e');
    }
  }

  Future<void> _signIn() async {
    try {
      // Show loader
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Center(child: CircularProgressIndicator());
        },
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Fetch patient details from the server
      String patientId = userCredential.user!.uid;
      final response = await http.get(Uri.parse(
          'https://advanced-app.netlify.app/.netlify/functions/api/patients/$patientId'));

      String patientName = '';
      if (response.statusCode == 200) {
        // Extract patient name from the response
        Map<String, dynamic> patientData = json.decode(response.body);
        patientName = patientData['Name'] ?? '';
      } else {
        patientName = userCredential.user?.email ?? 'User';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch patient details.')),
        );
      }
      // Save session (userId and timestamp)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', patientId);
      await prefs.setInt(
          'loginTimestamp', DateTime.now().millisecondsSinceEpoch);
      // Hide loader before navigation
      Navigator.pop(context);
      // Navigate to home screen with patient name (fallback if needed)
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Home(patientName: patientName),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Hide loader on error
      Navigator.pop(context);
      String errorMessage = '';
      if (e.code == 'user-not-found') {
        errorMessage = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        errorMessage = 'Wrong password provided for that user.';
      } else {
        errorMessage = 'Login failed. Please check your credentials.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      // Hide loader on error
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Image.asset(
                  "assets/doctors.png",
                  height: 150, // Adjusted height
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Your Email",
                    prefixIcon: Icon(Icons.email_rounded),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: passwordController,
                  obscureText: passToggle,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Password",
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          passToggle = !passToggle;
                        });
                      },
                      icon: Icon(
                        passToggle ? Icons.visibility_off : Icons.visibility,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(15),
                child: InkWell(
                  onTap: _signIn,
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: Color(0xFF7165D6),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        "Log In",
                        style: TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account?",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SignUpScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7165D6),
                      ),
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
