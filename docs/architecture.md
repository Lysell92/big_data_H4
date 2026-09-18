# Arkitektur

**Version 1.0 · Elevskabelon**

## Indhold

1. [Data](#data)
2. [Analysebehov](#analysebehov)
3. [Arkitekturskitse](#arkitekturskitse)

## Data

**Yellow Taxi:** Én rå række ser ud til at repræsentere:

> Information om taxaturerne inklusivt opsamlings og afleveringtidspunkt med dertilhørende lokations-ID, som er en foreign key fra Taxi Zone Lookup. Antal passagerer, turlængde osv. 

**Taxi Zone Lookup:** Én række repræsenterer:

> Bydele, zoner og service_zoner for taxaerne. Lokations-ID er den primary KEY her og den foreign KEY, som anvendes i Yellow Taxi datasættes.

Beskriv 3–5 relevante felter med egne ord. Find betydning og enheder i TLC's dataordbog, og henvis til kilden. Notér også en eventuel uventet værdi uden at ændre raw-data.

> tpep_pickup_datetime: The date and time when the meter was engaged. 


> tpep_dropoff_datetime: The date and time when the meter was disengaged. 


> fare_amount: The time-and-distance fare calculated by the meter.

### Taget fra https://www.nyc.gov/assets/tlc/downloads/pdf/data_dictionary_trip_records_yellow.pdf

## Analysebehov

3. TODO

Mindst ét spørgsmål skal bruge Zone Lookup. Alle spørgsmål skal kunne undersøges med de udleverede data.

## Arkitekturskitse

> TODO: Indsæt dit eget diagram. Brug Mermaid eller et andet diagramværktøj.

                    ┌──────────────────────────────┐
                    │          RÅ DATA             │
                    │                              │
                    │ yellow_tripdata_2025-01      │
                    │        .parquet               │
                    │                              │
                    │ taxi_zone_lookup.csv         │
                    └──────────────┬───────────────┘
                                   │
                                   │
                     ┌─────────────▼─────────────┐
                     │     DATAKONTROL /         │
                     │        FORBEREDELSE       │
                     │                            │
                     │ • Undersøg kolonner       │
                     │ • Tjek manglende værdier  │
                     │ • Tjek ID'er              │
                     │ • Tjek duplicate keys     │
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │           JOIN            │
                     │                           │
                     │ PULocationID              │
                     │       =                   │
                     │ LocationID                │
                     │                           │
                     │ DOLocationID              │
                     │       =                   │
                     │ LocationID                │
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │      AFLEDT DATA          │
                     │                           │
                     │ • Zone                    │
                     │ • Borough                 │
                     │ • Antal ture              │
                     │ • Gennemsnitlig distance  │
                     │ • Gennemsnitlig pris      │
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │         ANALYSE           │
                     │                           │
                     │ • Ture pr. zone           │
                     │ • Ture pr. borough        │
                     │ • Distance / pris         │
                     │  
                     └─────────────┬─────────────┘
                                   │
                                   ▼
                     ┌───────────────────────────┐
                     │          RESULTAT         │
                     │                           │
                     │ Tabeller / grafer /       │
                     │ konklusioner              │
                     └───────────────────────────┘


        ───────────────────────────────────────────────
        RÅDATA BEVARES UÆNDRET
        Transformationer sker i DuckDB
        ───────────────────────────────────────────────

Begrund dit dataflow ud fra analysebehovene. Forklar, hvor de rå data bevares, hvad der sker mellem input og resultat, og hvilke data der er afledte. Markér det, der virker nu, og det, der skal bygges senere.

> TODO: Din forklaring og de kilder, du har brugt.

## Dag04 – processing og pipeline

### Den implementerede batch-pipeline

Tegn det dataflow, som `src/pipeline.py` faktisk kører. Vis konkrete input, SQL-trin, DuckDB-tabeller og afhængigheder. Markér tydeligt, hvad der er raw input, transformation og lagret resultat. Pilenes labels skal beskrive handlingen.

                         IMPLEMENTERET

 Raw input
    │
    │ læses af SQL
    ▼
┌──────────────────────────────────────┐
│ data/raw/                            │
│                                      │
│ yellow_tripdata_2025-01.parquet      │
│ taxi_zone_lookup.csv                 │
└──────────────────────────────────────┘
    │
    │ 02_dimensions.sql
    │ opretter/genopbygger dimensioner
    ▼
┌──────────────────────────────────────┐
│ DuckDB                               │
│ data/warehouse/taxi_20556.duckdb    │
│                                      │
│ dim_zone                             │
│ dim_date                             │
└──────────────────────────────────────┘
    │
    │ 03_fact_trip.sql
    │ transformerer + joiner
    ▼
┌──────────────────────────────────────┐
│ fact_trip                            │
│                                      │
│ 1 række = 1 taxitur                  │
└──────────────────────────────────────┘
    │
    │ 04_aggregates.sql
    │ sammenfatter / analyserer
    ▼
┌──────────────────────────────────────┐
│ Afledte resultater                   │
│                                      │
│ taxi_data                            │
│ weekend_comparison                   │
└──────────────────────────────────────┘


Python pipeline.py styrer rækkefølgen:

02_dimensions.sql
        ↓
03_fact_trip.sql
        ↓
04_aggregates.sql


Forklar, hvorfor `01_explore.sql` ikke er et build-trin. Beskriv også, hvad pipelinen gør, hvis en påkrævet SQL-fil mangler, er tom eller fejler under kørsel, og hvornår resultaterne gøres gældende.

> TODO: Kort forklaring af dependencies, fejlstop, transaktion/udgivelse og forbindelsens lukning.
Explore.sql blev brugt til øvelse og derfor giver det ikke mening at tilføje den som et build-trin. Den har ikke nogen relevans for at blive inkluderet. 

`01_explore.sql` blev brugt til øvelse og udforskning af data og er derfor ikke en del af mit build-pipeline. Filen var kun ment for test og ikke for integration i selve buildet.

Pipelinen har en fast afhængighedsrækkefølge, hvor dimensionerne oprettes først, derefter `fact_trip`, og til sidst de afledte aggregater. Python bruger DuckDBs `Statement`-objekter til at parse SQL-filerne og `StatementType` til at identificere typen af SQL-statement.

Hvis en påkrævet SQL-fil mangler, er tom eller indeholder en SQL-fejl, stopper builden. Fejlen bliver vist sammen med det trin, hvor den opstod, så det er muligt at identificere, hvilken del af pipelinen der fejlede.

Builden køres i én database-transaktion. Ved succes udføres `COMMIT`, og resultaterne gøres dermed gældende som en samlet build. Hvis der opstår en fejl, udføres `ROLLBACK`, så ændringer fra den mislykkede build ikke efterlades som en halvfærdig database. Fejlen sendes derefter videre, så builden ikke skjuler problemet.

Når buildet er afsluttet – enten med succes eller fejl – lukkes DuckDB-forbindelsen i `finally`-blokken.



### ETL eller ELT – angiv destinationen

Beskriv forløbet som ETL og/eller ELT. Navngiv det lager, du betragter som destination, og placér extract, load og transform i forhold til dette. Hvis betegnelsen ændrer sig, når destinationen ændres, skal du forklare hvorfor.

> TODO: Din klassifikation med konkret destination. En forkortelse alene er ikke en begrundelse.

Min pipeline kan bedst beskrives som ELT, hvor destinationen er DuckDB-databasen `data/warehouse/taxi_20556.duckdb`.

Først udtrækkes data fra raw-filerne, blandt andet Parquet-filen med taxiture og CSV-filen med zoneoplysninger. Dataene indlæses i eller læses fra DuckDB, som fungerer som det analytiske lager. Herefter udføres transformationerne med SQL i DuckDB, hvor blandt andet `dim_date`, `dim_zone`, `fact_trip` og de afledte aggregater oprettes.

Forløbet kan derfor beskrives som:

`Extract → Load → Transform`

Det er ELT frem for traditionel ETL, fordi transformationerne udføres i destinationslageret efter load-trinnet. Hvis transformationerne i stedet blev udført uden for DuckDB, eksempelvis i Python, før de transformerede data blev indlæst i DuckDB, ville forløbet være ETL.

Valget af betegnelse afhænger derfor af, hvilket system der betragtes som destinationen. Her betragtes DuckDB som destinationen, fordi databasen er det lager, hvor de behandlede data og de afledte tabeller gemmes.

### Genkørsel og næste batch

Dokumentér resultatet af to kørsler med de samme raw-inputs. Brug relevante tællinger eller andre kontroller til at vise, om den anden kørsel fordoblede data. Skeln derefter mellem denne genkørsel og en plan for at modtage en ny måneds fil.

> TODO: Forventning, observeret resultat og konklusion på genkørsel. 
Forventningen var at dataen forhåbentligvis ikke blev duplikeret. Det viste sig også at være tilfældet - 
jeg tilføjede nogle simple queries, som tæller antallet af rækker hos mit 'fact_trip', 'taxi_data og 
'weekend_comparison'. Efter at have kørt: 'python pipeline.py' i det virtuelle python-miljø gentagende gange, forblev dataen stadigvæk den samme. Når der foretages en genkørsel duplikeres dataen derfor ikke. 

> TODO: Plan for et nyt månedligt batch. Medtag filvalg, dataperiode, nøgler/overlap, schemaændringer, kontroller og beslutning om fuld rebuild eller inkrementel indlæsning. Planen skal ikke implementeres på Dag04.
Jeg har tilføjet februar måned og har også implementeret tests sql_tests, som viser at begge måneder nu
er inkluderet og brugt i fact_trip. 

### Streamingvariant og ansvar

Tegn en tænkt variant, hvor taxi-hændelser ankommer løbende i stedet for som én færdig månedsfil. Diagrammet skal mindst vise:

```text
producer → queue eller log → processor → data store → anvendelse
```

Angiv hvilken hændelsestid der er relevant, hvordan gentagelser eller forsinkede events kan påvirke resultatet, og hvilket ansvar der ligger hos henholdsvis producer, queue/log, processor og orchestrator. Forklar også hvorfor orchestratoren ikke udfører selve transformationen.

> TODO: Diagram og kort rolle-/fejlforklaring. Markér hele varianten som foreslået, ikke implementeret.

### Konceptuelt paralleliseringsdesign

Beskriv ét konkret scenarie, hvor parallel behandling kunne blive relevant. Et stort rækkeantal er ikke alene en begrundelse: angiv en udløser som målt køretid mod deadline, hukommelsesgrænse, I/O eller flere samtidige opgaver.

Tegn derefter:

```text
partitioner → workers → combine/merge → kontrolleret resultat
```

Vælg en partitioneringsnøgle, forklar hvordan delresultater kan kombineres, og beskriv mindst ét problem med overhead, skæv fordeling, rækkefølge eller dubletter. Skeln mellem parallelitet på én maskine og behandling på flere maskiner.

> TODO: Udløser, partitionering, workers, combine, kontrol og trade-off. Markér designet som foreslået.

### Implementeret, testet og foreslået

Parallel behandling kunne blive relevant, hvis mængden af historiske taxiture vokser betydeligt, og den målte køretid for batch-pipelinen begynder at overskride den ønskede deadline for færdiggørelse. Det kunne eksempelvis være tilfældet, hvis pipelinen senere skal behandle flere års data i stedet for de nuværende datasæt fra januar og februar 2025.

En mulig partitioneringsnøgle er pickup_zone_key. fact_trip kan opdeles i flere partitioner baseret på pickup-zone, hvorefter flere workers kan behandle hver sin partition parallelt.

fact_trip
    │
    ▼
partitionér efter pickup_zone_key
    │
    ├──────────────┬──────────────┬──────────────┐
    ▼              ▼              ▼              ▼
 Worker 1       Worker 2       Worker 3       Worker 4
 zone 1–70      zone 71–140    zone 141–210   zone 211–265
    │              │              │              │
    └──────────────┴──────────────┴──────────────┘
                           │
                           ▼
                    combine / merge
                           │
                           ▼
                 kontrolleret resultat
                 counts + distance sums

Workers kan eksempelvis beregne COUNT(*) og SUM(trip_distance) for deres egen partition. Delresultaterne kan derefter kombineres ved at summere antal ture og distance. Hvis der beregnes gennemsnit, skal man samtidig bevare antal gyldige observationer og summen af distance, så det samlede gennemsnit kan beregnes korrekt. Man bør ikke blot tage gennemsnittet af de enkelte workers' gennemsnit.

En udfordring ved denne løsning er, at data ikke nødvendigvis er jævnt fordelt mellem zonerne. Hvis én partition indeholder langt flere ture end de øvrige, kan den blive en flaskehals, selvom arbejdet er paralleliseret. Derudover medfører parallelisering ekstra overhead til partitionering, koordinering og samling af resultater. Hvis samme data ved en fejl behandles af flere workers, kan der også opstå dubletter.

Designet kan implementeres som parallelitet på én maskine, hvor flere processer eller threads deler CPU- og I/O-ressourcer. Ved større datamængder kunne samme princip udvides til flere maskiner, hvor partitionerne fordeles mellem forskellige computere. Det vil dog introducere yderligere netværks-, koordinations- og fejlhåndteringsomkostninger.

Afslut med en lille tabel:

| Element | Status | Evidens eller næste skridt |
|---|---|---|
| Lokal batch-pipeline | TODO | TODO |
| Genkørsel med samme input | TODO | TODO |
| Nyt månedligt batch | TODO | TODO |
| Streamingvariant | TODO | TODO |
| Parallel behandling | TODO | TODO |

Brug statusord som **implementeret og testet**, **implementeret men ikke testet** eller **foreslået**. Notér de Python-, DuckDB- og arkitekturkilder, du faktisk anvendte, med genfindelig reference og hvad de bidrog med.

https://duckdb.org/docs/current/clients/python/reference/
En oversigt over python metoder i duckDB. Her fandt jeg blandt andet fetchmany(), som jeg brugte til at
printe de select-statements jeg returnerer. 
Og jeg brugte også extract_statements() til at parse SQL-filen, så statements ikke behøver at blive adskilt manuelt med split(";"). Parseren kan dermed skelne mellem semikoloner som afslutter SQL-statements, og semikoloner, der indgår normalt i en tekststreng.

https://duckdb.org/docs/current/internals/overview
Her fandt jeg StatementType, som hjalp mig med at fastligge hvad for en type et Select-statements betegnes som, så jeg kunne genkende og udskrive dem i min pipeline.



