CREATE schema klinik_mandiri;
USE klinik_mandiri;

-- ======================
-- TABLE: patient
-- ======================
CREATE TABLE patient (
    patient_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    gender ENUM('M', 'F') NOT NULL,
    phone VARCHAR(20) UNIQUE
);

-- ======================
-- TABLE: doctor
-- ======================
CREATE TABLE doctor (
    doctor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    specialty VARCHAR(100) NOT NULL,
    phone VARCHAR(20) UNIQUE
);

-- ======================
-- TABLE: appointment
-- ======================
CREATE TABLE appointment (
    appt_id INT AUTO_INCREMENT PRIMARY KEY,
    patient_id INT NOT NULL,
    doctor_id INT NOT NULL,
    appt_date DATE NOT NULL,
    appt_time TIME NOT NULL,
    status ENUM('scheduled', 'done', 'cancelled', 'no_show') DEFAULT 'scheduled',
    FOREIGN KEY (patient_id) REFERENCES patient(patient_id),
    FOREIGN KEY (doctor_id) REFERENCES doctor(doctor_id)
);

-- ======================
-- TABLE: diagnosis
-- ======================
CREATE TABLE diagnosis (
    diag_id INT AUTO_INCREMENT PRIMARY KEY,
    appt_id INT NOT NULL,
    diag_text TEXT,
    FOREIGN KEY (appt_id) REFERENCES appointment(appt_id)
);

-- ======================
-- TABLE: prescription
-- ======================
CREATE TABLE prescription (
    presc_id INT AUTO_INCREMENT PRIMARY KEY,
    appt_id INT NOT NULL,
    medicine_name VARCHAR(100),
    qty INT CHECK (qty >= 0),
    price DECIMAL(10,2),
    FOREIGN KEY (appt_id) REFERENCES appointment(appt_id)
);

-- ======================
-- TABLE: payment
-- ======================
CREATE TABLE payment (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    appt_id INT NOT NULL,
    amount DECIMAL(12,2),
    pay_date DATE DEFAULT (CURRENT_DATE),
    pay_method ENUM('cash', 'card', 'transfer') DEFAULT 'cash',
    FOREIGN KEY (appt_id) REFERENCES appointment(appt_id)
);
