// Fact_Sales: transactional net sales, in local currency
let
    DataFolder = "C:\path\to\your\data\",   // <- change to your folder
    Source = Csv.Document(
        File.Contents(DataFolder & "CSI_Sales.csv"),
        [Delimiter = ",", Columns = 6, Encoding = 1252, QuoteStyle = QuoteStyle.None]
    ),
    Promoted = Table.PromoteHeaders(Source, [PromoteAllScalars = true]),
    Typed = Table.TransformColumnTypes(
        Promoted,
        {
            {"Scenario", type text}, {"Market", type text}, {"FromCurrency", type text},
            {"Net Sales Local", type number}, {"Calendar Date", type date}, {"Product", type text}
        }
    )
in
    Typed
