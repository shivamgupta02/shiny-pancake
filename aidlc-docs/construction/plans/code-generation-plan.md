# Code Generation Plan — Expense Calculator App (All Units)

## Context
- **Project type**: Greenfield Flutter monolith
- **Workspace root**: /Users/facewatch-sg/work/projects/shiny-pancake
- **Code location**: Workspace root (`lib/`, `pubspec.yaml`, etc.)
- **Units**: 7 units in sequence (Foundation → Expenses & Categories → Dashboard → Reports → Export → SMS → Auth & Settings)

## Unit Dependencies
- Unit 1 (Foundation): No dependencies — built first
- Unit 2 (Expenses & Categories): Depends on Unit 1
- Unit 3 (Dashboard): Depends on Units 1, 2
- Unit 4 (Reports): Depends on Units 1, 2
- Unit 5 (Export): Depends on Units 1, 2, 4
- Unit 6 (SMS): Depends on Units 1, 2
- Unit 7 (Auth & Settings): Depends on Unit 1

---

## UNIT 1: Foundation

- [x] Step 1.1: Create Flutter project structure and pubspec.yaml with all dependencies
- [x] Step 1.2: Create core module (theme, constants, utils, DI setup)
- [x] Step 1.3: Create data models (Expense, Category, AppSettings Isar schemas)
- [x] Step 1.4: Create database service (initialization, schema registration)
- [x] Step 1.5: Create repositories (ExpenseRepository, CategoryRepository, SettingsRepository)
- [x] Step 1.6: Create app shell with bottom navigation and placeholder screens
- [x] Step 1.7: Create main.dart with BLoC providers and DI initialization

---

## UNIT 2: Expenses & Categories

- [x] Step 2.1: Create ExpenseBloc (states, events, CRUD logic)
- [x] Step 2.2: Create Expense screens (list, add, edit)
- [x] Step 2.3: Create CategoryBloc (states, events, CRUD logic)
- [x] Step 2.4: Create Category screens (list, create, edit)
- [x] Step 2.5: Create category picker widget and integrate with expense forms
- [x] Step 2.6: Create filter/search functionality for expense list

---

## UNIT 3: Dashboard & Visualization

- [x] Step 3.1: Create DashboardBloc (load metrics, month navigation)
- [x] Step 3.2: Create dashboard screen with layout structure
- [x] Step 3.3: Create chart widgets (pie chart, bar chart using fl_chart)
- [x] Step 3.4: Create stat cards and recent transactions widgets

---

## UNIT 4: Reports

- [x] Step 4.1: Create ReportBloc (weekly/monthly generation, comparison)
- [x] Step 4.2: Create report screens (weekly, monthly) with charts and data

---

## UNIT 5: Export

- [x] Step 5.1: Create ExportService (Excel and PDF generation)
- [x] Step 5.2: Create ExportBloc and export screen with filter options and share

---

## UNIT 6: SMS Auto-Detection

- [x] Step 6.1: Create SmsParsingService (regex patterns, extraction logic, confidence scoring)
- [x] Step 6.2: Create SmsBloc (listener, scanner, confirm/dismiss)
- [x] Step 6.3: Create SMS confirmation screen and notification setup

---

## UNIT 7: Authentication & Settings

- [x] Step 7.1: Create SecureStorageService and AuthBloc (PIN, biometric)
- [x] Step 7.2: Create auth screens (PIN entry, biometric prompt)
- [x] Step 7.3: Create OnboardingBloc and onboarding screens
- [x] Step 7.4: Create SettingsBloc, settings screen, and BackupService
- [x] Step 7.5: Integrate auth gate into app shell (lock/unlock flow)

---

## Story Traceability

| Step | Stories Implemented |
|------|-------------------|
| 1.1-1.7 | (Foundation — enables all stories) |
| 2.1-2.2 | US-2.2, US-2.4, US-2.5 |
| 2.3-2.5 | US-2.3, US-3.1, US-3.2, US-3.3, US-3.4 |
| 2.6 | US-4.4 |
| 3.1-3.4 | US-4.1, US-4.2, US-4.3, US-4.5 |
| 4.1-4.2 | US-5.1, US-5.2, US-5.3 |
| 5.1-5.2 | US-6.1, US-6.2 |
| 6.1-6.3 | US-2.1 |
| 7.1-7.2 | US-7.1, US-7.2, US-7.3 |
| 7.3 | US-1.1, US-1.2, US-1.3 |
| 7.4 | US-8.1, US-8.2, US-8.3, US-8.4 |
| 7.5 | (Integration — enables US-7.x) |

**Total**: 26 stories covered across all steps
