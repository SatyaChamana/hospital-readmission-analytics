-- ============================================
-- FactEncounters: Central fact table
-- Adds: EncounterDate, LengthOfStay, 30-day readmission flag
-- Uses LEAD() window function for readmission detection
-- [Start] and [Stop] are bracketed because they are reserved words
-- Run FIFTH
-- ============================================

CREATE TABLE FactEncounters (
    EncounterID         VARCHAR(50) PRIMARY KEY,
    PatientID           VARCHAR(50),
    PayerID             VARCHAR(50),
    EncounterDate       DATE,
    EncounterClass      VARCHAR(50),
    EncounterCode       VARCHAR(20),
    Description         VARCHAR(500),
    StartDateTime       DATETIME2,
    StopDateTime        DATETIME2,
    Base_Encounter_Cost DECIMAL(18,2),
    Total_Claim_Cost    DECIMAL(18,2),
    Payer_Coverage      DECIMAL(18,2),
    ReasonCode          VARCHAR(50),
    ReasonDescription   VARCHAR(500),
    LengthOfStay_Hours  DECIMAL(10,2),
    Is30DayReadmission  INT
);

;WITH EncounterSequence AS (
    SELECT
        Id,
        Patient,
        Payer,
        CAST([Start] AS DATE) AS EncounterDate,
        EncounterClass,
        Code,
        Description,
        CAST([Start] AS DATETIME2) AS StartDateTime,
        CAST([Stop] AS DATETIME2) AS StopDateTime,
        Base_Encounter_Cost,
        Total_Claim_Cost,
        Payer_Coverage,
        ReasonCode,
        ReasonDescription,

        -- LengthOfStay in hours using MINUTE then dividing by 60
        ROUND(DATEDIFF(MINUTE, [Start], [Stop]) / 60.0, 2) AS LengthOfStay_Hours,

        -- LEAD peeks at the next encounter date for this patient
        -- PARTITION BY Patient = restart window per patient
        -- ORDER BY [Start] = chronological within each patient
        LEAD(CAST([Start] AS DATE)) OVER (
            PARTITION BY Patient
            ORDER BY [Start]
        ) AS NextEncounterDate

    FROM encounters
)
INSERT INTO FactEncounters
SELECT
    Id,
    Patient,
    Payer,
    EncounterDate,
    EncounterClass,
    Code,
    Description,
    StartDateTime,
    StopDateTime,
    Base_Encounter_Cost,
    Total_Claim_Cost,
    Payer_Coverage,
    ReasonCode,
    ReasonDescription,
    LengthOfStay_Hours,

    -- 30-day readmission flag
    -- Only flags clinical encounters (not wellness checkups)
    CASE
        WHEN NextEncounterDate IS NOT NULL
         AND DATEDIFF(DAY, EncounterDate, NextEncounterDate) <= 30
         AND EncounterClass IN ('inpatient', 'emergency', 'urgentcare')
        THEN 1
        ELSE 0
    END

FROM EncounterSequence;
