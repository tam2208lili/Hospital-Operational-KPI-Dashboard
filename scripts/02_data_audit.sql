/* FILE: 02_data_audit.sql
DESCRIPTION: Comprehensive Data Quality Audit identifying 7 key business logic errors.
*/

-- 1. Orphaned Records (Referential Integrity)
-- Identify records pointing to non-existent patients or doctors
SELECT 'Orphaned Admission' AS issue, COUNT(*) AS count
FROM RoomRecords r LEFT JOIN Patients p ON r.patient_id = p.patient_id
WHERE p.patient_id IS NULL
UNION ALL
SELECT 'Orphaned Surgery', COUNT(*)
FROM SurgeryRecord s LEFT JOIN Patients p ON s.patient_id = p.patient_id
WHERE p.patient_id IS NULL;

-- 2. Logical Date Anomalies in Admissions
-- Identify stays where Discharge Date is before Admission Date
SELECT admission_id, patient_id, admission_date, discharge_date
FROM RoomRecords
WHERE discharge_date < admission_date;

-- 3. Surgery Time Anomalies (Overnight & Typo Check)
-- Identify surgeries with impossible durations (>18h or 0 mins)
SELECT surgery_id, start_time, end_time,
    CASE 
        WHEN end_time > start_time THEN (end_time - start_time)
        ELSE (end_time + INTERVAL '24 hours') - start_time
    END AS calculated_duration
FROM SurgeryRecord
WHERE (CASE 
        WHEN end_time > start_time THEN (end_time - start_time)
        ELSE (end_time + INTERVAL '24 hours') - start_time
    END) > INTERVAL '18 hours' 
    OR start_time = end_time;

-- 4. Missing Financial Data
-- Check for NULL or Zero amounts in billing records
SELECT 'NULL Billing' AS issue, COUNT(*) FROM RoomRecords WHERE amount IS NULL
UNION ALL
SELECT 'Zero Billing', COUNT(*) FROM RoomRecords WHERE amount = 0;

-- 5. Conflicting Same-Day Stays
-- Identify patients with multiple records starting same day BUT ending on different dates
-- (Filters out legitimate same-day treatment where Start = End)
SELECT 
    patient_id, 
    admission_date, 
    COUNT(*) AS record_count,
    COUNT(DISTINCT discharge_date) AS distinct_end_dates,
    MIN(discharge_date) AS first_exit,
    MAX(discharge_date) AS last_exit
FROM RoomRecords
GROUP BY patient_id, admission_date
HAVING COUNT(*) > 1 
   AND MIN(discharge_date) <> MAX(discharge_date);

-- 6. Overlapping Medical Records (Detailed Trace)
-- Identify patients recorded in two different rooms/stays simultaneously
SELECT 
    r1.patient_id,
    r1.admission_id AS stay_A_id, r2.admission_id AS stay_B_id,
    r1.admission_date AS start_A, r1.discharge_date AS end_A,
    r2.admission_date AS start_B, r2.discharge_date AS end_B
FROM RoomRecords r1
JOIN RoomRecords r2 ON r1.patient_id = r2.patient_id 
    AND r1.admission_id < r2.admission_id
WHERE (r1.admission_date, r1.discharge_date) OVERLAPS (r2.admission_date, r2.discharge_date)
ORDER BY r1.patient_id;

-- 7. Doctor Availability Conflict (Detailed Trace)
-- Identify surgeons assigned to multiple surgeries at the same time
SELECT 
    s1.surgeon_id,
    s1.surgery_id AS surgery_A, s2.surgery_id AS surgery_B,
    s1.surgery_date,
    s1.start_time AS start_A, s1.end_time AS end_A,
    s2.start_time AS start_B, s2.end_time AS end_B
FROM SurgeryRecord s1
JOIN SurgeryRecord s2 ON s1.surgeon_id = s2.surgeon_id 
    AND s1.surgery_id < s2.surgery_id
    AND s1.surgery_date = s2.surgery_date
WHERE (s1.start_time, s1.end_time) OVERLAPS (s2.start_time, s2.end_time)
ORDER BY s1.surgeon_id;