Appointment Scheduling Analytics
Operational analytics to reduce no-shows, improve utilisation, and optimise revenue for an appointment scheduling context (based on my postgraduate dissertation).

Data note: The original dissertation dataset was lost after submission.
This repo uses a realistically modelled synthetic dataset mirroring the original structure and behaviour (lead time, reminders, cancellations/no-shows, waits/overruns, payer mix) so results are reproducible without patient data.

Quick links
Dataset (Excel): Appointment_Scheduling_Dataset.xlsx
SQL (schema + sample queries): appointment_scheduling_core.sql

Report: NHS Report
What this project covers

Descriptive: completion / cancellation / no-show rates, utilisation, waits & overruns.
Diagnostic: drivers of no-shows (lead time, reminders, weekday/hour), specialty effects.
Prescriptive: simple, actionable changes (extra reminders, time-of-day shifts, buffer times).

Key questions answered

When do no-shows spike (by weekday and time of day)?
Do reminders and lead time affect attendance?
Which specialties overrun or have longer waits?
What does the payer mix look like (patient vs insurer), and how does it impact revenue?
Which clinics/providers are closest to utilisation targets?

Methods & tools

Excel / Power BI: quick exploration & visuals.
SQL: schema + queries for utilisation, no-show analysis, wait/overrun, revenue by clinic.
Analytics techniques: correlation, feature importance, k-means clustering, time-series trend.

How to explore quickly

Excel / Power BI
Open Appointment_Scheduling_Dataset.xlsx.
Build visuals or recreate the ones below (no-show by weekday/hour, wait/overrun by specialty, revenue by clinic).

SQL

Create tables using sql/appointment_scheduling_core.sql.
Run the sample queries inside the file:
KPIs (completion / cancel / no-show).
No-show by weekday & hour.

Reminders vs no-shows.

Wait & overrun by specialty (Completed only).
Revenue by clinic & insurer share.

Lead-time buckets vs no-show.

NPS by specialty (where feedback exists).
