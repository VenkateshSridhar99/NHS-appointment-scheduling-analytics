Appointment Scheduling Analytics 🩺📅

Operational analytics to reduce no-shows, improve utilisation, and optimise revenue.
This is a compact, portfolio-ready snapshot of my postgraduate dissertation.

Data note: The original dissertation dataset was lost post-submission.
This repo uses a realistically modelled synthetic dataset that mirrors the original structure and behaviour (lead time, reminders, cancellations/no-shows, waits/overruns, payer mix). Safe for public sharing.

🔗 Quick Links

- 📊 **Dataset (Excel):** [Appointment_Scheduling_Dataset.xlsx](<Appointment_Scheduling_Dataset.xlsx>)
- 🧠 **SQL (schema + queries):** [appointment_scheduling_core.sql](<appointment_scheduling_core.sql>)
- 📄 **Report:** [NHS Report.pdf](<NHS Report.pdf>) ·

🚀 Explore in 60 Seconds

Option A — Excel/Power BI

Open Appointment_Scheduling_Dataset.xlsx.

Recreate or tweak the visuals below: no-show by weekday/hour, wait & overrun by specialty, revenue by clinic.

Option B — SQL (Postgres/SQL Server)

Create tables using appointment_scheduling_core.sql.

Run the baked-in queries for:

KPIs (completion / cancel / no-show)

No-show by weekday & hour

Reminders vs no-shows

Wait & overrun by specialty (Completed only)

Revenue by clinic & insurer share

Lead-time buckets vs no-show

NPS by specialty (where feedback exists)

🧭 What’s Inside

Descriptive: completion/cancellation/no-show rates, utilisation, waits & overruns

Diagnostic: drivers of DNAs (lead time, reminders, weekday/hour), specialty effects

Prescriptive: actions (extra reminders 24–48h, shift high-risk slots earlier, buffer time for overrun-prone specialties)

(Optional) Predictive direction: feature importance & clustering to inform operations

🛠️ Tools & Methods

Tools: Excel · SQL · Power BI
Techniques: correlation, feature importance (Random Forest), k-means clustering, time-series trend/seasonality, basic patient feedback (NPS)
