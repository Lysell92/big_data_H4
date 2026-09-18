"""Dag04-opgave: implementér en reproducerbar batch-pipeline.

Arbejd efter Dag04 i 20556_Laerling_Ugecase_NYC_Taxi.md.
Denne fil angiver kontrakten og funktionsgrænserne, men ikke løsningen.
"""
from pathlib import Path

import duckdb

from duckdb import Statement, StatementType


DB_PATH = Path("data/warehouse/taxi_20556.duckdb")

# 01_explore.sql er udforskning og er bevidst ikke et rebuild-trin.
STEPS = (
    ("dimensions", Path("sql/02_dimensions.sql")),
    ("fact", Path("sql/03_fact_trip.sql")),
    ("aggregate", Path("sql/04_aggregates.sql")),
)

"""Læs og parse en påkrævet SQL-fil eller stop med en tydelig fejl.
TODO:
- Stop hvis filen mangler.
- Stop hvis filen ikke indeholder kørbare SQL-statements.
- Brug DuckDB-parseren, så kommentarer og semikolon i tekst håndteres.
- Returnér de kørbare statements i filens rækkefølge.
"""

def load_statements(connection: duckdb.DuckDBPyConnection,
    sql_path: Path
) -> list[Statement]:

    if not sql_path.exists():
        raise FileNotFoundError(f"SQL file couldn't be found: {sql_path}") 

    sql = sql_path.read_text(encoding="utf-8")
    
    statements = connection.extract_statements(sql)

    if not statements:
        raise ValueError(
            f"SQL file doesn't contain executable statements: {sql_path}"
        )
    print(type(statements[0].type))
    print(type(statements[0]))
    return statements


"""Kør ét trin og gør det synligt, hvor en eventuel fejl opstår.

TODO:
- Vis trinets navn og fremdrift.
- Kør statements i rækkefølge.
- Vis korte kontrolresultater fra SELECT-statements uden at skjule fejl.
"""

def run_step(
    connection: duckdb.DuckDBPyConnection,
    step_name: str,
    statements: list[Statement],
) -> None:
    print(f"\n--- {step_name} ---")

    for statement in statements:
        print("Running SQL...")
        print("QUERY:", statement.query)
        print("TYPE:", statement.type)
        
        result = connection.execute(statement.query)
        
        if statement.type == StatementType.SELECT:
            print(result.fetchmany(10))

"""Kør hele builden sikkert i den rækkefølge, afhængighederne kræver.

TODO:
- Opret warehouse-mappen ved behov, og åbn DB_PATH.
- Validér alle påkrævede SQL-filer før builden ændrer databasen.
- Brug én transaktion til builden: commit kun når alle trin lykkes.
- Roll back ved fejl, og lad fejlen være synlig for den, der kører scriptet.
- Luk forbindelsen både ved succes og fejl.
- Udskriv en tydelig slutstatus.

Genkørbarheden kommer også fra de SQL-filer, du har skrevet. Forklar derfor,
hvorfor din kombination af Python og SQL ikke fordobler afledte data.
"""

def main() -> None:

    DB_PATH.parent.mkdir(parents=True, exist_ok=True)
    connection = duckdb.connect(str(DB_PATH))
    
    transaction_started = False
    
    try:
        loaded_steps = []

        for step_name, sql_path in STEPS:
            statements = load_statements(connection, sql_path)
            loaded_steps.append((step_name, statements))
        
        connection.execute("BEGIN")
        transaction_started = True

        for step_name, statements in loaded_steps:
            run_step(connection, step_name, statements)
        
        connection.execute("COMMIT")
        print("\n Build successfully completed")
        transaction_started = False
    except Exception:
        if transaction_started:
            connection.execute("ROLLBACK")
        print("\nBuild failed. Transaction rolled back.")
        raise
    finally:
        connection.close()


if __name__ == "__main__":
    main()

