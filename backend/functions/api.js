const express = require('express');
const serverless = require('serverless-http');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();
const router = express.Router();

app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(cors());

const connection = mysql.createConnection({
    
    host: 'username.mysql.database.azure.com',   // Replace with your host id
    user: 'username',                           // Replace with your username
    password: 'your_password',                  // Replace with your password
    port: port_number,                          // Replace with your port number 
    database: 'db_name'                         // Replace with your database name
    
    
});

connection.connect((err) => {
    if (err) throw err;
    console.log("db connected");
});

// Server for fetching appointments corresponding to a patient ID
router.get('/appointments/:patientId', (req, res) => {
    const patientId = req.params.patientId;
    connection.query('SELECT * FROM Appointments WHERE PatientID = ?', [patientId], (err, results) => {
        if (err) {
            res.status(500).send('Error fetching appointments');
        } else {
            res.json(results);
        }
    });
});
// Server for fetching patient details corresponding to a patient ID
router.get('/patients/:patientId', (req, res) => {
    const patientId = req.params.patientId;
    connection.query('SELECT * FROM Patients WHERE PatientID = ?', [patientId], (err, results) => {
        if (err) {
            res.status(500).send('Error fetching patient details');
        } else {
            if (results.length === 0) {
                res.status(404).send('Patient not found');
            } else {
                res.json(results[0]);
            }
        }
    });
});

// Server for fetching doctor details
router.get('/doctors', (req, res) => {
    connection.query('SELECT * FROM Doctors', (err, results) => {
        if (err) {
            res.status(500).send('Error fetching doctors');
        } else {
            res.json(results);
        }
    });
});

// Server for fetching available slots corresponding to a doctor ID
router.get('/available-slots/:doctorId', (req, res) => {
    const doctorId = req.params.doctorId;
    connection.query('SELECT * FROM AvailableSlots WHERE DoctorID = ? ORDER BY AvailableDate ASC, AvailableTime ASC', [doctorId], (err, results) => {
        if (err) {
            res.status(500).send('Error fetching available slots');
        } else {
            res.json(results);
        }
    });
});

router.get('/appointmentanddoctor/:patientId', (req, res) => {
    const patientId = req.params.patientId;
    const sql = `
        SELECT * FROM Appointments A
        JOIN Doctors D ON D.DoctorID = A.DoctorID
        WHERE PatientID = ?;
    `;
    connection.query(sql, [patientId], (err, results) => {
        if (err) {
            console.error('Error executing SQL query:', err);
            res.status(500).send('Error executing SQL query');
            return;
        }
        res.json(results);
    });
});

// Server for executing the SQL update statement
router.get('/update-appointments', (req, res) => {
    connection.query('SET SQL_SAFE_UPDATES = 0', err => {
        if (err) {
            res.status(500).send('Error updating appointments');
        } else {
            connection.query(`
                UPDATE Appointments
                SET Status = 
                    CASE
                        WHEN Status = 'Cancelled' THEN 'Cancelled'
                        WHEN AppointmentDate > CURDATE() THEN 'Upcoming'
                        WHEN AppointmentDate = CURDATE() AND AppointmentTime > CURTIME() THEN 'Upcoming'
                        ELSE 'Complete'
                    END
            `, err => {
                if (err) {
                    res.status(500).send('Error updating appointments');
                } else {
                    res.send('Appointments updated successfully');
                }
            });
        }
    });
});

// Server for inserting into the Patients table
router.post('/patients', (req, res) => {
    const { PatientID, Name, Age, Gender } = req.body;
    connection.query('INSERT INTO Patients (PatientID, Name, Age, Gender) VALUES (?, ?, ?, ?)', [PatientID, Name, Age, Gender], (err, result) => {
        if (err) {
            res.status(500).send('Error inserting patient');
        } else {
            res.status(201).send('Patient inserted successfully');
        }
    });
});
// Server for inserting into the Appointments table
router.post('/appointments', (req, res) => {
    const { DoctorID, PatientID, AppointmentDate, AppointmentTime, Status } = req.body;
    connection.query('INSERT INTO Appointments (DoctorID, PatientID, AppointmentDate, AppointmentTime, Status) VALUES (?, ?, ?, ?, ?)', [DoctorID, PatientID, AppointmentDate, AppointmentTime, Status], (err, result) => {
        if (err) {
            console.error('Error inserting appointment:', err);
            res.status(500).send('Error inserting appointment');
        } else {
            console.log('Appointment inserted successfully');
            res.status(201).send('Appointment inserted successfully');
        }
    });
});


// Apply routes
app.use('/.netlify/functions/api', router);

// Export serverless handler
module.exports.handler = serverless(app);
