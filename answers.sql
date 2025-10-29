USE klinik_mandiri;

-- ============================================
-- CASE 1 : QUERY DASAR (SELECT & WHERE)
-- ============================================

-- DASAR
-- Tampilkan daftar pasien berusia ≥ 50 tahun,
-- urut berdasarkan umur tertua (paling tua dulu).
SELECT 
    patient_id,
    name,
    TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age
FROM patient
WHERE TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) >= 50
ORDER BY age DESC;

-- MENENGAH
-- Tambahkan kolom kategori umur:
-- <18 = Anak, 18–59 = Dewasa, ≥60 = Lansia.
SELECT 
    patient_id,
    name,
    TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) AS age,
    CASE
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) < 18 THEN 'Anak'
        WHEN TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) BETWEEN 18 AND 59 THEN 'Dewasa'
        ELSE 'Lansia'
    END AS kategori_umur
FROM patient
ORDER BY age DESC;

-- LANJUT
-- Hitung persentase pasien lansia dibanding total pasien.
SELECT 
    ROUND(
        (COUNT(*) / (SELECT COUNT(*) FROM patient)) * 100, 2
    ) AS persen_lansia
FROM patient
WHERE TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) >= 60;



-- ============================================
-- CASE 2 : MANIPULASI DATA (INSERT, UPDATE, DELETE)
-- ============================================

-- 🟢 DASAR
-- Tambahkan 5 pasien baru, ubah status no_show → cancelled,
-- dan hapus resep yang qty = 0.

-- Tambah 5 pasien baru
INSERT INTO patient (name, birth_date, gender, phone) VALUES
('Kevin Pradana', '1997-11-04', 'M', '081234599001'),
('Nadia Hapsari', '1993-02-18', 'F', '081234599002'),
('Rio Nugroho', '1985-05-23', 'M', '081234599003'),
('Citra Maharani', '2000-08-14', 'F', '081234599004'),
('Bagus Wicaksono', '1978-09-30', 'M', '081234599005');

-- cek 5 pasien baru
-- SELECT * FROM patient;

-- Ubah status appointment 'no_show' jadi 'cancelled'
UPDATE appointment
SET status = 'cancelled'
WHERE status = 'no_show';

-- untuk cek hasil ubah status
-- SELECT appt_id, patient_id, doctor_id, appt_date, status
-- FROM appointment
-- WHERE status = 'cancelled';

-- Hapus prescription dengan qty = 0
DELETE FROM prescription
WHERE qty = 0;

-- 🟡 MENENGAH
-- Tambahkan kolom created_at di tabel appointment
-- dan isi otomatis dengan tanggal insert.
ALTER TABLE appointment
ADD COLUMN created_at DATETIME DEFAULT CURRENT_TIMESTAMP;

-- 🔴 LANJUT
-- Gunakan INSERT INTO ... SELECT untuk menyalin pasien usia > 60
-- ke tabel arsip baru bernama patient_archive.

-- Buat tabel arsip (jika belum ada)
CREATE TABLE IF NOT EXISTS patient_archive (
    patient_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100),
    birth_date DATE,
    gender ENUM('M', 'F'),
    phone VARCHAR(20)
);

-- Salin pasien usia > 60 ke tabel arsip
INSERT INTO patient_archive (name, birth_date, gender, phone)
SELECT name, birth_date, gender, phone
FROM patient
WHERE TIMESTAMPDIFF(YEAR, birth_date, CURDATE()) > 60;

-- untuk cek hasil DML
-- SELECT * FROM patient_archive; 


-- ============================================
-- CASE 3 : JOIN DASAR (INNER, LEFT, RIGHT JOIN)
-- ============================================

-- 🟢 DASAR
-- Tampilkan daftar appointment lengkap dengan nama pasien dan dokter.
SELECT 
    a.appt_id,
    p.name AS patient_name,
    d.name AS doctor_name,
    a.appt_date,
    a.status
FROM appointment a
INNER JOIN patient p ON a.patient_id = p.patient_id
INNER JOIN doctor d ON a.doctor_id = d.doctor_id
ORDER BY a.appt_date;

-- 🟡 MENENGAH
-- Tampilkan semua pasien beserta tanggal appointment-nya (jika ada),
-- termasuk pasien yang belum pernah membuat appointment (LEFT JOIN).
SELECT 
    p.patient_id,
    p.name AS patient_name,
    a.appt_date,
    a.status
FROM patient p
LEFT JOIN appointment a ON p.patient_id = a.patient_id
ORDER BY p.patient_id;

-- 🔴 LANJUT
-- Tampilkan jumlah appointment yang ditangani tiap dokter.
-- Urutkan dari dokter dengan appointment terbanyak.
SELECT 
    d.doctor_id,
    d.name AS doctor_name,
    d.specialty,
    COUNT(a.appt_id) AS total_appointment
FROM doctor d
LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name, d.specialty
ORDER BY total_appointment DESC;


-- ============================================
-- CASE 4 : FUNGSI SKALAR & FORMATTING
-- ============================================

