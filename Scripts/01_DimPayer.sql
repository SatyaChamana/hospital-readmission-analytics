-- ============================================
-- DimPayer: Insurance provider dimension
-- 10 rows with derived InsuranceStatus column
-- Run this FIRST
-- ============================================

CREATE TABLE DimPayer (
    PayerID         VARCHAR(50) PRIMARY KEY,
    Name            VARCHAR(100),
    InsuranceStatus VARCHAR(30)
);

INSERT INTO DimPayer (PayerID, Name, InsuranceStatus)
SELECT
    Id,
    Name,
    CASE
        WHEN Name = 'NO_INSURANCE' THEN 'Uninsured'
        ELSE 'Insured'
    END
FROM payers;
