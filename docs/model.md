# Datamodel

**Version 1.0 · Elevskabelon**

## Indhold

1. [Grain](#grain)
2. [Modelvalg](#modelvalg)
3. [Modeldiagram](#modeldiagram)
4. [Forklaring](#forklaring)

## Grain

> Én række i `fact_trip` repræsenterer en taxitur.  

## Modelvalg

**Vigtigste measures:**  
trip_distance; fare_amount; tip_amount; zone;

**Vigtigste dimensions:**  
dim_zone; dim_data;

## Modeldiagram

dim_date
                       ┌────────────┐
                       │ date_key PK│
                       │ date       │
                       │ year       │
                       │ month      │
                       │ weekday    │
                       └─────▲──────┘
                             │
                             │ FK
                             │
                       fact_trips
                 ┌─────────────────────┐
                 │ date_key             │
                 │ pickup_zone_key ────────┐
                 │ dropoff_zone_key ─────┐ │
                 │ trip_distance         │ │
                 │ fare_amount           │ │
                 │ tip_amount            │ │
                 └─────────────────────┘ │ │
                                         │ │
                       ┌─────────────────┘ │
                       │                   │
                       ▼                   ▼
                  dim_zone             dim_zone
                  (pickup)             (dropoff)

> TODO: Tegn dit eget diagram med nøgler, relationer og kardinalitet.

## Forklaring

Begrund grain, valgte measures og dimensioner ud fra analysebehovene. Forklar dimensionernes roller, og vis hvordan du kontrollerer modellens relationer. Angiv de kilder, du har anvendt.

> ## 2. 