-- 🟢 DASAR
-- Tampilkan patient_id, NAMA (huruf besar), umur, dan tanggal kunjungan terakhir.
SELECT 
    p.patient_id,
    UPPER(p.name) AS nama_pasien,
    TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE()) AS umur,
    MAX(a.appt_date) AS tanggal_kunjungan_terakhir
FROM patient p
LEFT JOIN appointment a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.name, p.birth_date
ORDER BY tanggal_kunjungan_terakhir DESC;

-- 🟡 MENENGAH
-- Format nama menjadi 'Nama (Umur Tahun)' menggunakan CONCAT.
SELECT 
    p.patient_id,
    CONCAT(p.name, ' (', TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE()), ' Tahun)') AS nama_dan_umur,
    p.gender,
    MAX(a.appt_date) AS tanggal_kunjungan_terakhir
FROM patient p
LEFT JOIN appointment a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.name, p.birth_date, p.gender
ORDER BY p.name;

-- 🔴 LANJUT
-- Hitung rata-rata umur pasien per gender (GROUP BY).
SELECT 
    p.gender,
    ROUND(AVG(TIMESTAMPDIFF(YEAR, p.birth_date, CURDATE())), 2) AS rata_rata_umur
FROM patient p
GROUP BY p.gender;


-- ============================================
-- CASE 5 : AGREGASI & GROUP BY
-- ============================================

-- 🟢 DASAR
-- Tampilkan jumlah appointment per dokter
-- dan rata-rata pembayaran per dokter > 300.000.
SELECT 
    d.doctor_id,
    d.name AS doctor_name,
    COUNT(a.appt_id) AS jumlah_appointment,
    ROUND(AVG(p.amount), 2) AS rata_rata_pembayaran
FROM doctor d
LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
LEFT JOIN payment p ON a.appt_id = p.appt_id
GROUP BY d.doctor_id, d.name
HAVING rata_rata_pembayaran > 300000
ORDER BY rata_rata_pembayaran DESC;

-- 🟡 MENENGAH
-- Hitung total pembayaran per pasien dengan kategori:
-- (<300rb = Rendah, 300–600rb = Menengah, >600rb = Tinggi)
SELECT 
    pt.patient_id,
    pt.name AS patient_name,
    SUM(py.amount) AS total_pembayaran,
    CASE
        WHEN SUM(py.amount) < 300000 THEN 'Rendah'
        WHEN SUM(py.amount) BETWEEN 300000 AND 600000 THEN 'Menengah'
        ELSE 'Tinggi'
    END AS kategori_pembayaran
FROM patient pt
JOIN appointment a ON pt.patient_id = a.patient_id
JOIN payment py ON a.appt_id = py.appt_id
GROUP BY pt.patient_id, pt.name
ORDER BY total_pembayaran DESC;

-- 🔴 LANJUT
-- Tampilkan 5 pasien dengan total pembayaran tertinggi.
SELECT 
    pt.patient_id,
    pt.name AS patient_name,
    ROUND(SUM(py.amount), 2) AS total_pembayaran
FROM patient pt
JOIN appointment a ON pt.patient_id = a.patient_id
JOIN payment py ON a.appt_id = py.appt_id
GROUP BY pt.patient_id, pt.name
ORDER BY total_pembayaran DESC
LIMIT 5;


-- ============================================
-- CASE 6 : SUBQUERY (NON-CORRELATED)
-- ============================================

-- 🟢 DASAR
-- a. Tampilkan pasien yang pernah berobat ke dokter dengan spesialis 'Cardiology'.
SELECT 
    DISTINCT p.patient_id,
    p.name AS patient_name
FROM patient p
WHERE p.patient_id IN (
    SELECT a.patient_id
    FROM appointment a
    JOIN doctor d ON a.doctor_id = d.doctor_id
    WHERE d.specialty = 'Cardiology'
);

-- b. Tampilkan dokter yang memiliki jumlah appointment
-- lebih banyak dari rata-rata semua dokter.
SELECT 
    d.doctor_id,
    d.name AS doctor_name,
    COUNT(a.appt_id) AS total_appointment
FROM doctor d
JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name
HAVING total_appointment > (
    SELECT AVG(jumlah)
    FROM (
        SELECT COUNT(appt_id) AS jumlah
        FROM appointment
        GROUP BY doctor_id
    ) AS subq
);

-- 🟡 MENENGAH
-- Tampilkan pasien yang belum pernah melakukan pembayaran (NOT IN payment).
SELECT 
    p.patient_id,
    p.name AS patient_name
FROM patient p
WHERE p.patient_id NOT IN (
    SELECT DISTINCT a.patient_id
    FROM appointment a
    JOIN payment py ON a.appt_id = py.appt_id
);

-- 🔴 LANJUT
-- Tampilkan dokter dengan total pendapatan lebih besar
-- dari rata-rata pendapatan semua dokter (subquery bersarang).
SELECT 
    d.doctor_id,
    d.name AS doctor_name,
    ROUND(SUM(py.amount), 2) AS total_pendapatan
