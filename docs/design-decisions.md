# Design decisions

Plain-language notes on why the report works the way it does.

## 1. The calendar (Power Query)

`Dim_Date` builds every day from 1 Jul 2025 to 30 Jun 2026, then adds:

- `FiscalMonth`: July = 1 ... June = 12, using `Number.Mod(month - firstMonth + 12, 12) + 1`
- `FiscalYear`: July to December belong to the *next* calendar year's fiscal year (Jul 2025 is FY26)
- `FiscalPeriodKey`: `FiscalYear × 1000 + FiscalMonth`, so Jul 2025 is `2026001`

That key has the same shape as `Fiscal Year/Period` in the FX table, which is what makes the rate lookup possible. `Month Display` (`Jul-25`) is built in the same query and sorted by `FiscalPeriodKey`.

## 2. Scenario to rate type

| Scenario | Rate type |
|---|---|
| Actuals | Monthly |
| Budget | Budget |
| Sep / Dec / Apr forecasts | Hyper Inflation |

This lives in `Dim_Scenario` as data, not in code. Changing a mapping means editing one row.

## 3. Converting a sale

For each fact row, `Sales Reporting Currency` finds the fiscal key, the rate type and the from-currency, then looks up the rate. The reporting currency comes from the slicer through `SELECTEDVALUE`. `SUMX` is used so that `RELATED` and `LOOKUPVALUE` run once per row. With about 10,000 rows this is fast and, more importantly, easy to read.

**Fallback via USD.** If there is no direct rate, the measure multiplies From → USD by USD → To. The FX table is internally consistent that way: its EUR → CHF equals EUR → USD × USD → CHF in every period and rate type.

**Missing rates return BLANK**, not zero. A zero looks like a real result and hides the problem.

## 4. Like-for-like variance

Actuals only run July to December, while Budget runs the full year. Comparing them over a selection that includes January to June makes the variance look hugely negative for the wrong reason. `Budget Sales Card` restricts Budget to the dates that have Actuals in the current selection. With no Actuals in the selection, the cards say "No actuals" instead of showing -100%.

## 5. Number formatting

`Currency Format String` returns a text format such as `"€" #,##0.0"M"`. Each money measure uses it as its **dynamic format string**, so the number stays numeric (sortable, usable in conditional formatting) while the display follows the slicers. Card text measures use `FORMAT(value, [Currency Format String])` so they can show a message when empty.

## 6. Scenario comparison

The brief asked for any three scenarios side by side. The scenario slicer is multi-select, and `Scenario Table Value` returns `BLANK()` if more than three are ticked. `ALLSELECTED` counts the slicer's choices, because a plain count inside a matrix cell would always be 1.

---

## Questions I should be able to answer

**Why `LOOKUPVALUE` and not a relationship to the FX table?**
The match needs four keys together (from-currency, to-currency, fiscal period, rate type), and Power BI relationships use one column. A composite key column would also work, but it would add a calculated column to the fact table.

**Why a custom fiscal key rather than a date join?**
The rate table is at fiscal-period grain, not day grain. A key that matches its format is the simplest join.

**What happens when a rate is missing?**
The measure returns BLANK for those rows. With GBP as the reporting currency, EUR and CHF rows have no direct rate, so the measure converts through USD. The table's own rates are built that way (checked in all 36 combinations for EUR → CHF).

**Why is the Budget card smaller than the full-year budget?**
It is like-for-like: only months that have Actuals. Otherwise variance compares different periods.

**Why dynamic format strings and not `FORMAT()` everywhere?**
`FORMAT()` returns text, which can't be sorted or used for conditional formatting. A dynamic format string keeps the value numeric.

**Why `ALLSELECTED` in `Scenarios Selected`?**
Inside a matrix cell each column is already filtered to one scenario. `ALLSELECTED` ignores that and counts what the user ticked.

**What would you do differently with more time?**
Add an FX-versus-performance split of the variance, move to a Power BI Project (`.pbip`) so that every change is visible in Git, and add automated model checks in GitHub Actions.

**What edge cases did the data force?**
See "Edge cases the model handles" in the README: pairs with no direct rate (GBP), Actuals covering six months against twelve of Budget, one format across all visuals, and markets that trade in several currencies.
