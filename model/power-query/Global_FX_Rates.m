// Global FX Rates: one rate per (from, to, fiscal period, rate type)
// Rate = units of "To Currency" per 1 unit of "From Currency"
let
    DataFolder = "C:\path\to\your\data\",   // <- change to your folder
    Source = Csv.Document(
        File.Contents(DataFolder & "Global FX Rates.csv"),
        [Delimiter = ",", Columns = 5, Encoding = 1252, QuoteStyle = QuoteStyle.None]
    ),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(
        Promoted,
        {
            {"Overall FX Rate", type number}, {"From Currency", type text}, {"To Currency", type text},
            {"Fiscal Year/Period", Int64.Type}, {"Rate Type", type text}
        }
    )
in
    Typed
