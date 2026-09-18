-- 20556 · Tirsdag · Version 1.0
-- TODO: Implementér dim_zone og dim_date ud fra din dokumenterede model.
-- Dimensionerne skal kunne bruges til både pickup og dropoff.
-- Begrund nøgler og attributter. Undersøg, om nøglerne er entydige,
-- og om datodimensionen dækker begge roller i de faktiske data.
-- Bevar raw-input uændret. Skriv selv SQL og relevante kontroller.


CREATE OR REPLACE TABLE dim_date AS
SELECT
    CAST(strftime(date, '%Y%m%d') AS INTEGER) AS date_key,
    date,
    YEAR(date) AS year,
    MONTH(date) AS month,
    MONTHNAME(date) AS month_name,
    DAY(date) AS day,
    DAYOFWEEK(date) AS day_of_week,
    DAYNAME(date) AS day_name,

CASE 
    WHEN DAYOFWEEK(date) IN (0, 6) THEN TRUE
    ELSE FALSE
END AS is_weekend

FROM generate_series(
    DATE '2025-01-01',
    DATE '2025-12-31',
    INTERVAL '1 day'
) AS t(date);


Create OR REPLACE TABLE dim_zone as 
SELECT
    LocationID AS zone_key,
    Borough,
    Zone,
    service_zone
FROM 'data\raw\taxi_zone_lookup.csv';