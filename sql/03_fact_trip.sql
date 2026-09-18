-- 20556 · Tirsdag · Version 1.0
-- TODO: Implementér fact_trip ud fra grain og modelvalg i docs/model.md.
-- Begrund dine measures og relationer til dimensionernes to roller.
-- Dokumentér, hvad din nøgle identificerer, også ved en genopbygning.

-- TODO: Skriv kontroller af relationernes dækning og kardinalitet.
-- Resultater skal vise, om rækker mangler eller mangedobles ved joins.

-- TODO: Skriv tre analysequeries nederst i denne fil.
-- De skal samlet bruge dim_date, dim_zone og mindst ét numerisk measure
-- ud over optælling. Mindst én skal besvare et analysebehov fra mandag.
-- Kontrolqueries tæller ikke som de tre analysequeries.

CREATE OR REPLACE TABLE fact_trip AS
SELECT 
    trips_jan.tpep_pickup_datetime,
    trips_jan.tpep_dropoff_datetime,
    
    CAST(
        strftime(DATE(trips_jan.tpep_pickup_datetime), '%Y%m%d') 
        AS INTEGER
    ) AS date_key,

    pickup.zone_key AS pickup_zone_key,
    dropoff.zone_key AS dropoff_zone_key,

    trips_jan.trip_distance,
    trips_jan.fare_amount,
    trips_jan.tip_amount,
    trips_jan.passenger_count

FROM 'data\raw\yellow_tripdata_2025-01.parquet' AS trips_jan

JOIN dim_zone as pickup
    ON trips_jan.PULocationID = pickup.zone_key

JOIN dim_zone as dropoff
    ON trips_jan.DOLocationID = dropoff.zone_key

UNION ALL

SELECT 
    trips_feb.tpep_pickup_datetime,
    trips_feb.tpep_dropoff_datetime,
    
    CAST(
        strftime(DATE(trips_feb.tpep_pickup_datetime), '%Y%m%d') 
        AS INTEGER
    ) AS date_key,

    pickup.zone_key AS pickup_zone_key,
    dropoff.zone_key AS dropoff_zone_key,

    trips_feb.trip_distance,
    trips_feb.fare_amount,
    trips_feb.tip_amount,
    trips_feb.passenger_count

FROM 'data\raw\yellow_tripdata_2025-02.parquet' AS trips_feb

JOIN dim_zone as pickup
    ON trips_feb.PULocationID = pickup.zone_key

JOIN dim_zone as dropoff
    ON trips_feb.DOLocationID = dropoff.zone_key;
