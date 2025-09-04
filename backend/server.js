const express = require('express');
const bodyParser = require('body-parser');
const mysql = require('mysql2');
const cors = require('cors');

const app = express();

// Middleware
app.use(bodyParser.urlencoded({ extended: false }));
app.use(bodyParser.json());
app.use(cors());

// Database connection
const connection = mysql.createConnection({
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    port: Number(process.env.DB_PORT),
    database: process.env.DB_NAME
});

connection.connect((err) => {
    if (err) throw err;
    console.log("Database connected");
});

// Health check endpoint for Kubernetes probes
app.get('/health', (req, res) => {
    res.status(200).json({ status: 'OK', timestamp: new Date().toISOString() });
});

// Import routes from the Netlify function
const router = express.Router();

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
    // Start transaction to emulate trigger behavior: remove slot then insert appointment
    connection.beginTransaction(err => {
        if (err) {
            console.error('Error starting transaction:', err);
            return res.status(500).send('Error starting transaction');
        }

        const lockSlotSql = `SELECT SlotID FROM AvailableSlots WHERE DoctorID = ? AND AvailableDate = ? AND AvailableTime = ? FOR UPDATE`;

        connection.query(lockSlotSql, [DoctorID, AppointmentDate, AppointmentTime], (lockErr, rows) => {
            if (lockErr) {
                return connection.rollback(() => {
                    console.error('Error verifying slot:', lockErr);
                    res.status(500).send('Error verifying slot');
                });
            }

            if (!rows || rows.length === 0) {
                return connection.rollback(() => {
                    res.status(409).send('Selected slot is no longer available');
                });
            }

            const slotId = rows[0].SlotID;
            const deleteSlotSql = 'DELETE FROM AvailableSlots WHERE SlotID = ?';

            connection.query(deleteSlotSql, [slotId], (deleteErr) => {
                if (deleteErr) {
                    return connection.rollback(() => {
                        console.error('Error reserving slot:', deleteErr);
                        res.status(500).send('Error reserving slot');
                    });
                }

                const insertApptSql = 'INSERT INTO Appointments (DoctorID, PatientID, AppointmentDate, AppointmentTime, Status) VALUES (?, ?, ?, ?, ?)';
                const params = [DoctorID, PatientID, AppointmentDate, AppointmentTime, Status];

                connection.query(insertApptSql, params, (insertErr, result) => {
                    if (insertErr) {
                        return connection.rollback(() => {
                            console.error('Error inserting appointment:', insertErr);
                            res.status(500).send('Error inserting appointment');
                        });
                    }

                    connection.commit(commitErr => {
                        if (commitErr) {
                            return connection.rollback(() => {
                                console.error('Error finalizing appointment:', commitErr);
                                res.status(500).send('Error finalizing appointment');
                            });
                        }

                        res.status(201).json({ message: 'Appointment inserted successfully', appointmentId: result.insertId });
                    });
                });
            });
        });
    });
});

// Mount routes
app.use('/', router);

// Start server
const port = process.env.PORT || 3000;
app.listen(port, () => {
    console.log(`API server listening on port ${port}`);
});
