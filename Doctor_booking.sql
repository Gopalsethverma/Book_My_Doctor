CREATE DATABASE hospital;
USE hospital;

-- Table for Doctors
CREATE TABLE Doctors (
    DoctorID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(100),
    Specialization VARCHAR(100),
    Img VARCHAR(255)
);

-- Table for Patients
CREATE TABLE Patients (
    PatientID VARCHAR(250) PRIMARY KEY,
    Name VARCHAR(100),
    Age INT,
    Gender ENUM('Male', 'Female', 'Other') NOT NULL
);


-- Table for Available Slots
CREATE TABLE AvailableSlots (
    SlotID INT AUTO_INCREMENT PRIMARY KEY,
    DoctorID INT,
    AvailableDate DATE,
    AvailableTime TIME,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID)
);

-- Table for Appointments
CREATE TABLE Appointments (
    AppointmentID INT AUTO_INCREMENT PRIMARY KEY,
    DoctorID INT,
    PatientID VARCHAR(250),
    AppointmentDate DATE,
    AppointmentTime TIME,
    Status ENUM('Upcoming', 'Complete', 'Cancelled') NOT NULL,
    FOREIGN KEY (DoctorID) REFERENCES Doctors(DoctorID),
    FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

SELECT * FROM Appointments A
JOIN Doctors D ON D.DoctorID = A.DoctorID
AND PatientID = 'uRAzW1DfAxRYiPAu96UMUqBKPF12';

-- Create the trigger to remove slots from AvailableSlots
DELIMITER $$
CREATE TRIGGER RemoveSlotAfterAppointment
AFTER INSERT ON Appointments
FOR EACH ROW
BEGIN
    DELETE FROM AvailableSlots
    WHERE DoctorID = NEW.DoctorID
    AND AvailableDate = NEW.AppointmentDate
    AND AvailableTime = NEW.AppointmentTime;
END$$
DELIMITER ;


-- Create the trigger to update the status of appointments
-- DELIMITER $$
-- CREATE TRIGGER UpdateAppointmentStatus
-- AFTER INSERT ON Appointments
-- FOR EACH ROW
-- BEGIN
--     UPDATE Appointments
--     SET Status = 
--         CASE
--             WHEN Status = 'Cancelled' THEN 'Cancelled'
--             WHEN AppointmentDate > CURDATE() THEN 'Upcoming'
--             WHEN AppointmentDate = CURDATE() AND AppointmentTime > CURTIME() THEN 'Upcoming'
--             ELSE 'Complete'
--         END
--     WHERE AppointmentID = NEW.AppointmentID;
-- END$$
-- DELIMITER ;
-- drop trigger UpdateAppointmentStatus;


-- Update the status of appointments after insertion
SET SQL_SAFE_UPDATES = 0;
UPDATE Appointments
SET Status = 
    CASE
        WHEN Status = 'Cancelled' THEN 'Cancelled'
        WHEN AppointmentDate > CURDATE() THEN 'Upcoming'
        WHEN AppointmentDate = CURDATE() AND AppointmentTime > CURTIME() THEN 'Upcoming'
        ELSE 'Complete'
    END;

-- Inserting sample data for Doctors
INSERT INTO Doctors ( Name, Specialization, Img) VALUES
( 'Dr. John Smith', 'Cardiologist', 'assets/doctor01.jpeg'),
( 'Dr. Sarah Johnson', 'Dermatologist', 'assets/doctor02.png'),
( 'Dr. Rosa Williamson', 'Skin Specialist', 'assets/doctor03.jpeg'),
( 'Dr. Sachin Singh', 'Dentist', 'assets/doctor01.jpeg'),
( 'Dr. Amit Verma', 'Surgeon', 'assets/doctor02.png');
select * from AvailableSlots;
-- Inserting sample data for Patients
INSERT INTO Patients (PatientID, Name, Age, Gender) VALUES
('1', 'Alice Brown', 35, 'Female'),
('2', 'Bob Green', 45, 'Male');

-- Inserting sample data for Available Slots
INSERT INTO AvailableSlots (SlotID, DoctorID, AvailableDate, AvailableTime) VALUES
(1, 1, '2024-04-15', '10:00:00'),
(2, 1, '2024-04-16', '11:00:00'),
(3, 2, '2024-04-17', '14:00:00');
INSERT INTO AvailableSlots (SlotID, DoctorID, AvailableDate, AvailableTime) VALUES
(1, 1, '2024-04-18', '10:00:00');
-- Inserting appointments manually
INSERT INTO Appointments (DoctorID, PatientID, AppointmentDate, AppointmentTime, Status)
VALUES
(1, '1', '2024-04-15', '10:00:00', 'Upcoming'),
(1, '2', '2024-04-16', '11:00:00', 'Complete'),
(2, '1', '2024-04-17', '14:00:00', 'Cancelled');

INSERT INTO Appointments (DoctorID, PatientID, AppointmentDate, AppointmentTime, Status)
VALUES
(1, '1', '2024-04-17', '16:00:00', 'Upcoming');
INSERT INTO Appointments (DoctorID, PatientID, AppointmentDate, AppointmentTime, Status)
VALUES
(1, 'uRAzW1DfAxRYiPAu96UMUqBKPF12', '2024-04-13', '20:00:00', 'Complete'),
(1, 'uRAzW1DfAxRYiPAu96UMUqBKPF12', '2024-04-17', '16:00:00', 'Cancelled');
select * from Appointments;

INSERT INTO AvailableSlots ( DoctorID, AvailableDate, AvailableTime) VALUES
(1, '2024-04-19', '11:00:00'),
(1, '2024-04-20', '12:00:00'),
(1, '2024-04-20', '13:00:00'),
(1, '2024-04-19', '18:00:00');

INSERT INTO AvailableSlots ( DoctorID, AvailableDate, AvailableTime) VALUES
(5, '2024-04-19', '10:00:00'),
(5, '2024-04-20', '18:00:00');

INSERT INTO AvailableSlots ( DoctorID, AvailableDate, AvailableTime) VALUES
(1, '2024-04-13', '11:00:00');

-- Drop the existing foreign key constraint
ALTER TABLE AvailableSlots
DROP FOREIGN KEY DoctorID;

-- foreign key constraint with DELETE CASCADE
ALTER TABLE AvailableSlots
ADD CONSTRAINT FK_Doctors
FOREIGN KEY (DoctorID)
REFERENCES Doctors(DoctorID)
ON DELETE CASCADE;


-- for adding cascade in Appointments
ALTER TABLE Appointments
DROP FOREIGN KEY DoctorID;

ALTER TABLE Appointments
ADD CONSTRAINT FK_Doctors_Appointments
FOREIGN KEY (DoctorID)
REFERENCES Doctors(DoctorID)
ON DELETE CASCADE;

select* from AvailableSlots;


