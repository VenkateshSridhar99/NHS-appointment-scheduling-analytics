
-- appointment_scheduling_core.sql
-- Schema + sample analytic queries for the Appointment Scheduling synthetic dataset
-- Compatible with PostgreSQL / SQL Server (minor date functions noted).

/* ======================
   1) SCHEMA
   ====================== */

-- Drop stubs (safe if you re-run)
-- (Uncomment if needed)
-- DROP TABLE IF EXISTS feedback;
-- DROP TABLE IF EXISTS payments;
-- DROP TABLE IF EXISTS communications;
-- DROP TABLE IF EXISTS appointments;
-- DROP TABLE IF EXISTS appointment_slots;
-- DROP TABLE IF EXISTS services;
-- DROP TABLE IF EXISTS patients;
-- DROP TABLE IF EXISTS providers;
-- DROP TABLE IF EXISTS clinics;

CREATE TABLE clinics (
  clinic_id           INT PRIMARY KEY,
  clinic_name         VARCHAR(100) NOT NULL,
  borough             VARCHAR(100),
  postcode_outward    VARCHAR(10)
);

CREATE TABLE providers (
  provider_id         INT PRIMARY KEY,
  provider_name       VARCHAR(100) NOT NULL,
  email               VARCHAR(120),
  phone               VARCHAR(20),
  specialty           VARCHAR(50),
  seniority           VARCHAR(50),
  home_clinic_id      INT REFERENCES clinics(clinic_id),
  utilisation_target  DECIMAL(4,2) -- 0.65 .. 0.85
);

CREATE TABLE patients (
  patient_id          INT PRIMARY KEY,
  patient_name        VARCHAR(100) NOT NULL,
  email               VARCHAR(120),
  phone               VARCHAR(20),
  gender              VARCHAR(30),
  date_of_birth       DATE,
  postcode_outward    VARCHAR(10),
  registration_date   DATE
);

CREATE TABLE services (
  service_id              INT PRIMARY KEY,
  service_name            VARCHAR(100) NOT NULL,
  default_duration_mins   INT NOT NULL,
  list_price_gbp          DECIMAL(10,2) NOT NULL
);

CREATE TABLE appointment_slots (
  slot_id           INT PRIMARY KEY,
  provider_id       INT REFERENCES providers(provider_id),
  clinic_id         INT REFERENCES clinics(clinic_id),
  start_datetime    TIMESTAMP NOT NULL,
  end_datetime      TIMESTAMP NOT NULL
);

CREATE TABLE appointments (
  appointment_id    INT PRIMARY KEY,
  patient_id        INT REFERENCES patients(patient_id),
  provider_id       INT REFERENCES providers(provider_id),
  clinic_id         INT REFERENCES clinics(clinic_id),
  service_id        INT REFERENCES services(service_id),
  slot_id           INT REFERENCES appointment_slots(slot_id),
  created_at        TIMESTAMP NOT NULL,
  start_datetime    TIMESTAMP NOT NULL,
  end_datetime      TIMESTAMP NOT NULL,
  status            VARCHAR(20) NOT NULL,  -- Completed | Cancelled | No-show
  cancel_reason     VARCHAR(100),
  no_show_reason    VARCHAR(100),
  lead_time_days    INT,
  reminder_count    INT,
  check_in_time     TIMESTAMP NULL,
  wait_mins         INT,
  late_mins         INT,
  overrun_mins      INT
);

CREATE TABLE communications (
  communication_id  INT PRIMARY KEY,
  appointment_id    INT REFERENCES appointments(appointment_id),
  type              VARCHAR(30),   -- Reminder
  channel           VARCHAR(20),   -- SMS | Email | Phone
  sent_at           TIMESTAMP,
  content           VARCHAR(255)
);

CREATE TABLE payments (
  payment_id        INT PRIMARY KEY,
  appointment_id    INT REFERENCES appointments(appointment_id),
  list_price_gbp    DECIMAL(10,2) NOT NULL,
  discount_gbp      DECIMAL(10,2) NOT NULL,
  insured           BOOLEAN NOT NULL,
  patient_paid_gbp  DECIMAL(10,2) NOT NULL,
  insurer_paid_gbp  DECIMAL(10,2) NOT NULL,
  method            VARCHAR(20)    -- Card | Cash | Online | Invoice
);

CREATE TABLE feedback (
  feedback_id       INT PRIMARY KEY,
  appointment_id    INT REFERENCES appointments(appointment_id),
  star_rating       INT,           -- 1..5
  nps_score         INT,           -- 0..10
  comment           VARCHAR(255)
);

/* ======================
   2) SAMPLE QUERIES
   ====================== */

