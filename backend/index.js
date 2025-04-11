// const express = require('express');
// var mysql = require("mysql2");

// const app = express();
// app.use(express.json());

// const connection = mysql.createConnection(
//     {
//         host  : 'gopal123.mysql.database.azure.com',
//         user : 'Gopal123',
//         password : 'Ankit@123',
//         port : 3306,
//         database : 'hospital'
//     }
// );

// connection.connect((err)=>{
//     if(err)throw err;
//     console.log("db connected");
// });

// // Server for fetching appointments corresponding to a patient ID
// app.get('/appointments/:patientId', (req, res) => {
//   const patientId = req.params.patientId;
//   connection.query('SELECT * FROM Appointments WHERE PatientID = ?', [patientId], (err, results) => {
//     if (err) {
//       res.status(500).send('Error fetching appointments');
//     } else {
//       res.json(results);
//     }
//   });
// });

// // Server for fetching doctor details
// app.get('/doctors', (req, res) => {
//   connection.query('SELECT * FROM Doctors', (err, results) => {
//     if (err) {
//       res.status(500).send('Error fetching doctors');
//     } else {
//       res.json(results);
//     }
//   });
// });

// // Server for fetching available slots corresponding to a doctor ID
// app.get('/available-slots/:doctorId', (req, res) => {
//   const doctorId = req.params.doctorId;
//   connection.query('SELECT * FROM AvailableSlots WHERE DoctorID = ?', [doctorId], (err, results) => {
//     if (err) {
//       res.status(500).send('Error fetching available slots');
//     } else {
//       res.json(results);
//     }
//   });
// });

// // Server for executing the SQL update statement
// app.get('/update-appointments', (req, res) => {
//   connection.query('SET SQL_SAFE_UPDATES = 0', err => {
//     if (err) {
//       res.status(500).send('Error updating appointments');
//     } else {
//       connection.query(`
//         UPDATE Appointments
//         SET Status = 
//             CASE
//                 WHEN Status = 'Cancelled' THEN 'Cancelled'
//                 WHEN AppointmentDate > CURDATE() THEN 'Upcoming'
//                 WHEN AppointmentDate = CURDATE() AND AppointmentTime > CURTIME() THEN 'Upcoming'
//                 ELSE 'Complete'
//             END
//       `, err => {
//         if (err) {
//           res.status(500).send('Error updating appointments');
//         } else {
//           res.send('Appointments updated successfully');
//         }
//       });
//     }
//   });
// });

// // Server for inserting into the Appointments table
// app.post('/appointments', (req, res) => {
//   const { DoctorID, PatientID, AppointmentDate, AppointmentTime, Status } = req.body;
//   connection.query('INSERT INTO Appointments (DoctorID, PatientID, AppointmentDate, AppointmentTime, Status) VALUES (?, ?, ?, ?, ?)', [DoctorID, PatientID, AppointmentDate, AppointmentTime, Status], (err, result) => {
//     if (err) {
//       res.status(500).send('Error inserting appointment');
//     } else {
//       res.status(201).send('Appointment inserted successfully');
//     }
//   });
// });

// // Start server
// const PORT = process.env.PORT || 3000;
// app.listen(PORT, () => {
//   console.log(`Server is running on port ${PORT}`);
// });
