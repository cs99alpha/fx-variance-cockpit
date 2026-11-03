// Dim_Currency: reporting-currency slicer + display symbol
let
    Source = Table.FromRows(
        {
            {"USD", "$"},
            {"EUR", "€"},
            {"GBP", "£"},
            {"CHF", "CHF"}
        },
        type table [Currency = text, Symbol = text]
    )
in
    Source
