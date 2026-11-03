// Dim_Product: one row per product
let
    Source = Fact_Sales,
    Products = Table.Distinct(Table.SelectColumns(Source, {"Product"}))
in
    Products
