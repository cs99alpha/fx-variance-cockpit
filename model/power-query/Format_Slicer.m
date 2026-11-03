// Format Slicer: display-unit selector (disconnected table)
let
    Source = Table.FromRows(
        { {"Absolute"}, {"Thousands"}, {"Millions"} },
        type table [Unit = text]
    )
in
    Source
