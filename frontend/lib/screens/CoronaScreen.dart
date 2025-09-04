import 'package:flutter/material.dart';

class CovidDescriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COVID-19 Information'),
        backgroundColor: Colors.blue.shade700,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.coronavirus,
                            color: Colors.redAccent, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Symptoms',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        Chip(label: Text('Fever')),
                        Chip(label: Text('Dry cough')),
                        Chip(label: Text('Fatigue')),
                        Chip(label: Text('Shortness of breath')),
                        Chip(label: Text('Sore throat')),
                        Chip(label: Text('Loss of taste or smell')),
                        Chip(label: Text('Body aches')),
                        Chip(label: Text('Headache')),
                        Chip(label: Text('Chills')),
                        Chip(label: Text('Congestion or runny nose')),
                        Chip(label: Text('Nausea or vomiting')),
                        Chip(label: Text('Diarrhea')),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.shield, color: Colors.green, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Precautions',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(
                          leading: Icon(Icons.masks, color: Colors.blue),
                          title: Text('Wear a mask'),
                        ),
                        ListTile(
                          leading: Icon(Icons.clean_hands, color: Colors.teal),
                          title: Text('Wash hands frequently'),
                        ),
                        ListTile(
                          leading:
                              Icon(Icons.social_distance, color: Colors.orange),
                          title: Text('Maintain social distance'),
                        ),
                        ListTile(
                          leading: Icon(Icons.face, color: Colors.purple),
                          title: Text('Avoid touching face'),
                        ),
                        ListTile(
                          leading: Icon(Icons.sanitizer, color: Colors.pink),
                          title: Text('Clean and disinfect surfaces'),
                        ),
                        ListTile(
                          leading: Icon(Icons.home, color: Colors.indigo),
                          title: Text('Stay home if feeling unwell'),
                        ),
                        ListTile(
                          leading: Icon(Icons.vaccines, color: Colors.green),
                          title: Text('Get vaccinated when eligible'),
                        ),
                        ListTile(
                          leading: Icon(Icons.info, color: Colors.grey),
                          title:
                              Text('Follow guidelines from health authorities'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 18),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Colors.blueAccent, size: 28),
                        SizedBox(width: 8),
                        Text(
                          'Other Information',
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    Text(
                      'COVID-19 is caused by the SARS-CoV-2 virus. It primarily spreads through respiratory droplets when an infected person talks, coughs, or sneezes. The virus can also spread by touching surfaces contaminated with the virus and then touching the face. Most people with COVID-19 have mild to moderate symptoms and recover without requiring special treatment. However, older adults and those with underlying medical conditions are at higher risk of developing severe illness.',
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
