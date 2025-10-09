🧪 Clinical Trial Simulation Database (ClinicalSim)
📖 Project Overview
This project simulates a clinical trial relational database using synthetic data. It demonstrates end‑to‑end skills in:
- Database design (schema creation with primary/foreign keys, constraints)
- Data generation (synthetic patient data in R)
- Data integration (import into MySQL)
- Data validation (referential integrity, logical consistency, missing values)
- Data analysis (SQL queries for trial insights)
The database models a simplified clinical trial with patients, treatments, visits, lab results, and adverse events.

🗂️ Database Schema
- Patients: demographics, enrollment date
- Treatments: treatment arm (Placebo vs DrugA), dose, treatment dates
- Visits: scheduled visits per patient
- LabResults: lab test results per visit (ALT, AST, CRP, etc.)
- AdverseEvents: safety events with severity and seriousness
Relationships:
- Patients ↔ Treatments (1:1)
- Patients ↔ Visits (1:many)
- Visits ↔ LabResults (1:many)
- Patients ↔ AdverseEvents (1:many)

        ┌────────────────────┐
        │   Data Generation  │
        │   (R: synthetic    │
        │   patients, labs,  │
        │   treatments, AEs) │
        └─────────┬──────────┘
                  │  CSV export
                  ▼
        ┌────────────────────┐
        │   Data Storage     │
        │   (MySQL schema:   │
        │   Patients,        │
        │   Treatments,      │
        │   Visits, Labs,    │
        │   AdverseEvents)   │
        └─────────┬──────────┘
                  │  Import & load
                  ▼
        ┌────────────────────┐
        │   Data Validation  │
        │ - Referential      │
        │   integrity checks │
        │ - Missing values   │
        │ - Logical rules    │
        └─────────┬──────────┘
                  │  Clean, trusted data
                  ▼
        ┌────────────────────┐
        │   Data Analysis    │
        │ - Patients per arm │
        │ - Visit averages   │
        │ - Lab shifts (ALT) │
        │ - AE summaries     │
        └─────────┬──────────┘
                  │  Insights
                  ▼
        ┌────────────────────┐
        │   Visualization    │
        │   (Power BI/Tableau│
        │   dashboards: labs,│
        │   AEs, trends)     │
        └────────────────────┘
✅ Data Validation
Examples of checks performed:
- Orphan records (LabResults without Visits, AEs without Patients)
- Logical consistency (Placebo patients always have Dose = 0)
- Temporal consistency (no visits before enrollment)
- Missing values (null doses, missing lab results)

  📊 Example Analyses
- Patients per treatment arm
SELECT Arm, COUNT(*) AS PatientCount
FROM Treatments
GROUP BY Arm;

- Average number of visits per patient
  SELECT AVG(VisitCount) AS AvgVisits
FROM (
  SELECT PatientID, COUNT(*) AS VisitCount
  FROM Visits
  GROUP BY PatientID
) t;

  - Lab test averages by arm
SELECT t.Arm, l.TestCode, AVG(l.ResultValue) AS AvgResult
FROM LabResults l
JOIN Treatments t ON l.PatientID = t.PatientID
GROUP BY t.Arm, l.TestCode;

🔎 Example Insights
- Balanced Enrollment: Equal numbers of patients were randomized to Placebo and DrugA arms.
- Lab Shifts: DrugA patients showed a greater average increase in ALT from baseline compared to Placebo.
- Adverse Events: DrugA patients experienced more moderate AEs, while Placebo patients had mostly mild events.
- Visit Compliance: Average number of visits per patient was consistent across arms, indicating good adherence.

🚀 Extensions
- Add more endpoints (efficacy, concomitant meds, discontinuations)
- Build dashboards in Power BI/Tableau for lab trends and AE rates
- Expand validation rules for regulatory‑style data cleaning

🎯 Skills Demonstrated
- SQL schema design & normalization
- Data generation & cleaning (R)
- ETL (CSV → MySQL)
- Data validation & quality checks
- Analytical SQL for clinical data

