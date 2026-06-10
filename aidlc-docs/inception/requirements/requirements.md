# Requirements Document — Expense Calculator Mobile App

## Intent Analysis Summary

| Field | Value |
|-------|-------|
| **User Request** | Build a mobile expense calculator app using Flutter that reads SMS messages for auto-expense detection, supports manual input, tracks monthly expenses, shows data visually via dashboards, generates reports, stores data locally, exports to Excel/PDF, and supports custom categories |
| **Request Type** | New Project (Greenfield) |
| **Scope Estimate** | System-wide — Full mobile application with multiple screens, local storage, SMS integration, reporting, and export |
| **Complexity Estimate** | Moderate — Multiple features (SMS parsing, local DB, charts, export) but well-understood domain |

---

## Functional Requirements

### FR-1: Expense Input

#### FR-1.1: SMS Auto-Detection (Android Only)
- The app SHALL read incoming SMS messages to automatically detect expense transactions
- The app SHALL parse bank transaction alert messages to extract: amount, merchant/description, date
- The app SHALL present detected expenses to the user for confirmation before saving
- The app SHALL allow the user to edit auto-detected expense details before saving
- The app SHALL request SMS permission from the user at first launch with clear explanation

#### FR-1.2: Manual Expense Entry
- The app SHALL allow users to manually add expenses with the following fields:
  - Amount (required, in INR)
  - Category (required, from predefined or custom categories)
  - Description/Note (optional)
  - Date (required, defaults to current date)
- The app SHALL validate that amount is a positive number
- The app SHALL provide a quick-entry mode for common expenses

### FR-2: Expense Categories

#### FR-2.1: Default Categories
The app SHALL include the following default categories:
- Food & Dining
- Groceries
- Transport
- Fuel
- Rent
- Utilities
- Shopping
- Entertainment
- Health
- Education
- Travel
- Subscriptions
- Other

#### FR-2.2: Custom Categories
- The app SHALL allow users to create custom expense categories
- The app SHALL allow users to edit custom category names
- The app SHALL allow users to delete custom categories (with option to reassign existing expenses)
- The app SHALL allow users to assign an icon/color to custom categories

### FR-3: Expense Tracking & Dashboard

#### FR-3.1: Dashboard View
- The app SHALL display a dashboard as the home screen with:
  - Total expenses for current month
  - Comparison with previous month (percentage change)
  - Category-wise breakdown (pie chart)
  - Daily spending trend (bar/line chart)
  - Top spending categories
  - Recent transactions list

#### FR-3.2: Expense List
- The app SHALL display a chronological list of all expenses
- The app SHALL support filtering by: date range, category, amount range
- The app SHALL support searching expenses by description
- The app SHALL allow editing existing expenses
- The app SHALL allow deleting expenses (with confirmation)

#### FR-3.3: Monthly Tracking
- The app SHALL track expenses on a monthly basis
- The app SHALL allow users to view any past month's expenses
- The app SHALL display monthly budget vs. actual spending (if budget is set)

### FR-4: Reports

#### FR-4.1: Weekly Reports
- The app SHALL generate weekly expense summaries including:
  - Total spent in the week
  - Category breakdown with percentages
  - Day-by-day spending chart
  - Comparison with previous week

#### FR-4.2: Monthly Reports
- The app SHALL generate monthly expense reports including:
  - Total spent in the month
  - Category breakdown with pie chart
  - Daily spending trend chart
  - Top 5 expense categories
  - Average daily spending
  - Comparison with previous month

### FR-5: Data Export

#### FR-5.1: Excel Export
- The app SHALL export expense data to Excel (.xlsx) format
- The export SHALL include: date, amount, category, description
- The app SHALL allow selecting date range for export
- The app SHALL allow selecting specific categories for export

#### FR-5.2: PDF Export
- The app SHALL export reports as PDF documents
- The PDF SHALL include visual charts and summary statistics
- The PDF SHALL be shareable via device share functionality

### FR-6: Authentication & Security

#### FR-6.1: PIN Lock
- The app SHALL support a 4-6 digit PIN for app access
- The app SHALL lock after configurable inactivity timeout
- The app SHALL allow PIN change from settings

#### FR-6.2: Biometric Authentication
- The app SHALL support fingerprint authentication (where device supports it)
- The app SHALL support face recognition authentication (where device supports it)
- The app SHALL fall back to PIN if biometric fails

### FR-7: Local Data Storage

#### FR-7.1: Storage
- The app SHALL store all expense data locally using Hive/Isar database
- The app SHALL NOT require internet connectivity for core functionality
- The app SHALL handle data corruption gracefully with recovery options

#### FR-7.2: Data Management
- The app SHALL allow data backup (local file export)
- The app SHALL allow data restore from backup file

---

## Non-Functional Requirements

### NFR-1: Performance
- The app SHALL launch within 2 seconds on mid-range Android devices
- Dashboard SHALL load within 1 second
- SMS parsing SHALL complete within 500ms per message
- Export generation SHALL complete within 5 seconds for up to 1 year of data

### NFR-2: Storage
- The app SHALL efficiently store at least 2 years of expense data
- The app SHALL support more than 50 expenses per month
- Database size SHALL not exceed 100MB for typical usage

### NFR-3: Usability
- The app SHALL follow Material Design 3 guidelines
- The app SHALL support light and dark themes
- The app SHALL be accessible (proper contrast ratios, screen reader support)
- The app SHALL support English language only

### NFR-4: Compatibility
- The app SHALL support Android 8.0 (API 26) and above
- The app SHALL be prepared for future iOS support via Flutter cross-platform
- The app SHALL handle different screen sizes (phone and tablet)

### NFR-5: Data Safety
- PIN/biometric data SHALL be stored securely using platform secure storage
- Expense data SHALL be stored encrypted at rest
- Export files SHALL not contain authentication credentials

---

## Technical Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Flutter | Cross-platform, user specified |
| Platform (v1) | Android | User specified, iOS later |
| Currency | INR (single) | User specified |
| Local Storage | Hive/Isar | User preferred, Flutter-optimized, fast NoSQL |
| State Management | TBD | To be decided in Application Design |
| Charts | TBD | To be decided in Application Design |

---

## Future Considerations (Post-V1)

- iOS support (Flutter enables this with minimal additional work)
- Multi-user/family expense sharing
- Recurring/scheduled expense auto-addition
- Cloud backup and sync
- Budget planning and goal setting
- Bill reminders and notifications
