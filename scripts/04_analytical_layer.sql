/* FILE: 04_analytical_layer.sql
DESCRIPTION: Finalized Fact Tables for 5 Dashboards.
*/

-- ==========================================================
-- 1. FACT_ADMISSIONS_CAPACITY
-- Purpose: Executive Overview & Demographics (Dashboard 1 & 5)
-- ==========================================================
DROP VIEW IF EXISTS fact_admissions_capacity CASCADE;

CREATE VIEW fact_admissions_capacity AS
SELECT 
    rrec.admission_ID,
    rrec.patient_Id,
    p.Gender,
    -- Calculate precise age at time of admission
    EXTRACT(YEAR FROM AGE(rrec.admission_Date, p.Date_Of_Birth)) AS patient_age,
    -- Group age into bins for Demographics Dashboard
    CASE 
        WHEN EXTRACT(YEAR FROM AGE(rrec.admission_Date, p.Date_Of_Birth)) < 18 THEN 'Under 18'
        WHEN EXTRACT(YEAR FROM AGE(rrec.admission_Date, p.Date_Of_Birth)) BETWEEN 18 AND 60 THEN '18-60'
        ELSE 'Over 60'
    END AS age_group,
    d.dept_Name,
    rrec.admission_Date,
    rrec.discharge_Date,
    -- Length of Stay
    CASE 
        WHEN (rrec.discharge_Date - rrec.admission_Date) = 0 THEN 1 
        ELSE (rrec.discharge_Date - rrec.admission_Date) 
    END AS bed_days,
    rrec.amount AS revenue,
    rrec.mode_of_payment
FROM RoomRecords rrec
JOIN Room r ON rrec.room_no = r.room_No
JOIN Department d ON r.dept_Id = d.dept_Id
JOIN Patients p ON rrec.patient_Id = p.patient_Id;

-- ==========================================================
-- 2. FACT_STAFFING_EFFICIENCY
-- Purpose: Nurse Efficiency & Workload (Dashboard 2)
-- ==========================================================
DROP VIEW IF EXISTS fact_staffing_efficiency CASCADE;

CREATE VIEW fact_staffing_efficiency AS
WITH DeptNurseCount AS (
    SELECT dept_Id, COUNT(nurse_Id) AS nurse_count 
    FROM Nurse 
    GROUP BY dept_Id
),
DeptPatientInflow AS (
    SELECT r.dept_Id, rrec.admission_Date, COUNT(rrec.admission_ID) AS patient_count
    FROM RoomRecords rrec
    JOIN Room r ON rrec.room_no = r.room_No
    GROUP BY r.dept_Id, rrec.admission_Date
)
SELECT 
    d.dept_Name,
    dpi.admission_Date,
    COALESCE(dnc.nurse_count, 0) AS nurse_count,
    COALESCE(dpi.patient_count, 0) AS patient_count,
    -- Calculating the Workload Ratio
    CASE 
        WHEN COALESCE(dnc.nurse_count, 0) = 0 THEN NULL 
        ELSE (dpi.patient_count::float / dnc.nurse_count) 
    END AS patient_to_nurse_ratio
FROM Department d
LEFT JOIN DeptPatientInflow dpi ON d.dept_Id = dpi.dept_Id
LEFT JOIN DeptNurseCount dnc ON d.dept_Id = dnc.dept_Id
WHERE dpi.admission_Date IS NOT NULL;

-- ==========================================================
-- 3. FACT_APPOINTMENT_CONVERSION
-- Purpose: Funnel Analysis & Marketing (Dashboard 3)
-- ==========================================================
DROP VIEW IF EXISTS fact_appointment_conversion CASCADE;

CREATE VIEW fact_appointment_conversion AS
SELECT 
    a.appoIntment_Id, -- Spelling matches your CSV
    a.patient_Id,
    doc.FName || ' ' || doc.LName AS doctor_full_name,
    d.dept_Name,
    a.appointment_Date,
    a.appointment_status,
    a.mode_of_appointment,
    -- Conversion Logic: Admitted within 3 days after appointment
    CASE WHEN rrec.admission_ID IS NOT NULL THEN 1 ELSE 0 END AS is_converted
FROM Appointment a
JOIN Doctor doc ON a.doct_Id = doc.doct_Id
JOIN Department d ON doc.dept_Id = d.dept_Id
LEFT JOIN RoomRecords rrec ON a.patient_Id = rrec.patient_Id 
    AND (rrec.admission_Date BETWEEN a.appointment_Date AND a.appointment_Date + INTERVAL '3 days');

-- ==========================================================
-- 4. FACT_SURGERY_PERFORMANCE
-- Purpose: Surgical Volume & Surgeon Performance (Dashboard 4)
-- ==========================================================
DROP VIEW IF EXISTS fact_surgery_performance CASCADE;

CREATE VIEW fact_surgery_performance AS
SELECT 
    s.surgery_Id,
    s.patient_Id,
    s.surgery_Type,
    s.surgery_Date,
    d.dept_Name,
    doc.FName || ' ' || doc.LName AS surgeon_full_name,
    s.notes AS surgery_notes
FROM SurgeryRecord s
JOIN Doctor doc ON s.surgeon_Id = doc.doct_Id
JOIN Department d ON doc.dept_Id = d.dept_Id;