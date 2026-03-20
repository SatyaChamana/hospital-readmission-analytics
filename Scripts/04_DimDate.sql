-- ============================================
-- DimDate: One row per calendar day (2011-2022)
-- Generated from scratch using recursive CTE
-- Required for ALL DAX time intelligence
-- Run FOURTH
-- ============================================

CREATE TABLE DimDate (
    Date        DATE PRIMARY KEY,
    Year        INT,
    Quarter     INT,
    MonthNum    INT,
    MonthName   VARCHAR(20),
    WeekOfYear  INT,
    DayOfMonth  INT,
    DayOfWeek   INT,
    DayName     VARCHAR(20),
    IsWeekend   INT,
    FiscalYear  INT
);

-- Recursive CTE generates every date from 2011-01-01 to 2022-12-31
-- MAXRECURSION 5000 is needed because default limit is 100
-- We have ~4,383 days so we set it higher

;WITH DateSpine AS (
    SELECT CAST('2011-01-01' AS DATE) AS dt

    UNION ALL

    SELECT DATEADD(DAY, 1, dt)
    FROM DateSpine
    WHERE dt < '2022-12-31'
)
INSERT INTO DimDate
SELECT
    dt,
    YEAR(dt),
    DATEPART(QUARTER, dt),
    MONTH(dt),
    DATENAME(MONTH, dt),
    DATEPART(WEEK, dt),
    DAY(dt),
    DATEPART(WEEKDAY, dt),
    DATENAME(WEEKDAY, dt),
    CASE WHEN DATEPART(WEEKDAY, dt) IN (1, 7) THEN 1 ELSE 0 END,

    -- Fiscal year: if month >= July, fiscal year = calendar year + 1
    CASE WHEN MONTH(dt) >= 7 THEN YEAR(dt) + 1 ELSE YEAR(dt) END

FROM DateSpine
OPTION (MAXRECURSION 5000);
