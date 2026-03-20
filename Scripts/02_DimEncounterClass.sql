-- ============================================
-- DimEncounterClass: 6 encounter types
-- Hardcoded with clinical sort order
-- Run SECOND
-- ============================================

CREATE TABLE DimEncounterClass (
    EncounterClass  VARCHAR(50) PRIMARY KEY,
    SortOrder       INT
);

INSERT INTO DimEncounterClass (EncounterClass, SortOrder)
VALUES
    ('Emergency', 1),
    ('Urgentcare', 2),
    ('Inpatient', 3),
    ('Outpatient', 4),
    ('Ambulatory', 5),
    ('Wellness', 6);
