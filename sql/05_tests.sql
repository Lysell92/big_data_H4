-- TESTS

-- Viser om det ønskede grain i weekend_comparison henholder sig til: en række pr. kombination af weekend +
-- pickup-zone. Hvis dette query returnerer en række, betyder det, at den samme weekend + pickup_zone kombination 
-- forekommer flere gange og at grainet derfor ikke overholdes. 
SELECT
    weekend,
    pickup_zone,
    COUNT(*) AS number_of_rows
FROM weekend_comparison
GROUP BY
    weekend,
    pickup_zone
HAVING COUNT(*) > 1;

-- Første statement fra fact_trip: 
-- Sammenligner data her fra fact_trip med raw data, for at se hvorvidt dataen er konsistent 
-- efter at vi har aggregeret dataen. Hvis begge statements er ens, er dataen ikke blevet ændret i aggregationen. 

SELECT
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (WHERE trip_distance IS NULL) AS null_distance,
    COUNT(*) FILTER (WHERE trip_distance = 0) AS zero_distance
FROM fact_trip;

-- Det andet statement fra den rå data
-- Sammenligner data her fra raw_data med fact_trip, for at se hvorvidt dataen er konsistent 
-- efter at vi har aggregeret dataen. Hvis begge statements er ens, er dataen ikke blevet ændret i aggregationen. 
SELECT
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (WHERE trip_distance IS NULL) AS null_distance,
    COUNT(*) FILTER (WHERE trip_distance = 0) AS zero_distance
FROM (
    SELECT trip_distance
    FROM 'data\raw\yellow_tripdata_2025-01.parquet'

    UNION ALL

    SELECT trip_distance
    FROM 'data\raw\yellow_tripdata_2025-02.parquet'
) AS trips;

-- Test for at se hvorvidt dataen tilføjes gentagende gange pr. gang pipeline.py køres,
-- hvilket vil duplikere og kontaminere dataen (noter at taxi_data har færre rows, fordi den
-- fjerner null-værdier):
-- fact_trip rækker
SELECT COUNT(*) FROM fact_trip;
-- taxi_data rækker
SELECT COUNT(*) FROM taxi_data;
-- weekend_comparison - Hvor mange uger der sammenlignes med
SELECT COUNT(*) FROM weekend_comparison;

-- Bekræfter at data-rangen er blevet udvidet med februar måned.
SELECT
    MIN(d.date) AS first_date,
    MAX(d.date) AS last_date
FROM fact_trip AS f
JOIN dim_date AS d
    ON f.date_key = d.date_key;


-- Returnerer de samlede resultater fra de valgte measures på weekend_comparison aggregatet. 

SELECT
    weekend,
    number_of_trips,
    average_distance,
    total_distance
FROM weekend_comparison
ORDER BY weekend;

-- Viser hvornår først og sidste dato finder sted i datasættet.
SELECT
    MIN(tpep_pickup_datetime) AS first_trip,
    MAX(tpep_pickup_datetime) AS last_trip,
    COUNT(*) AS total_trips
FROM fact_trip;

-- Tæller antal ture på månedsbasis. Bekræfter at data fra begge måneder fra fact_trip er returnerbare og
-- sammenligner de to måneders antal ture.
SELECT
    DATE_TRUNC('month', tpep_pickup_datetime) AS month,
    COUNT(*) AS number_of_trips
FROM fact_trip
GROUP BY month
ORDER BY month;

-- Checker at grainet udføres korrekt, så at hver række repræsenterer en weekend + pickup-zone og at
-- weekend/zone kombination er unikke og ikke duplikeres.
SELECT
    weekend,
    pickup_zone,
    COUNT(*) AS number_of_rows
FROM weekend_comparison
GROUP BY weekend, pickup_zone
HAVING COUNT(*) > 1;


-- Checker for nul og null values og tydeliggøre distinktionen heraf.
SELECT
    COUNT(*) AS total_trips,
    COUNT(*) FILTER (WHERE trip_distance IS NULL) AS null_distance,
    COUNT(*) FILTER (WHERE trip_distance = 0) AS zero_distance
FROM fact_trip;