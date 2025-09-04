import 'dart:convert';

import 'package:doctor_booking/styles/colors.dart';
import 'package:doctor_booking/styles/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Appointment {
  final int appointmentId;
  final String img;
  final String doctorName;
  final String specialization;
  final String reservedDate;
  final String reservedTime;
  final String status;

  Appointment({
    required this.appointmentId,
    required this.img,
    required this.doctorName,
    required this.specialization,
    required this.reservedDate,
    required this.reservedTime,
    required this.status,
  });
}

class ScheduleTab extends StatefulWidget {
  const ScheduleTab({Key? key}) : super(key: key);

  @override
  State<ScheduleTab> createState() => _ScheduleTabState();
}

enum FilterStatus { Upcoming, Complete, Cancelled }

class _ScheduleTabState extends State<ScheduleTab> {
  FilterStatus status = FilterStatus.Upcoming;
  Alignment _alignment = Alignment.centerLeft;
  List<Appointment> schedules = [];

  @override
  void initState() {
    super.initState();
    updateAppointments();
    fetchAppointments();
  }

  Future<void> updateAppointments() async {
    try {
      // Make an HTTP GET request to the server endpoint
      final response = await http.get(
        Uri.parse(
            'https://advanced-app.netlify.app/.netlify/functions/api/update-appointments'),
      );

      // Check if the request was successful
      if (response.statusCode == 200) {
        print('Appointments updated successfully');
      } else {
        // Handle the case where the request was not successful
        print('Failed to update appointments: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any errors that occur during the request
      print('Error updating appointments: $e');
    }
  }

  Future<void> fetchAppointments() async {
    User? user = FirebaseAuth.instance.currentUser;
    try {
      final response = await http.get(
        Uri.parse(
            'https://advanced-app.netlify.app/.netlify/functions/api/appointmentanddoctor/${user!.uid}'),
      );

      if (response.statusCode == 200) {
        final dynamic responseBody = json.decode(response.body);
        if (responseBody != null && responseBody is List) {
          final List<dynamic> appointmentsJson = responseBody;
          setState(() {
            schedules = appointmentsJson
                .map((schedules) => Appointment(
                      appointmentId: schedules['AppointmentID'],
                      img: schedules['Img'] ?? '',
                      doctorName: schedules['Name'] ?? '',
                      specialization: schedules['Specialization'] ?? '',
                      reservedDate: schedules['AppointmentDate'] ?? '',
                      reservedTime: schedules['AppointmentTime'] ?? '',
                      status: schedules['Status'] ?? '',
                    ))
                .toList();
          });
        } else {
          print('Response body is null or not a List');
        }
      } else {
        print('Failed to fetch appointments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching appointments: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Appointment> filteredSchedules = schedules.where((schedule) {
      return schedule.status == status.name;
    }).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(left: 30, top: 30, right: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Schedule',
              textAlign: TextAlign.center,
              style: kTitleStyle,
            ),
            const SizedBox(
              height: 20,
            ),
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(MyColors.bg),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      for (FilterStatus filterStatus in FilterStatus.values)
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                if (filterStatus == FilterStatus.Upcoming) {
                                  status = FilterStatus.Upcoming;
                                  _alignment = Alignment.centerLeft;
                                } else if (filterStatus ==
                                    FilterStatus.Complete) {
                                  status = FilterStatus.Complete;
                                  _alignment = Alignment.center;
                                } else if (filterStatus ==
                                    FilterStatus.Cancelled) {
                                  status = FilterStatus.Cancelled;
                                  _alignment = Alignment.centerRight;
                                }
                              });
                            },
                            child: Center(
                              child: Text(
                                filterStatus.name,
                                style: kFilterStyle,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: _alignment,
                  child: Container(
                    width: 100,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(MyColors.primary),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(
                      child: Text(
                        status.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: filteredSchedules.length,
                itemBuilder: (context, index) {
                  var _schedule = filteredSchedules[index];
                  bool isLastElement = index == filteredSchedules.length - 1;
                  return Card(
                    margin: !isLastElement
                        ? const EdgeInsets.only(bottom: 20)
                        : EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage('${_schedule.img}'),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _schedule.doctorName,
                                    style: TextStyle(
                                      color: Color(MyColors.header01),
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    _schedule.specialization,
                                    style: TextStyle(
                                      color: Color(MyColors.grey02),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          DateTimeCard(
                            date: _schedule.reservedDate,
                            time: _schedule.reservedTime,
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  child: const Text('Cancel'),
                                  onPressed: () {},
                                ),
                              ),
                              const SizedBox(
                                width: 20,
                              ),
                              // Expanded(
                              //   child: ElevatedButton(
                              //     child: const Text('Reschedule'),
                              //     onPressed: () => {},
                              //   ),
                              // )
                            ],
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DateTimeCard extends StatelessWidget {
  final String date;
  final String time;

  const DateTimeCard({
    Key? key,
    required this.date,
    required this.time,
  }) : super(key: key);
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

  DateTime parseTime(String timeString) {
    try {
      // Parse the time string
      return DateFormat('HH:mm:ss').parse(timeString);
    } catch (e) {
      print('Error parsing time: $e');
    }
    return DateTime.now(); // Return current time if parsing fails
  }

  @override
  Widget build(BuildContext context) {
    // Parse the date string
    final avDate = parseDate(date);
    final avTime = parseTime(time);
    // Format date and time strings
    String formattedDate = "${DateFormat.yMMMd().format(avDate)}";
    String formattedTime = "${DateFormat.jm().format(avTime)}";

    return Container(
      decoration: BoxDecoration(
        color: Color(MyColors.bg03),
        borderRadius: BorderRadius.circular(10),
      ),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                color: Color(MyColors.primary),
                size: 15,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                formattedDate,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(MyColors.primary),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Icon(
                Icons.access_alarm,
                color: Color(MyColors.primary),
                size: 17,
              ),
              const SizedBox(
                width: 5,
              ),
              Text(
                formattedTime,
                style: TextStyle(
                  color: Color(MyColors.primary),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
