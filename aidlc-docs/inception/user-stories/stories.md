# User Stories — Expense Calculator App

Stories organized by **user journey**: Onboarding → Daily Use → Reporting → Exporting

---

## Epic 1: Onboarding & Setup

### US-1.1: Quick Setup
**As** Rahul, **I want** to set up the app in under a minute, **so that** I can start tracking expenses immediately.

**Acceptance Criteria:**
- App asks for name, PIN setup, and SMS permission in 3 steps
- Setup can be completed without internet
- User lands on dashboard after setup

**Traces to**: FR-6.1, FR-1.1

---

### US-1.2: SMS Permission Request
**As** Rahul, **I want** a clear explanation of why SMS access is needed, **so that** I feel comfortable granting the permission.

**Acceptance Criteria:**
- Permission screen explains "to auto-detect expenses from bank alerts"
- User can skip SMS permission and use manual entry only
- Permission can be granted later from settings

**Traces to**: FR-1.1

---

### US-1.3: PIN Setup
**As** Rahul, **I want** to set a PIN during setup, **so that** my expense data is protected from the start.

**Acceptance Criteria:**
- PIN is 4-6 digits
- User must confirm PIN by entering twice
- Biometric setup offered after PIN setup (if device supports it)

**Traces to**: FR-6.1, FR-6.2

---

## Epic 2: Daily Expense Input

### US-2.1: Auto-Detect Expense from SMS
**As** Rahul, **I want** the app to automatically detect expenses from my bank SMS alerts, **so that** I don't have to manually enter every transaction.

**Acceptance Criteria:**
- App reads incoming SMS and identifies transaction messages using generic patterns
- Detected expense shows amount, description, and date for user confirmation
- User can edit details before saving or dismiss if not an expense

**Traces to**: FR-1.1

---

### US-2.2: Manual Expense Entry
**As** Rahul, **I want** to manually add an expense quickly, **so that** I can log cash transactions or expenses not captured by SMS.

**Acceptance Criteria:**
- Entry requires only amount and category (description optional)
- Date defaults to today, can be changed
- Entry saves in 2 taps or fewer from home screen

**Traces to**: FR-1.2

---

### US-2.3: Assign Category to Expense
**As** Rahul, **I want** to assign a category to each expense, **so that** I can understand where my money goes.

**Acceptance Criteria:**
- Category picker shows all default and custom categories
- Most recently used categories appear at the top
- Category is required before saving

**Traces to**: FR-2.1, FR-2.2

---

### US-2.4: Edit Existing Expense
**As** Rahul, **I want** to edit a previously recorded expense, **so that** I can fix mistakes or update details.

**Acceptance Criteria:**
- All fields (amount, category, description, date) are editable
- Changes are saved immediately
- Edit is accessible from expense list and expense detail view

**Traces to**: FR-3.2

---

### US-2.5: Delete Expense
**As** Rahul, **I want** to delete an incorrectly recorded expense, **so that** my reports remain accurate.

**Acceptance Criteria:**
- Delete requires confirmation dialog
- Deleted expense is removed from all reports and totals
- Action cannot be undone (confirmed via dialog)

**Traces to**: FR-3.2

---

## Epic 3: Categories Management

### US-3.1: View Default Categories
**As** Rahul, **I want** to see a predefined list of expense categories, **so that** I can quickly categorize common expenses.

**Acceptance Criteria:**
- All 13 default categories are visible
- Each category has an icon and color
- Default categories cannot be deleted

**Traces to**: FR-2.1

---

### US-3.2: Create Custom Category
**As** Rahul, **I want** to create my own expense category, **so that** I can track expenses specific to my lifestyle.

**Acceptance Criteria:**
- User provides category name, selects icon and color
- Custom category appears alongside default categories
- Duplicate names are not allowed

**Traces to**: FR-2.2

---

### US-3.3: Edit Custom Category
**As** Rahul, **I want** to rename or change the icon of a custom category, **so that** I can keep my categories organized.

