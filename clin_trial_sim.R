#installing of required packages
install.packages("dplyr")
install.packages("tidyr")

#load library
library(dplyr)
library(tidyr)

set.seed(42)

#PARAMETERS
n_patients <-5000
sites <- paste0("SITE", sprintf("%03d", 1:20))
arms <- c("Placebo", "DrugA")
sexes <- c("Male", "Female")
visit_schedule <- data.frame(
  VisitNum = c(0,1,2,3,4),
  VisitType = c("Screening", "Baseline", "Week4", "Week8", "EOT"),
  DaysFromEnroll = c(-14,0,28,56,84)
)

#PATIENTS TABLE
Patients <- data.frame(
  PatientID = paste0("SUBJ", sprintf("%05d", 1:n_patients)),
  SiteID = sample(sites, n_patients, replace = TRUE),
  Sex = sample(sexes, n_patients, replace = TRUE, prob = c(0.48, 0.52)),
  DOB = as.Date("1950-01-01") + sample(0:25000, n_patients, replace = TRUE),
  EnrollmentDate = as.Date("2023-01-01") + sample(0:200, n_patients, replace = TRUE)
)

#Treatments Table
Treatments <- Patients %>%
  transmute(
    TreatmentID = paste0("TRT", PatientID),
    PatientID,
    Arm = sample(arms, n(), replace = TRUE),
    DoseMg = ifelse(Arm == "Placebo", 0, sample(c(50,100,150), n(), replace = TRUE)),
    StartDate = EnrollmentDate,
    EndDate = EnrollmentDate
  )

#Visits Table
Visits <- Patients %>%
  inner_join(visit_schedule, by = character()) %>%
  transmute(
    VisitID = paste0("VIS", PatientID, "_", VisitNum),
    PatientID,
    VisitDate = EnrollmentDate + DaysFromEnroll,
    VisitNum,
    VisitType = VisitType
  ) %>%
  group_by(PatientID) %>%
  filter(!(VisitType %in% sample(c("Week4", "Week8"), 1) & runif(n()) < 0.05)) %>%
  ungroup()

#Lab Test Results
tests <- data.frame(
  TestCode = c("ALT", "AST", "CRP"),
  Units = c("U/L", "U/L", "mg/L"),
  LowRef = c(7, 10, 0),
  HighRef = c(56, 40, 5)
)

LabResults <- Visits %>%
  inner_join(tests, by = character()) %>%
  left_join(Treatments %>% select(PatientID, Arm), by = "PatientID") %>%
  rowwise() %>%
  mutate(
    baseline_alt = rnorm(1, mean = 25, sd = 8),
    baseline_ast = rnorm(1, mean = 22, sd = 7),
    baseline_crp = rlnorm(1, meanlog = log(3), sdlog = 0.4),
    trt_shift = ifelse(Arm == "DrugA", 1, 0),
    alt = baseline_alt + trt_shift * (VisitNum * 2) + rnorm(1, 0, 5),
    ast = baseline_ast + trt_shift * (VisitNum * 1.5) + rnorm(1, 0, 4),
    crp = pmax(0, baseline_crp - trt_shift * (VisitNum * 0.3) + rnorm(1, 0, 0.5)),
    ResultValue = case_when(
      TestCode == "ALT" ~ alt,
      TestCode == "AST" ~ ast,
      TestCode == "CRP" ~ crp
    )
  )

#Adverse Events Table
ae_terms <- c("Headache", "Nausea", "Fatigue", "Rash", "ALT increased", "AST increased")
severity <- c("Mild", "Moderate", "Severe")

AE_counts <- data.frame(
  PatientID = Patients$PatientID,
  nAE = rpois(nrow(Patients), lambda = 0.6)
)

library(dplyr)
library(purrr)

AdverseEvents <- AE_counts %>%
  rowwise() %>%
  mutate(
    AE = list(
      if (nAE == 0) {
        NULL
      } else {
        enroll <- Patients$EnrollmentDate[Patients$PatientID == PatientID]
        data.frame(
          AEID = paste0("AE", PatientID, "_", seq_len(nAE)),
          PatientID = PatientID,
          EventTerm = sample(ae_terms, nAE, replace = TRUE),
          Severity = sample(severity, nAE, replace = TRUE, prob = c(0.6, 0.3, 0.1)),
          SeriousYN = sample(c("Y", "N"), nAE, replace = TRUE, prob = c(0.1, 0.9)),
          StartDate = enroll + sample(0:70, nAE, replace = TRUE),
          EndDate = enroll + sample(5:100, nAE, replace = TRUE),
          Outcome = sample(
            c("Recovered","Recovering","NotRecovered","Fatal","Unknown"),
            nAE, replace = TRUE, prob = c(0.6,0.2,0.15,0.01,0.04)
          )
        )
      }
    )
  ) %>%
  ungroup() %>%
  select(AE) %>%
  unnest(AE)

#Summary
summary_counts <- list(
  Patients = nrow(Patients),
  Visits = nrow(Visits),
  Treatments = nrow(Treatments),
  LabResults = nrow(LabResults),
  AdverseEvents = nrow(AdverseEvents)
)
print(summary_counts)

#Save CSVs
write.csv(Patients, "Patients.csv", row.names = FALSE)
write.csv(Visits, "Visits.csv", row.names = FALSE)
write.csv(Treatments, "Treatments.csv", row.names = FALSE)
write.csv(LabResults, "LabResults.csv", row.names = FALSE)
write.csv(AdverseEvents, "AdverseEvents.csv", row.names = FALSE)

getwd()

write.csv(Treatments, "Treatments.csv", row.names = FALSE)
