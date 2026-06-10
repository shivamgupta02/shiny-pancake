# Business Logic — Unit 5: Export

## Excel Export (.xlsx)

### Input: ExportFilter
| Field | Type | Description |
|-------|------|-------------|
| dateFrom | DateTime | Start date |
| dateTo | DateTime | End date |
| categoryIds | List<String>? | Filter by categories (null = all) |

### File Structure
- **Sheet name**: "Expenses"
- **Header row (bold)**: Date | Amount (₹) | Category | Description
- **Data rows**: One row per expense, sorted by date ascending
- **Summary row at bottom**: | | Total: ₹XX,XXX.XX | | |
- **Column widths**: Date (12), Amount (15), Category (20), Description (40)

### File Naming
- Format: `expenses_{dateFrom}_{dateTo}.xlsx`
- Example: `expenses_2026-01-01_2026-06-30.xlsx`

### Generation Logic
1. Query expenses matching filter from repository
2. Create Excel workbook with single sheet
3. Write header row with bold formatting
4. Write each expense as a row: date (DD-MMM-YYYY), amount (2 decimal), category name, description
5. Write summary row with total
6. Save to app's export directory
7. Return file path

---

## PDF Export

### Input
- MonthlyReport data (from Reports unit)

### PDF Layout
```
+------------------------------------------+
|           EXPENSE REPORT                  |
|           [Month Year]                    |
+------------------------------------------+
|                                           |
|  Total Spent: ₹XX,XXX.XX                |
|  Average Daily: ₹X,XXX.XX               |
|  vs Previous Month: +X.X% ↑              |
|                                           |
+------------------------------------------+
|  CATEGORY BREAKDOWN                       |
|  [Pie chart or table]                     |
|  Category    | Amount    | %              |
|  Food        | ₹5,000   | 25%            |
|  Transport   | ₹3,000   | 15%            |
|  ...         | ...       | ...            |
+------------------------------------------+
|  DAILY TREND                              |
|  [Bar chart or table with daily totals]   |
+------------------------------------------+
|  Generated on: DD-MMM-YYYY               |
+------------------------------------------+
```

### Generation Logic
1. Receive MonthlyReport data
2. Create PDF document (A4 portrait)
3. Add header with month/year title
4. Add summary section (total, average, comparison)
5. Add category breakdown table (sorted by amount desc)
6. Add daily totals table (or simplified bar representation)
7. Add footer with generation date
8. Save to app's export directory
9. Return file path

### File Naming
- Format: `report_{month}_{year}.pdf`
- Example: `report_june_2026.pdf`

---

## Share Logic
1. Get file path from export operation
2. Check file exists
3. Open platform share sheet with file
4. User chooses destination (WhatsApp, email, Drive, etc.)

---

## Export Progress
- Show indeterminate progress bar during generation
- Display "Generating Excel..." or "Generating PDF..." message
- On success: Show "Export complete" with "Share" and "Done" buttons
- On error: Show "Export failed" with error message and retry option