**Acceptance Criteria:**
- Name, icon, and color can be changed
- Existing expenses retain the updated category
- Cannot rename to an existing category name

**Traces to**: FR-2.2

---

### US-3.4: Delete Custom Category
**As** Rahul, **I want** to delete a custom category I no longer use, **so that** my category list stays clean.

**Acceptance Criteria:**
- Deletion prompts to reassign existing expenses to another category
- User must choose a target category before deletion completes
- Default categories cannot be deleted

**Traces to**: FR-2.2

---

## Epic 4: Dashboard & Visualization

### US-4.1: View Monthly Dashboard
**As** Rahul, **I want** to see a dashboard showing my current month's spending at a glance, **so that** I know my financial status immediately.

**Acceptance Criteria:**
- Shows total expenses for current month
- Shows percentage change vs previous month
- Displays category breakdown as pie chart
- Shows recent transactions list

**Traces to**: FR-3.1

---

### US-4.2: View Spending Trends
**As** Rahul, **I want** to see daily spending trends as a chart, **so that** I can identify days when I overspend.

**Acceptance Criteria:**
- Bar or line chart showing daily spending for current month
- Tap on a day shows that day's expense breakdown
- Average daily spend line shown for reference

**Traces to**: FR-3.1

---

### US-4.3: View Top Categories
**As** Rahul, **I want** to see which categories I spend the most on, **so that** I can identify areas to cut back.

**Acceptance Criteria:**
- Top spending categories shown with amounts and percentages
- Tap on a category shows detailed expense list for that category
- Visual indicator (color-coded) for quick recognition

**Traces to**: FR-3.1

---

### US-4.4: Filter Expense List
**As** Rahul, **I want** to filter my expenses by date, category, or amount, **so that** I can find specific transactions.

**Acceptance Criteria:**
- Filter by date range (custom, this week, this month, last month)
- Filter by one or more categories
- Filter by amount range (min/max)
- Search by description text

**Traces to**: FR-3.2

---

### US-4.5: View Past Months
**As** Rahul, **I want** to view any previous month's expenses and dashboard, **so that** I can review historical spending.

**Acceptance Criteria:**
- Month picker allows selecting any month within stored data (up to 2 years)
- Dashboard updates to show selected month's data
- All charts and metrics reflect the selected month

**Traces to**: FR-3.3

---

## Epic 5: Reports

### US-5.1: View Weekly Report
**As** Rahul, **I want** to see a weekly expense summary, **so that** I can monitor my spending on a weekly basis.

**Acceptance Criteria:**
- Shows total spent in the selected week
- Category breakdown with percentages
- Comparison with previous week (increase/decrease)

**Traces to**: FR-4.1

---

### US-5.2: View Monthly Report
**As** Rahul, **I want** to see a detailed monthly expense report, **so that** I can review my full month's financial activity.

**Acceptance Criteria:**
- Total spent with category pie chart
- Daily trend chart for the month
- Top 5 categories with amounts
- Average daily spending figure

**Traces to**: FR-4.2

---

### US-5.3: Compare Periods
**As** Rahul, **I want** to compare this month's spending with last month, **so that** I can see if my spending habits are improving.

**Acceptance Criteria:**
- Shows percentage change in total spending
- Category-by-category comparison
- Visual indicator (green for decrease, red for increase)

**Traces to**: FR-4.1, FR-4.2

---

## Epic 6: Data Export

### US-6.1: Export to Excel
**As** Rahul, **I want** to export my expenses to an Excel file, **so that** I can analyze data in a spreadsheet or share with my accountant.

**Acceptance Criteria:**
- Generates .xlsx file with columns: Date, Amount, Category, Description
- User can select date range for export
- User can filter by categories before export
- File saved to device downloads or shared via share sheet

**Traces to**: FR-5.1

---

### US-6.2: Export Report as PDF
**As** Rahul, **I want** to export a monthly report as a PDF, **so that** I can save or share a formatted summary.

