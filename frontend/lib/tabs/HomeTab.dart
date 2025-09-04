import 'package:doctor_booking/screens/CoronaScreen.dart';
import 'package:doctor_booking/screens/doctorDetailPage.dart';
import 'package:doctor_booking/screens/logoutScreen.dart';
import 'package:doctor_booking/styles/colors.dart';
import 'package:doctor_booking/styles/styles.dart';
import 'package:flutter/material.dart';
import '../screens/chat_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Doctor {
  final int id;
  final String name;
  final String specialization;
  final String imageUrl;

  Doctor(
      {required this.id,
      required this.name,
      required this.specialization,
      required this.imageUrl});

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['DoctorID'],
      name: json['Name'],
      specialization: json['Specialization'],
      imageUrl: json['Img'],
    );
  }
}

class HomeTab extends StatefulWidget {
  final void Function() onPressedScheduleCard;
  final String patientName;

  const HomeTab({
    Key? key,
    required this.onPressedScheduleCard,
    required this.patientName,
  }) : super(key: key);

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  List<Doctor> doctors = [];

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    final response = await http.get(Uri.parse(
        'https://advanced-app.netlify.app/.netlify/functions/api/doctors'));

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<Doctor> fetchedDoctors =
          data.map((doctorData) => Doctor.fromJson(doctorData)).toList();

      setState(() {
        doctors = fetchedDoctors;
      });
    } else {
      throw Exception('Failed to fetch doctors');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: ListView(
          children: [
            SizedBox(
              height: 20,
            ),
            UserIntro(patientName: widget.patientName),
            SizedBox(
              height: 10,
            ),
            SearchInput(),
            SizedBox(
              height: 20,
            ),
            CategoryIcons(),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Appointment Today',
                  style: kTitleStyle,
                ),
                TextButton(
                  child: Text(
                    'See All',
                    style: TextStyle(
                      color: Color(MyColors.yellow01),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  onPressed: () {},
                )
              ],
            ),
            SizedBox(
              height: 20,
            ),
            AppointmentCard(
              onTap: widget.onPressedScheduleCard,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              'Top Doctor',
              style: TextStyle(
                color: Color(MyColors.header01),
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            for (var doctor in doctors)
              TopDoctorCard(
                img: doctor.imageUrl,
                doctorName: doctor.name,
                doctorTitle: doctor.specialization,
                doctor: doctor,
              )
          ],
        ),
      ),
    );
  }
}

class TopDoctorCard extends StatefulWidget {
  final Doctor doctor;
  final String img;
  final String doctorName;
  final String doctorTitle;

  TopDoctorCard({
    required this.doctor,
    required this.img,
    required this.doctorName,
    required this.doctorTitle,
  });

  @override
  State<TopDoctorCard> createState() => _TopDoctorCardState();
}

class _TopDoctorCardState extends State<TopDoctorCard> {
  void _navigateToDoctorDetail() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => DoctorDetailPage(doctor: widget.doctor)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 20),
      child: InkWell(
        onTap: _navigateToDoctorDetail, // Change here
        child: Row(
          children: [
            Container(
              color: Color(MyColors.grey01),
              child: Image(
                width: 100,
                image: AssetImage(widget.img),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.doctorName,
                  style: TextStyle(
                    color: Color(MyColors.header01),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.doctorTitle,
                  style: TextStyle(
                    color: Color(MyColors.grey02),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star,
                      color: Color(MyColors.yellow02),
                      size: 18,
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Text(
                      '4.0 - 50 Reviews',
                      style: TextStyle(color: Color(MyColors.grey02)),
                    )
                  ],
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class AppointmentCard extends StatelessWidget {
  final void Function() onTap;

  const AppointmentCard({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Color(MyColors.primary),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage: AssetImage('assets/doctor01.jpeg'),
                        ),
                        SizedBox(
                          width: 10,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Dr.Muhammed Syahid',
                                style: TextStyle(color: Colors.white)),
                            SizedBox(
                              height: 2,
                            ),
                            Text(
                              'Dental Specialist',
                              style: TextStyle(color: Color(MyColors.text01)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    ScheduleCard(),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 20),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: Color(MyColors.bg02),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 40),
          width: double.infinity,
          height: 10,
          decoration: BoxDecoration(
            color: Color(MyColors.bg03),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(10),
              bottomLeft: Radius.circular(10),
            ),
          ),
        ),
      ],
    );
  }
}

List<Map> categories = [
  {'icon': Icons.smart_toy, 'text': 'Health Bot'},
  {'icon': Icons.coronavirus, 'text': 'Covid 19'},
  {'icon': Icons.local_hospital, 'text': 'Hospital'},
  {'icon': Icons.car_rental, 'text': 'Ambulance'},
  {'icon': Icons.local_pharmacy, 'text': 'Pill'},
];

class CategoryIcons extends StatelessWidget {
  const CategoryIcons({
    Key? key,
  }) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var category in categories)
          CategoryIcon(
            icon: category['icon'],
            text: category['text'],
          ),
      ],
    );
  }
}

