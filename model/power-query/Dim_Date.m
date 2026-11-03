// Dim_Date: daily calendar for one fiscal year, with fiscal columns
// Change only FYStartYear and FirstMonth to reuse for another year / fiscal calendar.
let
    FYStartYear = 2025,     // FY26 starts in calendar year 2025
    FirstMonth  = 7,        // fiscal year starts in July

    StartDate = #date(FYStartYear, FirstMonth, 1),
    EndDate   = Date.EndOfMonth(Date.AddMonths(StartDate, 11)),

    // 1) every day from start to end
    Dates = List.Dates(StartDate, Duration.Days(EndDate - StartDate) + 1, #duration(1, 0, 0, 0)),
    DateTable = Table.FromList(Dates, Splitter.SplitByNothing(), {"Date"}),
    Typed = Table.TransformColumnTypes(DateTable, {{"Date", type date}}),

    // 2) fiscal year, fiscal month, and the key that matches the FX table
    AddFiscal = Table.AddColumn(Typed, "Fiscal", each
        let
            M  = Date.Month([Date]),
            Y  = Date.Year([Date]),
            FM = Number.Mod(M - FirstMonth + 12, 12) + 1,
            FY = if FirstMonth = 1 then Y else if M >= FirstMonth then Y + 1 else Y
        in
            [FiscalYear = FY, FiscalMonth = FM, FiscalPeriodKey = FY * 1000 + FM]
    ),
    Expanded = Table.ExpandRecordColumn(AddFiscal, "Fiscal", {"FiscalYear", "FiscalMonth", "FiscalPeriodKey"}),

    // 3) label used on slicers, matrix and chart (sort it by FiscalPeriodKey)
    AddLabel = Table.AddColumn(
        Expanded, "Month Display",
        each Date.ToText([Date], [Format = "MMM-yy", Culture = "en-US"]),
        type text
    ),
    Result = Table.TransformColumnTypes(
        AddLabel,
        {{"FiscalYear", Int64.Type}, {"FiscalMonth", Int64.Type}, {"FiscalPeriodKey", Int64.Type}}
    )
in
    Result
