-- 20556 · Dag03 · Revision 1.1 · 15. september 2026
-- Arbejd efter Dag03 i 20556_Laerling_Ugecase_NYC_Taxi.md.
-- Forudsætning: Din fungerende fact/dimension-model fra Dag02.
-- Skriv selv SQL. Denne fil indeholder opgavekrav, ikke en løsningsskabelon.

-- ARBEJDSMÅDE OG DOKUMENTATION
--
-- Brug den officielle DuckDB-dokumentation undervejs, når du mangler
-- syntaks eller skal kontrollere, hvordan en funktion virker.
--
-- Notér løbende de manualsider, du faktisk bruger, og kort hvad de
-- hjalp dig med. Du skal kunne forklare og tilpasse den SQL, du skriver.
--
-- Skriv ikke en separat rapport. Grain, informationstab, lagringsvalg
-- og genskabelsesplan dokumenteres i Dag03-afsnittet i docs/architecture.md.

-- 1. DESIGN OG BYG
-- TODO: Angiv analysebehov, fact-grain og valgt aggregate-grain i egne ord.
-- Fælles udgangspunkt: pickup-dato x pickup-zone. Begrund et andet valg.
-- TODO: Byg og gem et nyt aggregate oven på fact_trip.
--
-- Aggregatet skal have et mere sammenfattet grain end fact_trip.
-- Fælles udgangspunkt:
--   én række pr. pickup-dato × pickup-zone.
--
-- Det er altså ikke bare endnu en SELECT, der vises i terminalen:
-- resultatet skal materialiseres som en tabel i DuckDB, så det kan
-- bruges som input til nye analyser og yderligere aggregering.

-- Bevar antal ture og det afstandsgrundlag, der er nødvendigt for at beregne
-- gennemsnitlig trip_distance efter endnu en aggregering. Vælg selv felterne.
-- Beskriv eventuelle filtre; brug dem også i alle sammenligninger med fact.
-- Bevar raw og fact. Fjern ikke nul, ekstremværdier eller datoer stiltiende.

-- 2. KONTROLLÉR
-- TODO: Vis, at hver kombination i dit valgte grain højst forekommer én gang.
-- TODO: Afstem ture og afstandsgrundlag med fact for samme datamængde.
-- Undersøg NULL kontra nul; en registreret værdi er ikke automatisk korrekt.
-- TODO: Genkør filen og vis, at resultatet ikke fordobles.
-- Notér kort forventning, observeret resultat og eventuelle forskelle.

-- 3. BRUG OG SAMMENFAT IGEN
-- TODO: Besvar dit analysebehov med en query mod aggregatet.
-- TODO: Sammenfat til et grovere grain og beregn gennemsnitlig afstand.
-- Kontrollér mod fact med samme afgrænsning. Håndtér manglende værdier
-- og grupper uden afstandsværdier; et ukendt gennemsnit er ikke nul.
-- Forklar hvorfor gennemsnit af gruppegennemsnit ikke generelt er korrekt.
-- Du behøver ikke gemme den yderligere sammenfatning som en ny tabel.


-- Analysebehov 1. En query som sammenligner aktiviteten af to weekender i en bestemt zone. I tilfælde af, at man skulle vælge ferie og ønskede en mere eller mindre aktiv weekend som taxa-chauffør.
-- Grain repræsenterer her en række en weekend for en udvalgt zone - i dette tilfælde 'Boerum Hill'. 

-- Aggregatet kan besvare spørgsmål om travlhed og mængde arbejde over to forskellige weekender. 
-- Hvis man ønskede mere repræsentativ data kunne man overveje at inkludere flere zoner. 

-- Measures er pickup_zone, number_of_trips, total_distance og average_distance

-- Jeg blev nød til at tilføje et maximum check i forlængelse af min null og < 0 checks. Målingerne viste en total_distance på over 50000 mil i den ene weekend modsætning til den anden weekend som lå omkring 1200 mil.

