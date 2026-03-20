-- ============================================
-- FactProcedures: Secondary fact table
-- One row per procedure performed during an encounter
-- Links to FactEncounters via EncounterID
-- [Start] and [Stop] are bracketed because they are reserved words
-- Run SIXTH
-- ============================================

CREATE TABLE FactProcedures (
    PatientID           VARCHAR(50),
    EncounterID         VARCHAR(50),
    ProcedureCode       VARCHAR(50),
    Description         VARCHAR(500),
    Base_Cost           DECIMAL(18,2),
    ReasonCode          VARCHAR(50),
    ReasonDescription   VARCHAR(500),
    ProcedureStart      DATETIME2,
    ProcedureStop       DATETIME2,
    Duration_Minutes    DECIMAL(10,2)
);

INSERT INTO FactProcedures
SELECT
    Patient,
    Encounter,
    Code,
    Description,
    Base_Cost,
    ReasonCode,
    ReasonDescription,
    CAST([Start] AS DATETIME2),
    CAST([Stop] AS DATETIME2),

    -- Procedure duration in minutes
    -- Some procedures have NULL stop times, handled with CASE
    CASE
        WHEN [Stop] IS NOT NULL
        THEN ROUND(DATEDIFF(MINUTE, [Start], [Stop]) / 1.0, 2)
        ELSE NULL
    END

FROM procedures;