class ScheduleCard extends StatelessWidget {
  const ScheduleCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Color(MyColors.bg01),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: const [
          Icon(
            Icons.calendar_today,
            color: Colors.white,
            size: 15,
          ),
          SizedBox(
            width: 5,
          ),
          Text(
            'Mon, July 29',
            style: TextStyle(color: Colors.white),
          ),
          SizedBox(
            width: 20,
          ),
          Icon(
            Icons.access_alarm,
            color: Colors.white,
            size: 17,
          ),
          SizedBox(
            width: 5,
          ),
          Flexible(
            child: Text(
              '11:00 ~ 12:10',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String text;

  CategoryIcon({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Color(MyColors.bg01),
      onTap: () {
        if (text == 'Health Bot') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatScreen(),
            ),
          );
        } else if (text == 'Covid 19') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CovidDescriptionPage(),
            ),
          );
        }
        // Add navigation for other categories if needed
      },
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Color(MyColors.bg),
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                icon,
                color: Color(MyColors.primary),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              text,
              style: TextStyle(
                color: Color(MyColors.primary),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SearchInput extends StatelessWidget {
  const SearchInput({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(MyColors.bg),
        borderRadius: BorderRadius.circular(5),
      ),
      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: Icon(
              Icons.search,
              color: Color(MyColors.purple02),
            ),
          ),
          const SizedBox(
            width: 15,
          ),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Search a doctor or health issue',
                hintStyle: TextStyle(
                    fontSize: 13,
                    color: Color(MyColors.purple01),
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserIntro extends StatefulWidget {
  final String patientName;
  const UserIntro({Key? key, required this.patientName}) : super(key: key);

  @override
  State<UserIntro> createState() => _UserIntroState();
}

class _UserIntroState extends State<UserIntro> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '${widget.patientName} 👋',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        InkWell(
          child: CircleAvatar(
            backgroundImage: AssetImage('assets/image.png'),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LogoutScreen(),
              ),
            );
          },
        )
      ],
    );
  }
}









// previous one:->************************************
// import 'package:doctor_booking/styles/colors.dart';
// import 'package:doctor_booking/styles/styles.dart';
// import 'package:flutter/material.dart';

// List<Map> doctors = [
//   {
//     'img': 'assets/doctor02.png',
//     'doctorName': 'Dr. Gardner Pearson',
//     'doctorTitle': 'Heart Specialist'
//   },
//   {
//     'img': 'assets/doctor03.jpeg',
//     'doctorName': 'Dr. Rosa Williamson',
//     'doctorTitle': 'Skin Specialist'
//   },
//   {
//     'img': 'assets/doctor02.png',
//     'doctorName': 'Dr. Gardner Pearson',
//     'doctorTitle': 'Heart Specialist'
//   },
//   {
//     'img': 'assets/doctor03.jpeg',
//     'doctorName': 'Dr. Rosa Williamson',
//     'doctorTitle': 'Skin Specialist'
//   }
// ];

