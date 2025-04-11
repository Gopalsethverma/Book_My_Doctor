import 'dart:async';

import 'package:doctor_booking/tabs/HomeTab.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BookingPage extends StatefulWidget {
  final int doctorId;
  final Doctor doctor;
  final String patientId;

  BookingPage(
      {required this.doctorId, required this.doctor, required this.patientId});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  List<Map<String, dynamic>> availableSlots = [];
  DateTime? selectedDateTime;

  @override
  void initState() {
    super.initState();
    fetchAvailableSlots();
  }

  Future<void> fetchAvailableSlots() async {
    try {
      final response = await http
          .get(Uri.parse('https:/your_api/available-slots/${widget.doctorId}'));

      if (response.statusCode == 200) {
        final List<dynamic> slotsJson = json.decode(response.body);
        setState(() {
          availableSlots =
              slotsJson.map((slot) => slot as Map<String, dynamic>).toList();
        });
      } else {
        print('Failed to fetch available slots: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching available slots: $e');
    }
  }

  List<Map<String, dynamic>> getUpcomingSlots() {
    final now = DateTime.now();
    return availableSlots.where((slot) {
      final availableDate = parseDate(slot['AvailableDate']);
      final availableTime = parseTime(slot['AvailableTime']);
      final slotDateTime = DateTime(
        availableDate.year,
        availableDate.month,
        availableDate.day,
        availableTime.hour,
        availableTime.minute,
      );
      return slotDateTime.isAfter(now);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Appointment'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButtonFormField<DateTime>(
              value: selectedDateTime,
              onChanged: (DateTime? value) {
                setState(() {
                  selectedDateTime = value;
                });
              },
              items: getUpcomingSlots().map<DropdownMenuItem<DateTime>>((slot) {
                final availableDate = parseDate(slot['AvailableDate']);
                final availableTime = parseTime(slot['AvailableTime']);
                return DropdownMenuItem<DateTime>(
                  value: DateTime(
                    availableDate.year,
                    availableDate.month,
                    availableDate.day,
                    availableTime.hour,
                    availableTime.minute,
                  ),
                  child: Text(
                    '${DateFormat.yMMMd().format(availableDate)} ${DateFormat.jm().format(availableTime)}',
                  ),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Select Date and Time',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedDateTime != null) {
                  bookAppointment();
                }
              },
              child: Text('Book Appointment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> bookAppointment() async {
    try {
      final response = await http.post(
        Uri.parse('https:/your_api//appointments'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'DoctorID': widget.doctorId,
          'PatientID': widget.patientId,
          'AppointmentDate': DateFormat('yyyy-MM-dd').format(selectedDateTime!),
          'AppointmentTime': DateFormat('HH:mm:ss').format(selectedDateTime!),
          'Status': 'Upcoming',
        }),
      );

      if (response.statusCode == 201) {
        print('Appointment booked successfully');
        // Navigate to success screen or handle accordingly
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        );
      } else {
        print('Failed to book appointment: ${response.statusCode}');
        // Handle error
      }
    } catch (e) {
      print('Error booking appointment: $e');
    }
  }

  // Parse ISO 8601 formatted date string
  DateTime parseDate(String dateString) {
    try {
      // Remove the 'Z' character at the end of the string
      dateString = dateString.replaceAll('Z', '');
      // Parse the date string
      return DateTime.parse(dateString);
    } catch (e) {
      print('Error parsing date: $e');
    }
    return DateTime.now(); // Return current date if parsing fails
  }

  // Parse ISO 8601 formatted time string
  DateTime parseTime(String timeString) {
    try {
      // Parse the time string
      return DateFormat('HH:mm:ss').parse(timeString);
    } catch (e) {
      print('Error parsing time: $e');
    }
    return DateTime.now(); // Return current time if parsing fails
  }
}

class ConfirmationScreen extends StatefulWidget {
  @override
  _ConfirmationScreenState createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  @override
  void initState() {
    super.initState();
    // Start a timer to navigate back to the previous screen after 3 seconds
    Timer(Duration(seconds: 3), () {
      Navigator.of(context).pop(); // Pop the ConfirmationScreen
      Navigator.of(context).pop(); // Pop the BookingPage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 64),
            SizedBox(height: 16),
            Text(
              'Your appointment is confirmed!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
