import 'dart:async';

import 'package:doctor_booking/tabs/HomeTab.dart';
import 'package:doctor_booking/services/razorpay_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

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
  late RazorpayService _razorpayService;
  bool _isProcessingPayment = false;

  @override
  void initState() {
    super.initState();
    fetchAvailableSlots();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpayService = RazorpayService();
    _razorpayService.init();

    _razorpayService.onPaymentSuccess = (PaymentSuccessResponse response) {
      _handlePaymentSuccess(response);
    };

    _razorpayService.onPaymentFailure = (PaymentFailureResponse response) {
      _handlePaymentFailure(response);
    };
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> fetchAvailableSlots() async {
    try {
      final response = await http.get(Uri.parse(
          'https://advanced-app.netlify.app/.netlify/functions/api/available-slots/${widget.doctorId}'));

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
            // Payment amount display
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking Fee:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '₹${RazorpayService.bookingAmount}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7165D6),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isProcessingPayment
                  ? null
                  : () {
                      if (selectedDateTime != null) {
                        _processPayment();
                      } else {
                        _showSnackBar(
                            'Please select a date and time for your appointment');
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF7165D6),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: _isProcessingPayment
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text('Processing...'),
                      ],
                    )
                  : Text(
                      'Pay ₹${RazorpayService.bookingAmount} & Book Appointment',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    setState(() {
      _isProcessingPayment = true;
    });

    _razorpayService.openCheckout(
      doctorName: widget.doctor.name,
      patientName: 'Patient', // You can get this from user profile
      appointmentDate: DateFormat('yyyy-MM-dd').format(selectedDateTime!),
      appointmentTime: DateFormat('HH:mm:ss').format(selectedDateTime!),
    );
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    setState(() {
      _isProcessingPayment = false;
    });

    print('Payment successful: ${response.paymentId}');
    _bookAppointmentAfterPayment(response.paymentId!);
  }

  void _handlePaymentFailure(PaymentFailureResponse response) {
    setState(() {
      _isProcessingPayment = false;
    });

    print('Payment failed: ${response.code} - ${response.message}');
    _showSnackBar('Payment failed. Please try again.');
  }

  Future<void> _bookAppointmentAfterPayment(String paymentId) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://advanced-app.netlify.app/.netlify/functions/api//appointments'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'DoctorID': widget.doctorId,
          'PatientID': widget.patientId,
          'AppointmentDate': DateFormat('yyyy-MM-dd').format(selectedDateTime!),
          'AppointmentTime': DateFormat('HH:mm:ss').format(selectedDateTime!),
          'Status': 'Confirmed',
          'PaymentId': paymentId,
          'PaymentAmount': RazorpayService.bookingAmount,
        }),
      );

      if (response.statusCode == 201) {
        print('Appointment booked successfully after payment');
        // Navigate to success screen
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        );
      } else {
        print('Failed to book appointment: ${response.statusCode}');
        _showSnackBar(
            'Payment successful but booking failed. Please contact support.');
      }
    } catch (e) {
      print('Error booking appointment: $e');
      _showSnackBar(
          'Payment successful but booking failed. Please contact support.');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
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
    // Start a timer to navigate back to the previous screen after 5 seconds
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pop(); // Pop the ConfirmationScreen
      Navigator.of(context).pop(); // Pop the BookingPage
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking Confirmed'),
        backgroundColor: Color(0xFF7165D6),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 80),
              SizedBox(height: 24),
              Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Your appointment has been confirmed',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'Booking Details',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text('Payment Amount: ₹${RazorpayService.bookingAmount}'),
                    Text('Status: Confirmed'),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Text(
                'You will be redirected automatically...',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
