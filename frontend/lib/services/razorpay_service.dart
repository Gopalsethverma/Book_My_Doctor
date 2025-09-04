import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:flutter/material.dart';

class RazorpayService {
  static const String _testKeyId = 'rzp_test_pi2fEEfhC66GKs';
  static const int _bookingAmount = 100; // 100 Rs for doctor booking

  late Razorpay _razorpay;

  // Payment success callback
  Function(PaymentSuccessResponse)? onPaymentSuccess;

  // Payment failure callback
  Function(PaymentFailureResponse)? onPaymentFailure;

  // Payment external wallet callback
  Function(ExternalWalletResponse)? onExternalWallet;

  void init() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Success: ${response.paymentId}');
    if (onPaymentSuccess != null) {
      onPaymentSuccess!(response);
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Error: ${response.code} - ${response.message}');
    if (onPaymentFailure != null) {
      onPaymentFailure!(response);
    }
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet: ${response.walletName}');
    if (onExternalWallet != null) {
      onExternalWallet!(response);
    }
  }

  void openCheckout({
    required String doctorName,
    required String patientName,
    required String appointmentDate,
    required String appointmentTime,
  }) {
    var options = {
      'key': _testKeyId,
      'amount': _bookingAmount * 100, // Amount in paise (100 Rs = 10000 paise)
      'name': 'Book My Doctor',
      'description': 'Doctor Appointment Booking',
      'prefill': {
        'contact': '',
        'email': '',
        'name': patientName,
      },
      'notes': {
        'doctor_name': doctorName,
        'appointment_date': appointmentDate,
        'appointment_time': appointmentTime,
        'booking_type': 'doctor_appointment',
      },
      'theme': {
        'color': '#7165D6', // Using the app's primary color
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay checkout: $e');
    }
  }

  void dispose() {
    _razorpay.clear();
  }

  static int get bookingAmount => _bookingAmount;
}
