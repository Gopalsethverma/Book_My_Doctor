import 'package:doctor_booking/screens/bookingPage.dart';
import 'package:doctor_booking/tabs/HomeTab.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DoctorDetailPage extends StatelessWidget {
  final Doctor doctor;

  const DoctorDetailPage({super.key, required this.doctor});

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display the image of the doctor
            Center(
              child: Image.asset(
                doctor.imageUrl,
                width: 200, // Adjust the width as needed
                height: 200, // Adjust the height as needed
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 16.0),
            // Display the doctor's name
            Text(
              'Name: ${doctor.name}',
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8.0),
            // Display the doctor's specialization
            Text(
              'Specialization: ${doctor.specialization}',
              style: const TextStyle(fontSize: 18.0),
            ),
            const SizedBox(height: 24.0),
            // Add a button to book appointment
            Padding(
              padding: const EdgeInsets.all(15),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BookingPage(
                          doctorId: doctor.id,
                          doctor: doctor,
                          patientId: user!.uid),
                    ),
                  );
                },
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7165D6),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "Book Appointment",
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
          ],
        ),
      ),
    );
  }
}
