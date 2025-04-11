import 'package:doctor_booking/screens/home.dart';
import 'package:doctor_booking/screens/loginScreen.dart';
import 'package:flutter/material.dart';

Map<String, Widget Function(BuildContext)> routes = {
  '/': (context) => loginScreen(), //Home(),
  // '/detail': (context) => SliverDoctorDetail(),
};
