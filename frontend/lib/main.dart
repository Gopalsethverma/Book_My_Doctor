//Original:***************************************************
import 'package:doctor_booking/firebase_options.dart';
import 'package:doctor_booking/routes/router.dart';
import 'package:doctor_booking/utils/textscale.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: fixTextScale,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: routes,
    );
  }
}

// //Original:***************************************************

// import 'package:doctor_booking/routes/router.dart';
// import 'package:doctor_booking/utils/textscale.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       builder: fixTextScale,
//       debugShowCheckedModeBanner: false,
//       initialRoute: '/',
//       routes: routes,
//     );
//   }
// }

//form code->*******************************************
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class PatientDetailPage extends StatefulWidget {
//   @override
//   _PatientDetailPageState createState() => _PatientDetailPageState();
// }

// class _PatientDetailPageState extends State<PatientDetailPage> {
//   final _formKey = GlobalKey<FormState>();
//   TextEditingController _mobileController = TextEditingController();
//   TextEditingController _nameController = TextEditingController();
//   String? _selectedGender;
//   int? _selectedAge;
//   DateTime? _selectedAppointmentDateTime;

//   // Sample list of appointment date and time options
//   List<DateTime> _appointmentDateTimeOptions = [
//     DateTime.now().add(Duration(days: 1, hours: 9)),
//     DateTime.now().add(Duration(days: 1, hours: 10)),
//     DateTime.now().add(Duration(days: 2, hours: 11)),
//     DateTime.now().add(Duration(days: 3, hours: 13)),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Patient Details'),
//       ),
//       body: Container(
//         decoration: BoxDecoration(
//           border: Border.all(color: Colors.blue),
//           borderRadius: BorderRadius.circular(10.0),
//         ),
//         padding: EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 child: TextFormField(
//                   controller: _mobileController,
//                   keyboardType: TextInputType.phone,
//                   maxLength: 10,
//                   decoration: InputDecoration(
//                     labelText: 'Mobile Number',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                   ),
//                   validator: (value) {
//                     if (value!.isEmpty || value.length != 10) {
//                       return 'Please enter a valid mobile number';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 child: TextFormField(
//                   controller: _nameController,
//                   decoration: InputDecoration(
//                     labelText: 'Name',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                   ),
//                   validator: (value) {
//                     if (value!.isEmpty) {
//                       return 'Please enter a name';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 10.0),
//                 child: DropdownButtonFormField<int>(
//                   value: _selectedAge,
//                   items:
//                       List.generate(100, (index) => index + 1).map((int value) {
//                     return DropdownMenuItem<int>(
//                       value: value,
//                       child: Text(value.toString()),
//                     );
//                   }).toList(),
//                   onChanged: (int? newValue) {
//                     setState(() {
//                       _selectedAge = newValue;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Age',
//                     border: InputBorder.none,
//                   ),
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select an age';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 10.0),
//                 child: DropdownButtonFormField<DateTime>(
//                   value: _selectedAppointmentDateTime,
//                   items: _appointmentDateTimeOptions.map((DateTime dateTime) {
//                     return DropdownMenuItem<DateTime>(
//                       value: dateTime,
//                       child: Text(
//                         '${DateFormat('yyyy-MM-dd hh:mm a').format(dateTime)}',
//                       ),
//                     );
//                   }).toList(),
//                   onChanged: (DateTime? newValue) {
//                     setState(() {
//                       _selectedAppointmentDateTime = newValue;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Appointment Date and Time',
//                     border: InputBorder.none,
//                   ),
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select an appointment date and time';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(height: 10),
//               Container(
//                 decoration: BoxDecoration(
//                   border: Border.all(color: Colors.blue),
//                   borderRadius: BorderRadius.circular(5.0),
//                 ),
//                 child: DropdownButtonFormField<String>(
//                   value: _selectedGender,
//                   items: ['Male', 'Female', 'Other'].map((String value) {
//                     return DropdownMenuItem<String>(
//                       value: value,
//                       child: Text(value),
//                     );
//                   }).toList(),
//                   onChanged: (String? newValue) {
//                     setState(() {
//                       _selectedGender = newValue;
//                     });
//                   },
//                   decoration: InputDecoration(
//                     labelText: 'Gender',
//                     border: InputBorder.none,
//                     contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
//                   ),
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select a gender';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//               SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () {
//                   if (_formKey.currentState!.validate()) {
//                     // Form is validated, submit data or perform actions here
//                     print('Mobile Number: ${_mobileController.text}');
//                     print('Name: ${_nameController.text}');
//                     print('Age: $_selectedAge');
//                     print(
//                         'Appointment Date and Time: $_selectedAppointmentDateTime');
//                     print('Gender: $_selectedGender');
//                   }
//                 },
//                 child: Text('Submit for Booking'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// void main() {
//   runApp(MaterialApp(
//     home: PatientDetailPage(),
//   ));
// }
