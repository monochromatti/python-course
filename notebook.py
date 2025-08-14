# /// script
# requires-python = ">=3.13"
# dependencies = [
#     "altair==5.5.0",
#     "marimo",
#     "polars==1.32.2",
# ]
# ///

import marimo

__generated_with = "0.14.16"
app = marimo.App(width="medium")


@app.cell
def _():
    import altair as alt
    import polars as pl
    return alt, pl


@app.cell
def _(pl):
    pokemon_table = pl.read_csv(
        "https://raw.githubusercontent.com/rfordatascience/tidytuesday/main/data/2025/2025-04-01/pokemon_df.csv",
        null_values="NA",
    )
    pokemon_table
    return (pokemon_table,)


@app.cell
def _(pl, pokemon_table):
    pokemon_heights = (
        pokemon_table.group_by("type_1")
        .agg(
            pl.col("height").max().alias("max_height"),
            pl.col("height").mean().alias("mean_height"),
        )
        .sort(by="mean_height", descending=True)
    )
    return (pokemon_heights,)


@app.cell
def _(alt, pokemon_heights):
    alt.Chart(pokemon_heights).mark_bar().encode(
        alt.Y("type_1"), alt.X("mean_height")
    )
    return


@app.cell
def _():
    return


if __name__ == "__main__":
    app.run()
