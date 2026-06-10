# Business Logic — Unit 3: Dashboard & Visualization

## Metrics Calculation

### Monthly Total
- Sum all expense amounts where date is within the target month (1st to last day)
- Format as INR with 2 decimal places

### Previous Month Comparison
- Calculate total for previous month
- Percentage change = ((current - previous) / previous) * 100
- **First month rule (BR)**: If no previous month data exists, show "0% ↑ First month" with neutral indicator
- Display: Green arrow down for decrease, Red arrow up for increase

### Category Breakdown (Pie Chart)
- Group expenses by categoryId for the target month
- Calculate: total per category, percentage of monthly total
- Sort by amount descending
- Include category name and color for chart rendering
- If more than 6 categories, show top 5 + "Others" (aggregate remaining)

### Daily Spending Trend (Bar Chart)
- Get all expenses for target month
- Group by date (day)
- Sum amount per day
- Days with no expenses show as 0
- Calculate average daily spend (total / days elapsed in month)
- Show average as reference line on chart

### Top Spending Categories
- Same data as pie chart but displayed as ranked list
- Show top 5 categories with: name, icon, color, total amount, percentage
- Tap on category navigates to filtered expense list

### Recent Transactions
- Query last 10 expenses ordered by date descending, then createdAt descending
- Display: date, amount, category icon/color, description (truncated at 40 chars)

---

## Month Navigation

### Change Month Logic
1. User selects a month from month picker
2. Validate month is within 2-year retention window
3. Reload all dashboard metrics for selected month
4. Update comparison to use the month before selected month

### Month Picker Constraints
- Earliest: 2 years before current month
- Latest: Current month
- Display format: "June 2026", "May 2026", etc.
- Default: Current month on app launch

---

## Dashboard Refresh Logic
- Auto-refresh when returning to dashboard tab (if expense data changed)
- Pull-to-refresh gesture supported
- Loading state shown during data fetch
- Error state with retry button if data load fails
