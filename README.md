# Capstone Project Report – Part 1  
**Clinical Trial Simulation: Data Modeling, Validation, and Analysis with SQL and R**

---

## 🔗 Project Files
- [SQL Script: clinical_simulation.sql](https://github.com/abigailcabadin/clinical-trial-simulation-part1/blob/main/clinical_simulation.sql)  
- [R Script: clin_trial_sim.R](https://github.com/abigailcabadin/clinical-trial-simulation-part1/blob/main/clin_trial_sim.R)  

## 1. Introduction
Clinical trials generate complex datasets that must be carefully structured, validated, and analyzed to ensure reliable insights into safety and efficacy. This project simulates a mid‑sized clinical trial using synthetic data generated in **R** and stored in a **MySQL relational database**.  

The goal of Part 1 is to demonstrate:
- End‑to‑end **data engineering** (schema design, data loading, validation)  
- **Data analysis** using SQL queries to answer clinical questions  
- **Safety signal detection** through adverse event (AE) and laboratory data review  

This foundation sets the stage for Part 2 (visualization and reporting in Power BI).

---

## 2. Methods

### 2.1 Data Generation
Synthetic datasets were created in **R** to simulate:
- 5,000 patients across multiple sites  
- Randomization to **Placebo** or **DrugA** arms  
- Treatment doses (0 mg for Placebo; 50, 100, 150 mg for DrugA)  
- Scheduled visits (~5 per patient)  
- Laboratory results (ALT, AST, CRP) with reference ranges  
- Adverse events with severity (Mild, Moderate, Severe)  

### 2.2 Database Schema
A normalized schema was designed in **MySQL** with the following tables:

| Table           | Description |
|-----------------|-------------|
| **Patients**    | Demographics, enrollment dates |
| **Treatments**  | Randomization, dose, treatment dates |
| **Visits**      | Scheduled visits per patient |
| **LabResults**  | ALT, AST, CRP values per visit |
| **AdverseEvents** | Safety events with severity and outcome |

### 2.3 Validation Queries
SQL queries were written to check:
- Row counts and completeness  
- Referential integrity (no orphan records)  
- Logical consistency (e.g., Placebo = 0 mg dose)  
- Temporal checks (visits after enrollment)  
- Missing values  

### 2.4 Analysis Queries
SQL was used to answer key clinical questions:
- Patient distribution by arm  
- Visit compliance  
- Lab averages and abnormal values  
- Adverse event counts, percentages, and incidence per patient  
- ALT shifts from baseline  

---

## 3. Analyst’s Notes – Data Validation & Initial Findings
- **Data Volume & Structure**  
  - Patients: 5,000; Treatments: 5,000; Visits: 24,763 (~5 per patient); Lab Results: 51,159 (~2 per visit); Adverse Events: 3,050 (~0.6 per patient).  
  - *Interpretation:* Dataset size and structure are consistent with a mid‑sized trial.  

- **Demographics & Randomization**  
  - Balanced male/female distribution, multiple sites.  
  - Placebo patients always Dose = 0; DrugA patients valid doses (50/100/150 mg).  
  - *Interpretation:* Randomization and dosing logic are correct.  

- **Visit & Lab Integrity**  
  - Labs correctly tied to visits; no orphan lab records.  
  - *Interpretation:* Visit–lab relationships intact.  

- **Adverse Events Snapshot (from AE_Summary view)**  

  | Arm     | Mild | Moderate | Severe |
  |---------|------|----------|--------|
  | Placebo | 934  | 464      | 150    |
  | DrugA   | 879  | 460      | 163    |  

  - *Interpretation:* Similar AE distributions; DrugA slightly more severe AEs.  

- **Data Quality Checks**  
  - No missing doses; no orphan AEs.  
  - 17 visits occurred before enrollment → realistic “dirty data” scenario.  
  - *Interpretation:* Strong integrity overall, with one data cleaning issue.  

---

## 4.  Analysis Results & Interpretation

### 4.1 Patients per Treatment Arm
- Placebo: 2,488  
- DrugA: 2,512  

**Interpretation:** Randomization is well balanced (almost 50/50 split).

---

### 4.2 Average Number of Visits per Patient
- Average visits: 4.95  

**Interpretation:** Patients attended ~5 visits on average, consistent with protocol adherence.

---

### 4.3 Lab Test Averages by Arm
| Arm     | ALT   | AST   | CRP   |
|---------|-------|-------|-------|
| Placebo | 27.06 | 23.45 | 2.96  |
| DrugA   | 26.81 | 23.52 | 2.99  |

**Interpretation:**  
- Mean ALT, AST, and CRP values are very similar between arms.  
- No obvious group‑level lab abnormalities.  
- Suggests DrugA does not dramatically shift average lab values compared to Placebo.

---

### 4.4 Adverse Events by Severity and Arm
| Arm     | Mild | Moderate | Severe |
|---------|------|----------|--------|
| Placebo | 934  | 464      | 150    |
| DrugA   | 879  | 460      | 163    |

**Interpretation:**  
- Both arms have similar AE distributions.  
- DrugA shows slightly more Severe AEs (163 vs 150).  
- Placebo has slightly more Mild AEs.  

---

### 4.5 Abnormal Lab Values
Examples:  
- SUBJ00001: AST = 41.43 (above upper limit 40.00)  
- SUBJ00002: AST = 6.17 (below lower limit 10.00)  
- SUBJ00003: ALT = -0.77 (invalid negative value)  
- SUBJ00007: CRP = 5.49 (above upper limit 5.00)  

**Interpretation:**  
- Abnormal labs are present, as expected in real data.  
- Negative ALT values are biologically impossible → data quality issue.  
- Highlights the importance of data cleaning and medical review.

---

### 4.6 ALT Shift from Baseline
- Placebo: +2.03 U/L  
- DrugA: +1.89 U/L  

**Interpretation:**  
- Both arms show small increases from baseline.  
- No meaningful difference between DrugA and Placebo.  
- Suggests DrugA does not cause significant ALT elevation at the group level.

---

### 4.7 AE Percentages by Severity
| Arm     | % Mild | % Moderate | % Severe |
|---------|--------|------------|----------|
| Placebo | 58.6%  | 29.1%      | 9.4%     |
| DrugA   | 56.0%  | 29.3%      | 10.4%    |

**Interpretation:** Mild/Moderate dominate; DrugA has a modest increase in severe AEs.

---

### 4.8 AE Incidence per Patient
| Arm     | % with Mild AE | % with Moderate AE | % with Severe AE |
|---------|----------------|--------------------|------------------|
| Placebo | 31.6%          | 16.6%              | 5.8%             |
| DrugA   | 29.8%          | 16.8%              | 6.2%             |

**Interpretation:** Similar proportions overall; DrugA slightly higher severe AE incidence.

---

### 4.9 Overall AE Incidence
| Arm     | Patients w/ ≥1 AE | % of Patients |
|---------|-------------------|----------------|
| Placebo | 1,149             | 46.2%          |
| DrugA   | 1,144             | 45.5%          |

**Interpretation:** Nearly half of patients in both arms experienced ≥1 AE. Overall tolerability is comparable.

---

### Key Takeaways (Analyst’s Summary)
- **Balanced randomization:** Placebo and DrugA arms are nearly equal in size.  
- **Strong compliance:** Patients averaged ~5 visits, consistent with protocol.  
- **Lab results:** Group averages are stable across arms, no major safety signal.  
- **Adverse events:** Distribution is similar, with DrugA showing slightly more severe cases.  
- **Abnormal labs:** Present and realistic, including biologically implausible values (negative ALT).  
- **ALT shifts:** Minimal and comparable between arms, suggesting no drug‑induced liver signal.  

---

## 5. Discussion
- **Randomization and compliance** were strong, reflecting a well‑designed trial.  
- **Lab results** showed no major differences between arms, though data quality issues (negative values, early visits) were detected.  
- **Adverse events** were broadly similar between arms, with a slight increase in severe AEs for DrugA.  
- **Overall AE incidence** was nearly identical, suggesting comparable tolerability.  

This mirrors real‑world clinical trial challenges: balancing safety signals against background noise, and ensuring data quality.

---

## 6. Conclusion
Part 1 of the ClinicalSim Capstone successfully demonstrated:
- **Data generation** in R  
- **Relational schema design** in MySQL  
- **Validation queries** to ensure data integrity  
- **Analysis queries** to extract clinical insights  