// class HomeTab extends StatelessWidget {
//   final void Function() onPressedScheduleCard;

//   const HomeTab({
//     Key? key,
//     required this.onPressedScheduleCard,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () => FocusScope.of(context).unfocus(),
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 30),
//         child: ListView(
//           children: [
//             SizedBox(
//               height: 20,
//             ),
//             UserIntro(),
//             SizedBox(
//               height: 10,
//             ),
//             SearchInput(),
//             SizedBox(
//               height: 20,
//             ),
//             CategoryIcons(),
//             SizedBox(
//               height: 20,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   'Appointment Today',
//                   style: kTitleStyle,
//                 ),
//                 TextButton(
//                   child: Text(
//                     'See All',
//                     style: TextStyle(
//                       color: Color(MyColors.yellow01),
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   onPressed: () {},
//                 )
//               ],
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             AppointmentCard(
//               onTap: onPressedScheduleCard,
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             Text(
//               'Top Doctor',
//               style: TextStyle(
//                 color: Color(MyColors.header01),
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//             SizedBox(
//               height: 20,
//             ),
//             for (var doctor in doctors)
//               TopDoctorCard(
//                 img: doctor['img'],
//                 doctorName: doctor['doctorName'],
//                 doctorTitle: doctor['doctorTitle'],
//               )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class TopDoctorCard extends StatelessWidget {
//   String img;
//   String doctorName;
//   String doctorTitle;

//   TopDoctorCard({
//     required this.img,
//     required this.doctorName,
//     required this.doctorTitle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       margin: EdgeInsets.only(bottom: 20),
//       child: InkWell(
//         onTap: () {
//           Navigator.pushNamed(context, '/detail');
//         },
//         child: Row(
//           children: [
//             Container(
//               color: Color(MyColors.grey01),
//               child: Image(
//                 width: 100,
//                 image: AssetImage(img),
//               ),
//             ),
//             SizedBox(
//               width: 10,
//             ),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   doctorName,
//                   style: TextStyle(
//                     color: Color(MyColors.header01),
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Text(
//                   doctorTitle,
//                   style: TextStyle(
//                     color: Color(MyColors.grey02),
//                     fontSize: 12,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(
//                   height: 5,
//                 ),
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Icon(
//                       Icons.star,
//                       color: Color(MyColors.yellow02),
//                       size: 18,
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Text(
//                       '4.0 - 50 Reviews',
//                       style: TextStyle(color: Color(MyColors.grey02)),
//                     )
//                   ],
//                 )
//               ],
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

// class AppointmentCard extends StatelessWidget {
//   final void Function() onTap;

//   const AppointmentCard({
//     Key? key,
//     required this.onTap,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: Color(MyColors.primary),
//             borderRadius: BorderRadius.circular(10),
//           ),
//           child: Material(
//             color: Colors.transparent,
//             child: InkWell(
//               onTap: onTap,
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     Row(
//                       children: [
//                         CircleAvatar(
//                           backgroundImage: AssetImage('assets/doctor01.jpeg'),
//                         ),
//                         SizedBox(
//                           width: 10,
//                         ),
//                         Column(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text('Dr.Muhammed Syahid',
//                                 style: TextStyle(color: Colors.white)),
//                             SizedBox(
//                               height: 2,
//                             ),
//                             Text(
//                               'Dental Specialist',
//                               style: TextStyle(color: Color(MyColors.text01)),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 20,
//                     ),
//                     ScheduleCard(),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 20),
//           width: double.infinity,
//           height: 10,
//           decoration: BoxDecoration(
//             color: Color(MyColors.bg02),
//             borderRadius: BorderRadius.only(
//               bottomRight: Radius.circular(10),
//               bottomLeft: Radius.circular(10),
//             ),
//           ),
//         ),
//         Container(
//           margin: EdgeInsets.symmetric(horizontal: 40),
//           width: double.infinity,
//           height: 10,
//           decoration: BoxDecoration(
//             color: Color(MyColors.bg03),
//             borderRadius: BorderRadius.only(
//               bottomRight: Radius.circular(10),
//               bottomLeft: Radius.circular(10),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

// List<Map> categories = [
//   {'icon': Icons.coronavirus, 'text': 'Covid 19'},
//   {'icon': Icons.local_hospital, 'text': 'Hospital'},
//   {'icon': Icons.car_rental, 'text': 'Ambulance'},
//   {'icon': Icons.local_pharmacy, 'text': 'Pill'},
// ];

// class CategoryIcons extends StatelessWidget {
//   const CategoryIcons({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         for (var category in categories)
//           CategoryIcon(
//             icon: category['icon'],
//             text: category['text'],
//           ),
//       ],
//     );
//   }
// }

// class ScheduleCard extends StatelessWidget {
//   const ScheduleCard({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: Color(MyColors.bg01),
//         borderRadius: BorderRadius.circular(10),
//       ),
//       width: double.infinity,
//       padding: EdgeInsets.all(20),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: const [
//           Icon(
//             Icons.calendar_today,
//             color: Colors.white,
//             size: 15,
//           ),
//           SizedBox(
//             width: 5,
//           ),
//           Text(
//             'Mon, July 29',
//             style: TextStyle(color: Colors.white),
//           ),
//           SizedBox(
//             width: 20,
//           ),
//           Icon(
//             Icons.access_alarm,
//             color: Colors.white,
//             size: 17,
//           ),
//           SizedBox(
//             width: 5,
//           ),
//           Flexible(
//             child: Text(
//               '11:00 ~ 12:10',
//               style: TextStyle(color: Colors.white),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class CategoryIcon extends StatelessWidget {
//   IconData icon;
//   String text;

//   CategoryIcon({
//     required this.icon,
//     required this.text,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return InkWell(
//       splashColor: Color(MyColors.bg01),
//       onTap: () {},
//       child: Padding(
//         padding: const EdgeInsets.all(4.0),
//         child: Column(
//           children: [
//             Container(
//               width: 50,
//               height: 50,
//               decoration: BoxDecoration(
//                 color: Color(MyColors.bg),
//                 borderRadius: BorderRadius.circular(50),
//               ),
//               child: Icon(
//                 icon,
//                 color: Color(MyColors.primary),
//               ),
//             ),
//             SizedBox(
//               height: 10,
//             ),
//             Text(
//               text,
//               style: TextStyle(
//                 color: Color(MyColors.primary),
//                 fontSize: 12,
//                 fontWeight: FontWeight.w600,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class SearchInput extends StatelessWidget {
//   const SearchInput({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       decoration: BoxDecoration(
//         color: Color(MyColors.bg),
//         borderRadius: BorderRadius.circular(5),
//       ),
//       padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.only(top: 3),
//             child: Icon(
//               Icons.search,
//               color: Color(MyColors.purple02),
//             ),
//           ),
//           const SizedBox(
//             width: 15,
//           ),
//           Expanded(
//             child: TextField(
//               decoration: InputDecoration(
//                 border: InputBorder.none,
//                 hintText: 'Search a doctor or health issue',
//                 hintStyle: TextStyle(
//                     fontSize: 13,
//                     color: Color(MyColors.purple01),
//                     fontWeight: FontWeight.w700),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class UserIntro extends StatelessWidget {
//   const UserIntro({
//     Key? key,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: const [
//             Text(
//               'Hello',
//               style: TextStyle(fontWeight: FontWeight.w500),
//             ),
//             Text(
//               'Brad King 👋',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//             ),
//           ],
//         ),
//         const CircleAvatar(
//           backgroundImage: AssetImage('assets/person.jpeg'),
//         )
//       ],
//     );
//   }
// }







