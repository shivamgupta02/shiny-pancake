# Business Logic — Unit 4: Reports

## Weekly Report Generation

### Input
- Week start date (Monday)

### Calculation Logic
1. **Date range**: Monday 00:00:00 to Sunday 23:59:59
2. **Total spent**: Sum all expenses in date range
3. **Category breakdown**: Group by category, calculate total and percentage per category
4. **Day-by-day**: Sum expenses per day (Mon–Sun), show 0 for days with no expenses
5. **Previous week comparison**:
   - Previous week = 7 days before current week start
   - Percentage change = ((current - previous) / previous) * 100
   - If no previous week data: show "0% — First week" with neutral indicator
6. **Average daily**: Total / 7

### Output: WeeklyReport
| Field | Type | Description |
|-------|------|-------------|
| weekStart | DateTime | Monday of the week |
| weekEnd | DateTime | Sunday of the week |
| totalSpent | double | Sum of all expenses |
| categoryBreakdown | List<CategoryTotal> | Per-category totals |
| dailyTotals | List<DailyTotal> (7 items) | Mon–Sun amounts |
| previousWeekTotal | double? | Previous week's total (null if first week) |
| percentageChange | double | Change vs previous week |
| averageDaily | double | Total / 7 |

---

## Monthly Report Generation

### Input
- Target month (year + month)

### Calculation Logic
1. **Date range**: 1st of month 00:00:00 to last day 23:59:59
2. **Total spent**: Sum all expenses in month
3. **Category breakdown**: Group by category with totals and percentages, sorted descending
4. **Pie chart data**: Top 5 categories + "Others" aggregate
5. **Daily trend**: Sum per day for entire month (show 0 for empty days)
6. **Top 5 categories**: Highest spending categories with amounts
7. **Average daily spending**: Total / number of days in month
8. **Previous month comparison**:
   - Previous month = month - 1
   - Percentage change = ((current - previous) / previous) * 100
   - First month rule: Show "0% — First month" with neutral indicator

### Output: MonthlyReport
| Field | Type | Description |
|-------|------|-------------|
| month | DateTime | First day of target month |
| totalSpent | double | Sum of all expenses |
| categoryBreakdown | List<CategoryTotal> | Per-category totals sorted desc |
| dailyTotals | List<DailyTotal> | Day 1 to last day amounts |
| topCategories | List<CategoryTotal> (5) | Top 5 spending categories |
| averageDaily | double | Total / days in month |
| previousMonthTotal | double? | Previous month total (null if first) |
| percentageChange | double | Change vs previous month |
| daysInMonth | int | Calendar days count |

---

## Period Comparison Logic

### Comparison Data
| Field | Type | Description |
|-------|------|-------------|
| currentTotal | double | Current period total |
| previousTotal | double | Previous period total |
| absoluteChange | double | current - previous |
| percentageChange | double | ((current - previous) / previous) * 100 |
| direction | CompareDirection | increase / decrease / unchanged |
| isFirstPeriod | bool | True if no previous data |

### Direction Rules
- If percentageChange > 0: `increase` (red indicator — spending went up)
- If percentageChange < 0: `decrease` (green indicator — spending went down)
- If percentageChange == 0: `unchanged` (gray indicator)
- If isFirstPeriod: show neutral with "First [week/month]" label

### Edge Cases
- Division by zero (previous = 0, current > 0): Show "New" instead of percentage
- Both zero: Show "No expenses" message
- Previous exists but current is 0: Show "-100%" decrease
