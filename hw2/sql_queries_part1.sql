/*
 Query 1 : Average length of stay in ICU By Diagnosis
 Tables required : Icustays, Diagnosis_Icd, D_icd_diagnosis
 This query helps identify which diagnoses are associated with the longest ICU stays, which can be useful for resource planning and patient care strategies.
 Septic myocarditis is associated wth the highest average length of stay, followed by Nasal mucositis and instantaneous death, this means these 2 diagnosis need moe ICU care.
 */
SELECT d.LONG_TITLE AS Diagnosis,
       ROUND(AVG(i.LOS), 2) AS Avg_ICU_Length_of_Stay
FROM ICUSTAYS i
JOIN DIAGNOSES_ICD d_icd ON i.HADM_ID = d_icd.HADM_ID
JOIN D_ICD_DIAGNOSES d ON d_icd.ICD9_CODE = d.ICD9_CODE
GROUP BY d.LONG_TITLE
ORDER BY Avg_ICU_Length_of_Stay DESC
LIMIT 10;

/*
 Query 2 : Readmission Rate by Age Group
 Tables required : Patients, Admissions
 This query shows how readmission rates vary by age, helping to identify which age groups are more likely to be readmitted.
 The maximum number of readmitted patients are Under 40, which might represent a transitional phase with increasing chronic diseases like hypertension or obesity, making them vulnerable to readmissions.
 An actionable insight would be to expand screening and management programs for preventable conditions like hypertension and high cholesterol, especially in middle-aged populations.
 */
WITH Readmissions AS (
    SELECT SUBJECT_ID, COUNT(HADM_ID) AS Admission_Count
    FROM ADMISSIONS
    GROUP BY SUBJECT_ID
    HAVING COUNT(HADM_ID) > 1
)
SELECT
    CASE
        WHEN AGE(p.DOB)::TEXT >= '80 years' THEN '80+'
        WHEN AGE(p.DOB)::TEXT >= '60 years' THEN '60-79'
        WHEN AGE(p.DOB)::TEXT >= '40 years' THEN '40-59'
        ELSE 'Under 40'
    END AS Age_Group,
    COUNT(r.SUBJECT_ID) AS Readmitted_Patients,
    COUNT(DISTINCT p.SUBJECT_ID) AS Total_Patients,
    ROUND(100 * COUNT(r.SUBJECT_ID) / COUNT(DISTINCT p.SUBJECT_ID), 2) AS Readmission_Rate
FROM PATIENTS p
LEFT JOIN Readmissions r ON p.SUBJECT_ID = r.SUBJECT_ID
GROUP BY Age_Group
ORDER BY Readmission_Rate DESC;
/*
 Query 3 : Readmission Rate by Age Group
 Tables required : Patients, Admissions
 This query shows how readmission rates vary by age, helping to identify which age groups are more likely to be readmitted.
 The maximum number of readmitted patients are Under 40, which might represent a transitional phase with increasing chronic diseases like hypertension or obesity, making them vulnerable to readmissions.
 An actionable insight would be to expand screening and management programs for preventable conditions like hypertension and high cholesterol, especially in middle-aged populations.
 */
WITH Readmissions AS (
    SELECT SUBJECT_ID, COUNT(HADM_ID) AS Admission_Count
    FROM ADMISSIONS
    GROUP BY SUBJECT_ID
    HAVING COUNT(HADM_ID) > 1
)
SELECT
    CASE
        WHEN AGE(p.DOB)::TEXT >= '80 years' THEN '80+'
        WHEN AGE(p.DOB)::TEXT >= '60 years' THEN '60-79'
        WHEN AGE(p.DOB)::TEXT >= '40 years' THEN '40-59'
        ELSE 'Under 40'
    END AS Age_Group,
    COUNT(r.SUBJECT_ID) AS Readmitted_Patients,
    COUNT(DISTINCT p.SUBJECT_ID) AS Total_Patients,
    ROUND(100 * COUNT(r.SUBJECT_ID) / COUNT(DISTINCT p.SUBJECT_ID), 2) AS Readmission_Rate
FROM PATIENTS p
LEFT JOIN Readmissions r ON p.SUBJECT_ID = r.SUBJECT_ID
GROUP BY Age_Group
ORDER BY Readmission_Rate DESC;

/*
 Query 3 : Top 10 Most Frequent Medical Procedures
Tables Used: PROCEDURES_ICD, D_ICD_DIAGNOSES
Key Insight:Insight: The Dominance of Poisoning Cases in the Dataset
The overwhelming prevalence of poisoning cases—with tetracycline poisoning (10,333 cases), chloral hydrate poisoning (9,100 cases), and paraldehyde poisoning (6,048 cases) accounting for nearly half of the top diagnoses—suggests a major public health issue related to substance exposure, overdose, or misuse.
 */

SELECT d.LONG_TITLE AS Procedure_Name,
       COUNT(p.ICD9_CODE) AS Procedure_Count
FROM PROCEDURES_ICD p
JOIN D_ICD_DIAGNOSES d ON p.ICD9_CODE = d.ICD9_CODE
GROUP BY d.LONG_TITLE
ORDER BY Procedure_Count DESC
LIMIT 10;

