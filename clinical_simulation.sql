CREATE DATABASE ClinicalSim;
USE ClinicalSim;

#CREATING TABLES
###Patients
CREATE TABLE Patients(
	PatientID VARCHAR(20) PRIMARY KEY,
	SiteID VARCHAR(10) NOT NULL,
	Sex ENUM('Male', 'Female') NOT NULL,
	DOB DATE NOT NULL,
	EnrollmentDate DATE NOT NULL
);

### TREATMENTS
CREATE TABLE Treatments (
  TreatmentID VARCHAR(20) PRIMARY KEY,
  PatientID VARCHAR(20) NOT NULL,
  Arm ENUM('Placebo','DrugA') NOT NULL,
  DoseMg INT CHECK (DoseMg >= 0),
  StartDate DATE NOT NULL,
  EndDate DATE,
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

### VISITS
CREATE TABLE Visits (
  VisitID VARCHAR(30) PRIMARY KEY,
  PatientID VARCHAR(20) NOT NULL,
  VisitDate DATE NOT NULL,
  VisitNum INT NOT NULL,
  VisitType VARCHAR(30),
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

### LAB RESULTS
CREATE TABLE LabResults (
  LabID INT AUTO_INCREMENT PRIMARY KEY,   -- optional surrogate key
  VisitID VARCHAR(20) NOT NULL,
  PatientID VARCHAR(20) NOT NULL,
  VisitDate DATE,
  VisitNum INT,
  VisitType VARCHAR(50),
  TestCode VARCHAR(20),
  Units VARCHAR(20),
  LowRef DECIMAL(10,2),
  HighRef DECIMAL(10,2),
  Arm VARCHAR(20),
  baseline_alt DECIMAL(10,2),
  baseline_ast DECIMAL(10,2),
  baseline_crp DECIMAL(10,2),
  trt_shift VARCHAR(20),
  alt DECIMAL(10,2),
  ast DECIMAL(10,2),
  crp DECIMAL(10,2),
  ResultValue DECIMAL(10,2),
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
  FOREIGN KEY (VisitID) REFERENCES Visits(VisitID)
);

### ADVERSE EVENTS
CREATE TABLE AdverseEvents (
  AEID VARCHAR(40) PRIMARY KEY,
  PatientID VARCHAR(20) NOT NULL,
  EventTerm VARCHAR(100) NOT NULL,
  Severity ENUM('Mild','Moderate','Severe') NOT NULL,
  SeriousYN ENUM('Y','N') NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE,
  Outcome VARCHAR(20),
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

#QUICK VALIDATION QUERIES
#Check ROW counts
SELECT COUNT(*) FROM Patients;
SELECT COUNT(*) FROM Treatments;
SELECT COUNT(*) FROM Visits;
SELECT COUNT(*) FROM labresults;
SELECT COUNT(*) FROM AdverseEvents; 

SELECT * FROM Patients LIMIT 5; 

#Relationship Checks
#Patients and Treatments
SELECT p.PatientID, p.Sex, t.Arm, t.DoseMg
FROM Patients p
JOIN Treatments t ON p.PatientID = t.PatientID
LIMIT 5;

#Visits and LabResults
SELECT v.VisitID, v.PatientID, v.VisitDate, l.TestCode, l.ResultValue
FROM Visits v
JOIN LabResults l ON v.VisitID = l.VisitID
LIMIT 5;

#Adverse Events by Arm
SELECT t.Arm, a.Severity, COUNT(*) AS AE_Count
FROM Treatments t
JOIN AdverseEvents a ON t.PatientID = a.PatientID
GROUP BY t.Arm, a.Severity;

#Data Validation
SELECT l.VisitID
FROM LabResults l
LEFT JOIN Visits v ON l.VisitID = v.VisitID
WHERE v.VisitID IS NULL;

SELECT a.PatientID
FROM AdverseEvents a
LEFT JOIN Patients p ON a.PatientID = p.PatientID
WHERE p.PatientID IS NULL;

SELECT Arm, DoseMg, COUNT(*) 
FROM Treatments
GROUP BY Arm, DoseMg;

SELECT v.PatientID, v.VisitDate, p.EnrollmentDate
FROM Visits v
JOIN Patients p ON v.PatientID = p.PatientID
WHERE v.VisitDate < p.EnrollmentDate;

SELECT COUNT(*) AS MissingDose
FROM Treatments
WHERE DoseMg IS NULL;

#Data Analysis Queries
#Patients per treatment arm
SELECT Arm, COUNT(*) AS PatientCount
FROM Treatments
GROUP BY Arm;

#Average number of visits per patients
SELECT AVG(VisitCount) AS AvgVisits
FROM (
  SELECT PatientID, COUNT(*) AS VisitCount
  FROM Visits
  GROUP BY PatientID
) t;

#Lab test average by arm
SELECT t.Arm, l.TestCode, AVG(l.ResultValue) AS AvgResult
FROM LabResults l
JOIN Treatments t ON l.PatientID = t.PatientID
GROUP BY t.Arm, l.TestCode;

#Adverse events by severity and arm
SELECT t.Arm, a.Severity, COUNT(*) AS AE_Count
FROM Treatments t
JOIN AdverseEvents a ON t.PatientID = a.PatientID
GROUP BY t.Arm, a.Severity;

#Identify patients with abnormal labs
SELECT l.PatientID, l.TestCode, l.ResultValue, l.LowRef, l.HighRef
FROM LabResults l
WHERE l.ResultValue < l.LowRef OR l.ResultValue > l.HighRef;

#Compare ALT lab shifts between Placebo vs DrugA
SELECT t.Arm, AVG(l.alt - l.baseline_alt) AS Avg_ALT_Shift
FROM LabResults l
JOIN Treatments t ON l.PatientID = t.PatientID
GROUP BY t.Arm;

#The AE_Summary View 
CREATE VIEW AE_Summary AS
SELECT t.Arm, a.Severity, COUNT(*) AS AE_Count
FROM Treatments t
JOIN AdverseEvents a ON t.PatientID = a.PatientID
GROUP BY t.Arm, a.Severity;

#
SELECT * FROM AE_Summary;
#FILTER BY ARM
SELECT * FROM AE_Summary WHERE Arm = 'DrugA';
#PIVOT BY SEVERITY
SELECT Arm,
  SUM(CASE WHEN Severity = 'Mild' THEN AE_Count ELSE 0 END) AS Mild_AEs,
  SUM(CASE WHEN Severity = 'Moderate' THEN AE_Count ELSE 0 END) AS Moderate_AEs,
  SUM(CASE WHEN Severity = 'Severe' THEN AE_Count ELSE 0 END) AS Severe_AEs
FROM AE_Summary
GROUP BY Arm;

#QUERY FOR PERCENTAGES
SELECT 
    Arm,
    SUM(CASE WHEN Severity = 'Mild' THEN AE_Count ELSE 0 END) AS Mild_AEs,
    ROUND(SUM(CASE WHEN Severity = 'Mild' THEN AE_Count ELSE 0 END) * 100.0 / SUM(AE_Count), 2) AS Mild_Pct,
    SUM(CASE WHEN Severity = 'Moderate' THEN AE_Count ELSE 0 END) AS Moderate_AEs,
    ROUND(SUM(CASE WHEN Severity = 'Moderate' THEN AE_Count ELSE 0 END) * 100.0 / SUM(AE_Count), 2) AS Moderate_Pct,
    SUM(CASE WHEN Severity = 'Severe' THEN AE_Count ELSE 0 END) AS Severe_AEs,
    ROUND(SUM(CASE WHEN Severity = 'Severe' THEN AE_Count ELSE 0 END) * 100.0 / SUM(AE_Count), 2) AS Severe_Pct
FROM AE_Summary
GROUP BY Arm;

#Patients with ≥1 AE by SeveritY
SELECT 
    t.Arm,
    COUNT(DISTINCT CASE WHEN a.Severity = 'Mild' THEN a.PatientID END) AS Patients_With_Mild,
    ROUND(COUNT(DISTINCT CASE WHEN a.Severity = 'Mild' THEN a.PatientID END) * 100.0 / COUNT(DISTINCT t.PatientID), 2) AS Mild_Pct,
    
    COUNT(DISTINCT CASE WHEN a.Severity = 'Moderate' THEN a.PatientID END) AS Patients_With_Moderate,
    ROUND(COUNT(DISTINCT CASE WHEN a.Severity = 'Moderate' THEN a.PatientID END) * 100.0 / COUNT(DISTINCT t.PatientID), 2) AS Moderate_Pct,
    
    COUNT(DISTINCT CASE WHEN a.Severity = 'Severe' THEN a.PatientID END) AS Patients_With_Severe,
    ROUND(COUNT(DISTINCT CASE WHEN a.Severity = 'Severe' THEN a.PatientID END) * 100.0 / COUNT(DISTINCT t.PatientID), 2) AS Severe_Pct
FROM Treatments t
LEFT JOIN AdverseEvents a ON t.PatientID = a.PatientID
GROUP BY t.Arm;

#Overall AE Incidence
SELECT 
    t.Arm,
    COUNT(DISTINCT a.PatientID) AS Patients_With_AE,
    ROUND(COUNT(DISTINCT a.PatientID) * 100.0 / COUNT(DISTINCT t.PatientID), 2) AS AE_Incidence_Pct
FROM Treatments t
LEFT JOIN AdverseEvents a ON t.PatientID = a.PatientID
GROUP BY t.Arm;


#THE INDEXES
CREATE INDEX idx_patient ON LabResults(PatientID);
CREATE INDEX idx_visit ON LabResults(VisitID);

SHOW INDEXES FROM LabResults;





