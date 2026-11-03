// Dim_Scenario: which FX rate type each scenario must use
let
    Source = Table.FromRows(
        {
            {"Actuals",  "Monthly2026"},
            {"Budget",   "Budget2026"},
            {"Sep Fcst", "Hyper Inflation2026"},
            {"Dec Fcst", "Hyper Inflation2026"},
            {"Apr Fcst", "Hyper Inflation2026"}
        },
        type table [Scenario = text, #"Rate Type" = text]
    )
in
    Source