-- Hvilket er et fint eksempel på hvordan gennemsnit kan generes af støj i dataen og dermed ikke er repræsentativ for et reelt gennemsnit.
-- Gruppe gennemsnit kan også være fejlagtig, fordi grupperne kan variere i stor grad (som eksempel kan man forestille sig en taxa-chauffør, som kører langdistanceturer vs. en der kører mindre ture i den indre by. 
-- Dermed er deres gennemsnit være vidt forskelligt og hvis du sammenfattede deres gennemsnit, vil forskellen mellem de to ikke være gennemsigtig. 


CREATE OR REPLACE TABLE weekend_comparison AS
SELECT 
    CASE
        WHEN d.date BETWEEN DATE '2025-01-04' AND DATE '2025-01-05'
            THEN 'Weekend 1' 
        WHEN d.date BETWEEN DATE '2025-01-11' AND DATE '2025-01-12'
            THEN 'Weekend 2' 
        WHEN d.date BETWEEN DATE '2025-01-18' AND DATE '2025-01-19'
            THEN 'Weekend 3'
        WHEN d.date BETWEEN DATE '2025-01-25' AND DATE '2025-01-26'
            THEN 'Weekend 4'
        WHEN d.date BETWEEN DATE '2025-02-01' AND DATE '2025-02-02'
            THEN 'Weekend 5' 
        WHEN d.date BETWEEN DATE '2025-02-08' AND DATE '2025-02-09'
            THEN 'Weekend 6' 
        WHEN d.date BETWEEN DATE '2025-02-15' AND DATE '2025-02-16'
            THEN 'Weekend 7'
        WHEN d.date BETWEEN DATE '2025-02-22' AND DATE '2025-02-23'
            THEN 'Weekend 8'
    END AS weekend,

    z.Zone AS pickup_zone,
    COUNT(*) AS number_of_trips,
    AVG(f.trip_distance) AS average_distance,
    SUM(f.trip_distance) AS total_distance 
    
  
FROM fact_trip AS f

JOIN dim_date AS d
    ON f.date_key = d.date_key

JOIN dim_zone AS z
    ON f.pickup_zone_key = z.zone_key


WHERE z.Zone IS NOT NULL 
    AND z.Zone = 'Boerum Hill'
    AND(
        d.date BETWEEN DATE '2025-01-04' AND DATE '2025-01-05'
        OR
        d.date BETWEEN DATE '2025-01-11' AND DATE '2025-01-12'
        OR
        d.date BETWEEN DATE '2025-01-18' AND DATE '2025-01-19'
        OR
        d.date BETWEEN DATE '2025-01-25' AND DATE '2025-01-26'
        OR 
        d.date BETWEEN DATE '2025-02-01' AND DATE '2025-02-02'
        OR 
        d.date BETWEEN DATE '2025-02-08' AND DATE '2025-02-09'
        OR 
        d.date BETWEEN DATE '2025-02-15' AND DATE '2025-02-16'
        OR
        d.date BETWEEN DATE '2025-02-22' AND DATE '2025-02-23'        
    )
    AND f.trip_distance IS NOT NULL
    AND f.trip_distance > 0
    AND f.trip_distance < 2000



GROUP BY
    weekend,
    z.Zone;

-- Analysebehov 2. En generel oversigt over taxaturer i en borough: Tidspunkt for afhentning, aflevering, turens distance og passagerer.
-- Grain er her en taxa-tur, men mere fokuseret med færre measures end vores fact_trip.
-- Measures indbefatter her alle kolonnerne: tpep_pickup_datetime, tpep_dropoff_datetime, trip_distance, passenger_count

CREATE OR REPLACE TABLE taxi_data AS
SELECT
    f.tpep_pickup_datetime,
    f.tpep_dropoff_datetime,
    f.trip_distance AS distance_of_trip,
    f.passenger_count AS passengers

FROM fact_trip AS f

JOIN dim_date as d
    ON f.date_key = d.date_key
JOIN dim_zone as z
    ON f.pickup_zone_key = z.zone_key

WHERE f.tpep_pickup_datetime IS NOT NULL
AND f.tpep_dropoff_datetime IS NOT NULL
AND f.trip_distance IS NOT NULL
AND f.passenger_count IS NOT NULL;


