-- En generel query som henter datasættet og opsummerer forskellige information om det valgte table.
SUMMARIZE SELECT * FROM read_parquet('data\raw\yellow_tripdata_2025-01.parquet');

-- Viser hvor mange ture der foretages med 3 eller 4 passagerer.
SELECT count(*)
FROM 'data\raw\yellow_tripdata_2025-01.parquet'
WHERE passenger_count BETWEEN '3' AND '4';


-- Zone lookup som viser de første 5 dataenheder fra det valgte table. 
SELECT *
FROM 'data\raw\yellow_tripdata_2025-01.parquet'
LIMIT 5;



-- Find manglende matches: Først medtager jeg kun ture hvor man kan finde en zone. Derefter med LEFT JOIN, er alle ture medtaget inklusivt dem uden zone.

SELECT
    zones.Borough,
    COUNT(*) AS antal_ture
FROM 'data\raw\yellow_tripdata_2025-01.parquet' AS trips
JOIN 'data\raw\taxi_zone_lookup.csv' AS zones
    ON trips.PULocationID = zones.LocationID
GROUP BY zones.Borough
ORDER BY antal_ture DESC;

SELECT
    zones.Borough,
    COUNT(*) AS antal_ture
FROM 'data\raw\yellow_tripdata_2025-01.parquet' AS trips
LEFT JOIN 'data\raw\taxi_zone_lookup.csv' AS zones
    ON trips.PULocationID = zones.LocationID
GROUP BY zones.Borough
ORDER BY antal_ture DESC;


-- Zonefilen har en positionel relation mellem rækkerne, hvor rækkernes locations-id, identificere den relationelle sammenhæng mellem rækkerne.

-- Analysebehov 1. En query som sammenligner aktiviteten af to weekender. I tilfælde af, at man skulle vælge ferie og ønskede en mere eller mindre aktiv weekend som taxa-chauffør.
SELECT 
    count(*) filter(
            WHERE tpep_pickup_datetime >= TIMESTAMPTZ '2025-01-10 00:00:00+00'
            AND tpep_pickup_datetime < '2025-01-13 00:00:00+00'
    ) as weekend_1,

    count(*) filter(
                WHERE tpep_pickup_datetime >= TIMESTAMPTZ '2025-01-17 00:00:00+00'
                AND tpep_pickup_datetime < '2025-01-20 00:00:00+00'
    ) as weekend_2
FROM 'data\raw\yellow_tripdata_2025-01.parquet';




-- Analysebehov 2. En behov for en generel oversigt over taxaturenes forløb: Tidspunkt for afhentning, aflevering og turens distance.

SELECT
    trips.tpep_pickup_datetime,

    pickup.Zone AS pickup_zone,
    dropoff.Zone AS dropoff_zone,

    trips.trip_distance

FROM 'data\raw\yellow_tripdata_2025-01.parquet' AS trips

JOIN 'data\raw\taxi_zone_lookup.csv' AS pickup
    ON trips.PULocationID = pickup.LocationID

JOIN 'data\raw\taxi_zone_lookup.csv' AS dropoff
    ON trips.DOLocationID = dropoff.LocationID
LIMIT 5;


-- 20556 · Mandag · Version 1.0
-- Skriv selv dine queries. Find syntaks i DuckDB-dokumentationen.
-- Gem filen, og kør den med src/run_sql_file.py fra projektets rod.

-- 1. Dataundersøgelse
-- TODO: Undersøg antal rækker, schema/datatyper, et lille udsnit,
-- perioden i pickup-tidsstemplet og forskellige pickup-lokationer.
-- Kommentér kort, hvad resultaterne fortæller, og hvad der undrer dig.

-- 2. Eget analysespørgsmål
-- TODO: Skriv en selvvalgt gruppering, der undersøger et relevant spørgsmål.
-- Forklar i en kommentar, hvad én række i resultatet repræsenterer.

-- 3. Sammenhæng mellem kilderne
-- TODO: Undersøg zonefilen. Begrund relationen, og skriv selv et join.
-- Vis, hvordan du kontrollerer for manglende matches og ekstra rækker.
-- Afprøv en meningsfuld ændring, og forklar dens konsekvens.
-- Join og gruppering må gerne indgå i samme query.

-- 4. Dokumentation
-- TODO: Notér de manualsider, du faktisk brugte, og hvad du fandt i dem.
-- Dataforklaringer, analysebehov og eget diagram gemmes i docs/architecture.md.


