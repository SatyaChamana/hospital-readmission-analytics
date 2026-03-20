-- ============================================
-- DimPatient: One row per unique patient
-- Adds: FullName, Age, AgeBucket, IsDeceased
-- State is VARCHAR(50) to handle full state names
-- Run THIRD
-- ============================================

CREATE TABLE DimPatient (
    PatientID   VARCHAR(50) PRIMARY KEY,
    FullName    VARCHAR(200),
    Gender      VARCHAR(10),
    Race        VARCHAR(50),
    Ethnicity   VARCHAR(50),
    BirthDate   DATE,
    DeathDate   DATE,
    City        VARCHAR(100),
    State       VARCHAR(50),
    Zip         VARCHAR(20),
    Lat         FLOAT,
    Lon         FLOAT,
    Age         INT,
    AgeBucket   VARCHAR(20),
    IsDeceased  INT
);

INSERT INTO DimPatient
SELECT
    Id,
    CONCAT(First, ' ', Last),
    Gender,
    Race,
    Ethnicity,
    BirthDate,
    DeathDate,
    City,
    State,
    Zip,
    Lat,
    Lon,

    -- Age: if patient is deceased, calculate age at death
    -- If alive, calculate age as of today
    -- COALESCE returns the first non-null value
    DATEDIFF(YEAR, BirthDate, COALESCE(DeathDate, GETDATE())),

    -- AgeBucket: groups patients into clinical age ranges
    CASE
        WHEN DATEDIFF(YEAR, BirthDate, COALESCE(DeathDate, GETDATE())) < 18  THEN 'Under 18'
        WHEN DATEDIFF(YEAR, BirthDate, COALESCE(DeathDate, GETDATE())) <= 34 THEN '18-34'
        WHEN DATEDIFF(YEAR, BirthDate, COALESCE(DeathDate, GETDATE())) <= 49 THEN '35-49'
        WHEN DATEDIFF(YEAR, BirthDate, COALESCE(DeathDate, GETDATE())) <= 64 THEN '50-64'
        ELSE '65+'
    END,

    -- IsDeceased: 1 if patient has a death date, 0 if alive
    CASE WHEN DeathDate IS NOT NULL THEN 1 ELSE 0 END

FROM patients;