/*
 Query 4 : Mortality Rate by Admission Type
Tables Used: ADMISSIONS, PATIENTS
Key Insight: Urgent Admissions Have the Highest Mortality Rate (51%)
Despite being fewer in number (1,336 cases), urgent admissions have the highest mortality rate (51%), indicating that these patients arrive in extremely critical condition with a very high risk of death.

 */

SELECT a.ADMISSION_TYPE,
       COUNT(a.HADM_ID) AS Total_Admissions,
       SUM(p.EXPIRE_FLAG) AS Deaths,
       ROUND(100 * SUM(p.EXPIRE_FLAG) / COUNT(a.HADM_ID), 2) AS Mortality_Rate
FROM ADMISSIONS a
JOIN PATIENTS p ON a.SUBJECT_ID = p.SUBJECT_ID
GROUP BY a.ADMISSION_TYPE
ORDER BY Mortality_Rate DESC;

*
 Query 5 : Most Common Diagnoses for ICU Patients
Tables Used: ICUSTAYS, DIAGNOSES_ICD, D_ICD_DIAGNOSES
Key Insight: This query helps determine the most frequent medical conditions that require ICU care.
Cardiovascular Diseases Dominate ICU Admissions
The most frequent ICU diagnoses are hypertension (21,530 cases), congestive heart failure (14,226 cases), atrial fibrillation (14,048 cases), and coronary artery disease (13,107 cases), highlighting that cardiovascular conditions are the primary drivers of ICU admissions.
This underscores the critical burden of heart-related illnesses in intensive care, emphasizing the need for better prevention, early intervention, and cardiac care improvements.

 */
`SELECT d.LONG_TITLE AS Diagnosis,
       COUNT(di.ICD9_CODE) AS Occurrences
FROM ICUSTAYS i
JOIN DIAGNOSES_ICD di ON i.HADM_ID = di.HADM_ID
JOIN D_ICD_DIAGNOSES d ON di.ICD9_CODE = d.ICD9_CODE
GROUP BY d.LONG_TITLE
ORDER BY Occurrences DESC
LIMIT 10;`

/*
 Query 6 : ICU Admission Trends
Key Insight: Explore the trend of ICU admissions over time to understand seasonal or annual variations.
ICU admissions in 2100 saw a dramatic rise from June to September, peaking in August and September. This surge suggests a potential seasonal factor or public health event during that period.
 */

SELECT
    EXTRACT(YEAR FROM ic.INTIME) AS Year,
    EXTRACT(MONTH FROM ic.INTIME) AS Month,
    COUNT(*) AS ICU_Admissions
FROM ICUSTAYS ic
GROUP BY EXTRACT(YEAR FROM ic.INTIME), EXTRACT(MONTH FROM ic.INTIME)
ORDER BY Year, Month;


/*
 Query 7 : Mortality by Insurance Type
Key Insight: Identify if patients with specific types of insurance have higher mortality rates.
 Medicare Patients Have the Highest Mortality Rate (56%)
Medicare patients not only have the highest number of admissions (28,215) but also the highest mortality rate (56%), indicating that older or chronically ill patients face significantly higher risks of death in the hospital.
 */

SELECT
    a.INSURANCE,
    COUNT(a.HADM_ID) AS Total_Admissions,
    SUM(p.EXPIRE_FLAG) AS Deaths,
    ROUND(100 * SUM(p.EXPIRE_FLAG) / COUNT(a.HADM_ID), 2) AS Mortality_Rate
FROM ADMISSIONS a
JOIN PATIENTS p ON a.SUBJECT_ID = p.SUBJECT_ID
GROUP BY a.INSURANCE
ORDER BY Mortality_Rate DESC;

/*
 Query 8 : Average Procedure Duration by Service
Key Insight: Determine which hospital services require the longest average procedure durations.

ENT Procedures Have the Longest Average Duration (1794 Minutes / ~30 Hours)
Among all medical services, ENT (Ear, Nose, and Throat) procedures have the longest average duration (1794 minutes, ~30 hours), significantly higher than other specialties.
This suggests that ENT surgeries or treatments may be particularly complex, requiring prolonged operative or procedural time, potentially due to intricate anatomical structures, microsurgical techniques, or extensive reconstructive procedures.
 */
SELECT
    s.CURR_SERVICE,
    ROUND(AVG(EXTRACT(EPOCH FROM (pe.ENDTIME - pe.STARTTIME)) / 60), 2) AS Avg_Procedure_Duration
FROM PROCEDUREEVENTS_MV pe
JOIN SERVICES s ON pe.HADM_ID = s.HADM_ID
WHERE pe.ENDTIME IS NOT NULL
GROUP BY s.CURR_SERVICE
ORDER BY Avg_Procedure_Duration DESC;

/*
 Query 9 : Callouts by Service
Key Insight: Analyze which services generate the most callouts for patient transfers.
Medical (MED) Callouts Dominate Hospital Response Requests
The MED (General Medicine) service has the highest number of callouts (13,791), far exceeding all other specialties.
This suggests that the majority of urgent or specialized hospital response requests are for medical (non-surgical) conditions, likely involving critical internal medicine cases such as infections, cardiac issues, or respiratory distress.
 */

SELECT
    CALLOUT_SERVICE,
    COUNT(*) AS Callout_Count
FROM CALLOUT
GROUP BY CALLOUT_SERVICE
ORDER BY Callout_Count DESC;