-- 2.1 Overview KPIs
-- PostgreSQL: date_trunc('month', ...)
-- SQL Server:  dateadd(month, datediff(month, 0, ...), 0)
SELECT
  COUNT(*) AS total_appointments,
  100.0 * AVG(CASE WHEN status='Completed' THEN 1.0 ELSE 0.0 END) AS completion_rate_pct,
  100.0 * AVG(CASE WHEN status='Cancelled' THEN 1.0 ELSE 0.0 END) AS cancel_rate_pct,
  100.0 * AVG(CASE WHEN status='No-show' THEN 1.0 ELSE 0.0 END) AS noshow_rate_pct
FROM appointments;

-- 2.2 No-show rate by weekday and hour
-- PostgreSQL: EXTRACT(DOW FROM ts) returns 0=Sunday..6=Saturday
-- SQL Server: DATEPART(WEEKDAY, ts) returns 1=Sunday..7=Saturday (adjust ordering as needed)
SELECT
  TO_CHAR(start_datetime, 'Day') AS weekday_label,
  EXTRACT(HOUR FROM start_datetime) AS hour_of_day,
  COUNT(*) AS appts,
  100.0 * SUM(CASE WHEN status='No-show' THEN 1 ELSE 0 END)::decimal / COUNT(*) AS noshow_pct
FROM appointments
GROUP BY 1,2
ORDER BY
  CASE TRIM(TO_CHAR(start_datetime,'Day'))
    WHEN 'Monday' THEN 1 WHEN 'Tuesday' THEN 2 WHEN 'Wednesday' THEN 3
    WHEN 'Thursday' THEN 4 WHEN 'Friday' THEN 5 WHEN 'Saturday' THEN 6
    ELSE 7 END,
  hour_of_day;

-- 2.3 Impact of reminders on no-shows
SELECT
  reminder_count,
  COUNT(*) AS appts,
  100.0 * SUM(CASE WHEN status='No-show' THEN 1 ELSE 0 END)::decimal / COUNT(*) AS noshow_pct
FROM appointments
GROUP BY reminder_count
ORDER BY reminder_count;

-- 2.4 Average wait & overrun by specialty (Completed appts only)
SELECT
  p.specialty,
  AVG(a.wait_mins) AS avg_wait_mins,
  AVG(a.overrun_mins) AS avg_overrun_mins,
  COUNT(*) AS completed_count
FROM appointments a
JOIN providers p ON a.provider_id = p.provider_id
WHERE a.status='Completed'
GROUP BY p.specialty
ORDER BY avg_wait_mins DESC;

-- 2.5 Revenue by clinic & payer mix
SELECT
  c.clinic_name,
  SUM(pay.patient_paid_gbp + pay.insurer_paid_gbp) AS total_revenue,
  100.0 * SUM(pay.insurer_paid_gbp) / NULLIF(SUM(pay.patient_paid_gbp + pay.insurer_paid_gbp),0) AS insurer_share_pct
FROM payments pay
JOIN appointments a ON pay.appointment_id = a.appointment_id
JOIN clinics c ON a.clinic_id = c.clinic_id
GROUP BY c.clinic_name
ORDER BY total_revenue DESC;

-- 2.6 Lead time vs no-show (bucketed)
WITH buckets AS (
  SELECT
    CASE
      WHEN lead_time_days <= 1 THEN '0-1 day'
      WHEN lead_time_days <= 3 THEN '2-3 days'
      WHEN lead_time_days <= 7 THEN '4-7 days'
      WHEN lead_time_days <= 14 THEN '8-14 days'
      ELSE '15+ days'
    END AS lead_bucket,
    status
  FROM appointments
)
SELECT
  lead_bucket,
  COUNT(*) AS appts,
  100.0 * SUM(CASE WHEN status='No-show' THEN 1 ELSE 0 END)::decimal / COUNT(*) AS noshow_pct
FROM buckets
GROUP BY lead_bucket
ORDER BY
  CASE lead_bucket
    WHEN '0-1 day' THEN 1 WHEN '2-3 days' THEN 2 WHEN '4-7 days' THEN 3
    WHEN '8-14 days' THEN 4 ELSE 5 END;

-- 2.7 Patient experience (NPS) by specialty (where feedback exists)
SELECT
  p.specialty,
  AVG(f.nps_score) AS avg_nps,
  COUNT(*) AS responses
FROM feedback f
JOIN appointments a ON f.appointment_id = a.appointment_id
JOIN providers p ON a.provider_id = p.provider_id
GROUP BY p.specialty
HAVING COUNT(*) >= 10
ORDER BY avg_nps DESC;

-- 2.8 Top providers by monthly revenue
SELECT
  date_trunc('month', a.start_datetime)::date AS month_start,
  pr.provider_name,
  SUM(pay.patient_paid_gbp + pay.insurer_paid_gbp) AS revenue_gbp
FROM payments pay
JOIN appointments a ON pay.appointment_id = a.appointment_id
JOIN providers pr ON a.provider_id = pr.provider_id
GROUP BY 1,2
ORDER BY month_start, revenue_gbp DESC;

-- End of file
