// Dim_Market: one row per market (no currency column: a market can trade in several currencies)
let
    Source = Fact_Sales,
    Markets = Table.Distinct(Table.SelectColumns(Source, {"Market"}))
in
    Markets
