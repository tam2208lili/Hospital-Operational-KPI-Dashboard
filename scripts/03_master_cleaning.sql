/* FILE: 03_master_cleaning.sql
DESCRIPTION: Final Transformation Layer. 
             Resolves all 7 audit issues: Orphans, Date Logic, Overnight Surgery, 
             NULL Financials, Conflicting Stays, Patient Overlaps, and Surgeon Conflicts.
*/

-- PRE-CLEANING: Drop existing views to avoid structure conflict errors
DROP VIEW IF EXISTS dw_clean_surgeries CASCADE;
DROP VIEW IF EXISTS dw_clean_admissions CASCADE;
DROP VIEW IF EXISTS dw_clean_patients CASCADE;
DROP VIEW IF EXISTS dw_clean_appointments CASCADE;

-- 1. CLEAN PATIENTS
-- Purpose: Standardizing master data for patient demographics.
CREATE OR REPLACE VIEW dw_clean_patients AS
SELECT DISTINCT
    patient_id,
    TRIM(fname) AS first_name,
    TRIM(lname) AS last_name,
    COALESCE(UPPER(gender), 'OTHER') AS gender,
    date_of_birth,
    COALESCE(contact_no, 'N/A') AS contact_info
FROM Patients
WHERE patient_id IS NOT NULL;

-- 2. CLEAN ADMISSIONS & BILLING
-- Purpose: Handles duplicates, overlaps, and financial NULLs.
CREATE OR REPLACE VIEW dw_clean_admissions AS
WITH deduplicated_admissions AS (
    -- Fix Issue #5: Prioritize record with the latest discharge in case of same-day start conflicts
    SELECT DISTINCT ON (patient_id, admission_date)
        admission_id, 
        patient_id,
        room_no,
        admission_date,
        COALESCE(discharge_date, CURRENT_DATE) AS discharge_date,
        COALESCE(amount, 0) AS total_billing
    FROM RoomRecords
    -- Fix Issue #1: Ensure Patient exists in master table
    WHERE patient_id IN (SELECT patient_id FROM Patients)
    ORDER BY patient_id, admission_date, discharge_date DESC
)
SELECT 
    *,
    -- Calculate Length of Stay (LOS), minimum 1 day for same-day admissions
    CASE 
        WHEN (discharge_date - admission_date) = 0 THEN 1 
        ELSE (discharge_date - admission_date) 
    END AS length_of_stay
FROM deduplicated_admissions
WHERE admission_date <= discharge_date -- Fix Issue #2: Logical Date
  AND NOT EXISTS (
      -- Fix Issue #6: Eliminate overlapping stays for the same patient
      SELECT 1 FROM RoomRecords r2 
      WHERE deduplicated_admissions.patient_id = r2.patient_id 
        AND deduplicated_admissions.admission_id < r2.admission_id
        AND (deduplicated_admissions.admission_date, deduplicated_admissions.discharge_date) 
            OVERLAPS (r2.admission_date, r2.discharge_date)
  );

-- 3. CLEAN SURGERIES
-- Purpose: Handles overnight math and surgeon scheduling conflicts.
CREATE OR REPLACE VIEW dw_clean_surgeries AS
WITH surgery_calc AS (
    SELECT 
        s.surgery_id,
        s.patient_id,
        s.surgeon_id,
        s.surgery_date,
        s.start_time,
        s.end_time,
        s.surgery_type,
        -- Fix Issue #3: Handle overnight surgeries by adding 24h if end < start
        CASE 
            WHEN s.end_time > s.start_time THEN (s.end_time - s.start_time)
            ELSE (s.end_time + INTERVAL '24 hours') - s.start_time
        END AS raw_duration
    FROM SurgeryRecord s
    -- Fix Issue #1: Referral Integrity
    INNER JOIN Doctor d ON s.surgeon_id = d.doct_id
    INNER JOIN Patients p ON s.patient_id = p.patient_id
)
SELECT 
    surgery_id,
    patient_id,
    surgeon_id,
    surgery_date,
    surgery_type,
    raw_duration AS duration,
    -- Extract numeric hours for Tableau KPIs
    EXTRACT(EPOCH FROM raw_duration) / 3600 AS duration_hours
FROM surgery_calc
WHERE raw_duration < INTERVAL '18 hours' -- Filter potential data entry typos
  AND raw_duration > INTERVAL '0 minutes'
  AND NOT EXISTS (
      -- Fix Issue #7: Eliminate Surgeon availability conflicts
      SELECT 1 FROM SurgeryRecord s2
      WHERE surgery_calc.surgeon_id = s2.surgeon_id
        AND surgery_calc.surgery_id > s2.surgery_id
        AND surgery_calc.surgery_date = s2.surgery_date
        AND (surgery_calc.start_time, surgery_calc.end_time) 
            OVERLAPS (s2.start_time, s2.end_time)
  );