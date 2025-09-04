import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:doctor_booking/screens/loginScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogoutScreen extends StatelessWidget {
  Future<void> _signOut(BuildContext context) async {
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

      // Clear session data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      await prefs.remove('loginTimestamp');

      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => loginScreen()),
        (route) => false, // Prevents going back to the logout screen
      );
    } catch (e) {
      print("Error signing out: $e");
      // Hide CircularProgressIndicator in case of error
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Profile'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: InkWell(
            onTap: () => _signOut(
                context), // Wrap _signOut with an anonymous function to provide the context
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
                  "Log Out",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