FROM doctor d
JOIN appointment a ON d.doctor_id = a.doctor_id
JOIN payment py ON a.appt_id = py.appt_id
GROUP BY d.doctor_id, d.name
HAVING total_pendapatan > (
    SELECT AVG(total)
    FROM (
        SELECT SUM(py2.amount) AS total
        FROM doctor d2
        JOIN appointment a2 ON d2.doctor_id = a2.doctor_id
        JOIN payment py2 ON a2.appt_id = py2.appt_id
        GROUP BY d2.doctor_id
    ) AS subq
)
ORDER BY total_pendapatan DESC;


-- ============================================
-- CASE 7 : SUBQUERY (CORRELATED)
-- ============================================

-- 🟢 DASAR
-- Tampilkan daftar appointment beserta total biaya resep-nya.
-- Subquery menghitung total (qty * price) dari tabel prescription.
SELECT 
    a.appt_id,
    a.patient_id,
    a.doctor_id,
    a.appt_date,
    (
        SELECT SUM(pr.qty * pr.price)
        FROM prescription pr
        WHERE pr.appt_id = a.appt_id
    ) AS total_biaya_resep
FROM appointment a
ORDER BY a.appt_date
LIMIT 20;  -- biar hasilnya gak kepanjangan

-- 🟡 MENENGAH
-- Tambahkan kategori biaya resep:
-- <100rb = Murah, 100–300rb = Sedang, >300rb = Mahal.
SELECT 
    a.appt_id,
    a.patient_id,
    a.doctor_id,
    a.appt_date,
    (
        SELECT SUM(pr.qty * pr.price)
        FROM prescription pr
        WHERE pr.appt_id = a.appt_id
    ) AS total_biaya_resep,
    CASE
        WHEN (
            SELECT SUM(pr.qty * pr.price)
            FROM prescription pr
            WHERE pr.appt_id = a.appt_id
        ) < 100000 THEN 'Murah'
        WHEN (
            SELECT SUM(pr.qty * pr.price)
            FROM prescription pr
            WHERE pr.appt_id = a.appt_id
        ) BETWEEN 100000 AND 300000 THEN 'Sedang'
        ELSE 'Mahal'
    END AS kategori_biaya
FROM appointment a
ORDER BY total_biaya_resep DESC
LIMIT 20;

-- 🔴 LANJUT
-- Tampilkan 5 appointment termahal per dokter
-- menggunakan correlated subquery (per dokter_id).
SELECT 
    a.appt_id,
    a.doctor_id,
    a.patient_id,
    a.appt_date,
    (
        SELECT SUM(pr.qty * pr.price)
        FROM prescription pr
        WHERE pr.appt_id = a.appt_id
    ) AS total_biaya_resep
FROM appointment a
WHERE (
    SELECT COUNT(*)
    FROM appointment a2
    WHERE a2.doctor_id = a.doctor_id
      AND (
        SELECT SUM(pr2.qty * pr2.price)
        FROM prescription pr2
        WHERE pr2.appt_id = a2.appt_id
      ) >
      (
        SELECT SUM(pr3.qty * pr3.price)
        FROM prescription pr3
        WHERE pr3.appt_id = a.appt_id
      )
) < 5
ORDER BY a.doctor_id, total_biaya_resep DESC;


-- ============================================
-- CASE 8 : ADVANCED QUERY (ANALISIS LANJUTAN)
-- ============================================

-- 🟢 DASAR
-- Tampilkan 3 pasien paling sering datang ke klinik (COUNT + LIMIT 3).
SELECT 
    p.patient_id,
    p.name AS patient_name,
    COUNT(a.appt_id) AS jumlah_kunjungan
FROM patient p
JOIN appointment a ON p.patient_id = a.patient_id
GROUP BY p.patient_id, p.name
ORDER BY jumlah_kunjungan DESC
LIMIT 3;

-- 🟡 MENENGAH
-- Hitung jumlah pasien unik yang ditangani oleh setiap dokter (GROUP BY).
SELECT 
    d.doctor_id,
    d.name AS doctor_name,
    COUNT(DISTINCT a.patient_id) AS jumlah_pasien_unik
FROM doctor d
LEFT JOIN appointment a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor_id, d.name
ORDER BY jumlah_pasien_unik DESC;

-- 🔴 LANJUT
-- Tampilkan 3 pasien teratas per dokter berdasarkan frekuensi kunjungan.
-- Menggunakan ROW_NUMBER() OVER (PARTITION BY ... ORDER BY ...).
SELECT *
FROM (
    SELECT 
        d.doctor_id,
        d.name AS doctor_name,
        p.patient_id,
        p.name AS patient_name,
        COUNT(a.appt_id) AS jumlah_kunjungan,
        ROW_NUMBER() OVER (
            PARTITION BY d.doctor_id
            ORDER BY COUNT(a.appt_id) DESC
        ) AS peringkat
    FROM doctor d
    JOIN appointment a ON d.doctor_id = a.doctor_id
    JOIN patient p ON a.patient_id = p.patient_id
    GROUP BY d.doctor_id, d.name, p.patient_id, p.name
) AS ranked
WHERE ranked.peringkat <= 3
ORDER BY ranked.doctor_id, ranked.peringkat;
