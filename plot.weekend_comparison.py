from pathlib import Path

import duckdb
import matplotlib.pyplot as plt
import pandas as pd


DB_PATH = Path("data/warehouse/taxi_20556.duckdb")


def main():
    # Connect to the existing DuckDB warehouse
    con = duckdb.connect(DB_PATH)

    # Read the aggregate table into a pandas DataFrame
    df = con.execute("""
        SELECT
            weekend,
            number_of_trips,
            average_distance,
            total_distance
        FROM weekend_comparison
        ORDER BY weekend
    """).fetchdf()

    con.close()

    # Chart 1: number of trips per weekend
    plt.figure(figsize=(9, 5))
    plt.bar(df["weekend"], df["number_of_trips"])
    plt.xlabel("Weekend")
    plt.ylabel("Number of trips")
    plt.title("Number of taxi trips per weekend – Boerum Hill")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

    # Chart 2: total distance per weekend
    plt.figure(figsize=(9, 5))
    plt.bar(df["weekend"], df["total_distance"])
    plt.xlabel("Weekend")
    plt.ylabel("Total distance")
    plt.title("Total taxi distance per weekend – Boerum Hill")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()

    # Chart 3: Average distance
    plt.figure(figsize=(9, 5))
    plt.bar(df["weekend"], df["average_distance"])
    plt.xlabel("Weekend")
    plt.ylabel("Average distance")
    plt.title("Average taxi trip distance per weekend – Boerum Hill")
    plt.xticks(rotation=45)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    main()