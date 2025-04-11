import 'dart:convert';

import 'package:doctor_booking/screens/home.dart';
import 'package:doctor_booking/screens/signupScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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
    // Check if user is already logged in
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _fetchPatientDetails(user.uid);
    }
  }

  Future<void> _fetchPatientDetails(String patientId) async {
    try {
      final response =
          await http.get(Uri.parse('https:/your_api/patients/$patientId'));

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
      // Show CircularProgressIndicator
      showDialog(
        context: context,
        barrierDismissible: false, // prevent user from dismissing dialog
        builder: (BuildContext context) {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Fetch patient details from the server
      String patientId = userCredential.user!.uid;
      final response =
          await http.get(Uri.parse('https:/your_api/patients/$patientId'));

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
    } on FirebaseAuthException catch (e) {
      // Hide CircularProgressIndicator
      Navigator.pop(context);

      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    } catch (e) {
      // Hide CircularProgressIndicator
      Navigator.pop(context);
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
