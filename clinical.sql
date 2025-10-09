CREATE DATABASE ClinicalSim;
USE ClinicalSim;

#Creating tables

#Patients
CREATE TABLE Patients(
	PatientID VARCHAR(20) PRIMARY KEY,
	SiteID VARCHAR(10) NOT NULL,
	Sex ENUM('Male', 'Female') NOT NULL,
	DOB DATE NOT NULL,
	EnrollmentDate DATE NOT NULL
);

# Treatments
CREATE TABLE Treatments (
  TreatmentID VARCHAR(20) PRIMARY KEY,
  PatientID VARCHAR(20) NOT NULL,
  Arm ENUM('Placebo','DrugA') NOT NULL,
  DoseMg INT CHECK (DoseMg >= 0),
  StartDate DATE NOT NULL,
  EndDate DATE,
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

#VISITS
CREATE TABLE Visits (
  VisitID VARCHAR(30) PRIMARY KEY,
  PatientID VARCHAR(20) NOT NULL,
  VisitDate DATE NOT NULL,
  VisitNum INT NOT NULL,
  VisitType VARCHAR(30),
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID)
);

#Lab Results
CREATE TABLE LabResults (
  LabID VARCHAR(40) PRIMARY KEY,
  PatientID VARCHAR(20) NOT NULL,
  VisitID VARCHAR(30) NOT NULL,
  TestCode VARCHAR(20) NOT NULL,
  ResultValue DECIMAL(8,2) NOT NULL,
  Units VARCHAR(20),
  LowRef DECIMAL(8,2),
  HighRef DECIMAL(8,2),
  FOREIGN KEY (PatientID) REFERENCES Patients(PatientID),
  FOREIGN KEY (VisitID) REFERENCES Visits(VisitID)
);

#Adverse Events
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

LOAD DATA LOCAL INFILE 'C:/Users/abiga/OneDrive/Documents/SELF-STUDY FILES/Projects/New folder/Patients.csv'
INTO TABLE Patients
FIELDS TERMINATED BY ','
IGNORE 1 ROWS;

