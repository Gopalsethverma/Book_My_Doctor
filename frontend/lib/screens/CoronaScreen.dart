import 'package:flutter/material.dart';

class CovidDescriptionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('COVID-19 Information'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Symptoms',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Fever\n2. Dry cough\n3. Fatigue\n4. Shortness of breath\n5. Sore throat\n6. Loss of taste or smell\n7. Body aches\n8. Headache\n9. Chills\n10. Congestion or runny nose\n11. Nausea or vomiting\n12. Diarrhea',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Precautions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '1. Wear a mask\n2. Wash hands frequently\n3. Maintain social distance\n4. Avoid touching face\n5. Cover mouth and nose when coughing or sneezing\n6. Clean and disinfect frequently touched surfaces\n7. Stay home if feeling unwell\n8. Get vaccinated when eligible\n9. Follow guidelines from health authorities',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Other Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'COVID-19 is caused by the SARS-CoV-2 virus. It primarily spreads through respiratory droplets when an infected person talks, coughs, or sneezes. The virus can also spread by touching surfaces contaminated with the virus and then touching the face. Most people with COVID-19 have mild to moderate symptoms and recover without requiring special treatment. However, older adults and those with underlying medical conditions are at higher risk of developing severe illness.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