**Acceptance Criteria:**
- PDF includes charts, totals, and category breakdown
- PDF is formatted for readability (not just raw data)
- Shareable via device share functionality (WhatsApp, email, etc.)

**Traces to**: FR-5.2

---

## Epic 7: Authentication & Security

### US-7.1: Unlock with PIN
**As** Rahul, **I want** to unlock the app with my PIN, **so that** only I can see my financial data.

**Acceptance Criteria:**
- App requires PIN on every launch
- Locks after configurable inactivity timeout
- Shows error after 3 incorrect attempts with brief lockout

**Traces to**: FR-6.1

---

### US-7.2: Unlock with Biometric
**As** Rahul, **I want** to unlock the app with my fingerprint or face, **so that** access is quick and secure.

**Acceptance Criteria:**
- Biometric prompt appears on app launch (if enabled)
- Falls back to PIN if biometric fails or is unavailable
- Can be enabled/disabled from settings

**Traces to**: FR-6.2

---

### US-7.3: Change PIN
**As** Rahul, **I want** to change my PIN from settings, **so that** I can update my security if needed.

**Acceptance Criteria:**
- Requires current PIN before allowing change
- New PIN must be confirmed by entering twice
- Success confirmation shown after change

**Traces to**: FR-6.1

---

## Epic 8: Settings & Data Management

### US-8.1: Backup Data
**As** Rahul, **I want** to back up my expense data to a local file, **so that** I don't lose data if I change phones.

**Acceptance Criteria:**
- Creates a backup file containing all expenses, categories, and settings
- File can be saved to device storage or shared
- Shows backup date and size

**Traces to**: FR-7.2

---

### US-8.2: Restore Data
**As** Rahul, **I want** to restore my data from a backup file, **so that** I can recover my expenses on a new device.

**Acceptance Criteria:**
- User selects a backup file from device storage
- Warns that restore will replace current data
- Restores all expenses, categories, and settings

**Traces to**: FR-7.2

---

### US-8.3: Toggle Theme
**As** Rahul, **I want** to switch between light and dark themes, **so that** the app is comfortable to use in any lighting.

**Acceptance Criteria:**
- Light, dark, and system-default options available
- Theme changes apply immediately
- Preference persists across app restarts

**Traces to**: NFR-3

---

### US-8.4: Manage Inactivity Timeout
**As** Rahul, **I want** to set how long the app stays unlocked when idle, **so that** I can balance convenience and security.

**Acceptance Criteria:**
- Options: Immediately, 1 minute, 5 minutes, 15 minutes
- Default is 1 minute
- Setting persists across restarts

**Traces to**: FR-6.1

---

## INVEST Criteria Validation

| Criteria | Status | Notes |
|----------|--------|-------|
| **Independent** | ✅ | Each story can be implemented and delivered independently |
| **Negotiable** | ✅ | Stories describe goals, not implementation details |
| **Valuable** | ✅ | Each story delivers clear user value |
| **Estimable** | ✅ | Stories are well-defined enough to estimate effort |
| **Small** | ✅ | Each story is achievable within a single sprint/iteration |
| **Testable** | ✅ | Acceptance criteria provide clear pass/fail conditions |

---

## Story-Persona Mapping Summary

| Epic | Stories | Primary Persona | Secondary Persona |
|------|---------|-----------------|-------------------|
| Onboarding & Setup | US-1.1 to US-1.3 | Rahul | Priya |
| Daily Expense Input | US-2.1 to US-2.5 | Rahul | — |
| Categories Management | US-3.1 to US-3.4 | Rahul | Priya |
| Dashboard & Visualization | US-4.1 to US-4.5 | Rahul | Priya |
| Reports | US-5.1 to US-5.3 | Rahul | Priya |
| Data Export | US-6.1 to US-6.2 | Rahul | Priya |
| Authentication & Security | US-7.1 to US-7.3 | Rahul | Priya |
| Settings & Data Management | US-8.1 to US-8.4 | Rahul | Priya |

**Total**: 8 Epics, 26 User Stories
