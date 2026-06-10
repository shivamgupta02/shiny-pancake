# Functional Design Plan — All Units

## Plan Overview
Since this is a single monolithic Flutter app, the functional design covers business logic across all 7 units in sequence. Unit 1 (Foundation) focuses on data model design. Units 2-7 focus on feature-specific business logic.

---

## Clarifying Questions

### Question 1
For SMS parsing, what information is typically in your bank transaction SMS messages? This helps define parsing patterns.

A) Format like: "Rs.500 debited from A/c XX1234 on 09-Jun. UPI/Merchant Name. Avl bal: Rs.10000"

B) Format like: "You have spent Rs 500 at Merchant on card ending 1234"

C) Various formats — the app should handle multiple patterns flexibly

D) Other (please describe after [Answer]: tag below)

[Answer]: A

---

### Question 2
When an expense is deleted, should the app keep any history or is permanent deletion fine?

A) Permanent deletion — no trace remains

B) Soft delete — mark as deleted but keep in DB (can be recovered within 30 days)

C) Other (please describe after [Answer]: tag below)

[Answer]: A

---

### Question 3
For the dashboard "comparison with previous month", what should happen in the first month of usage (no previous data)?

A) Show "No previous data" message in comparison area

B) Hide the comparison section entirely until 2+ months of data exist

C) Show 0% change with a note that it's the first month

D) Other (please describe after [Answer]: tag below)

[Answer]: C

---

---

## Generation Steps (Per Unit)

### Unit 1: Foundation
- [x] Define domain entities (Expense, Category, AppSettings) with field-level validation rules
- [x] Define default category seed data
- [x] Define database schema and relationships

### Unit 2: Expenses & Categories
- [x] Define expense CRUD business rules and validation
- [x] Define category management rules (create, edit, delete with reassignment)
- [x] Define filter/search logic

### Unit 3: Dashboard
- [x] Define metrics calculation logic (totals, averages, comparisons)
- [x] Define chart data transformation rules

### Unit 4: Reports
- [x] Define weekly/monthly report generation logic
- [x] Define period comparison calculation rules

### Unit 5: Export
- [x] Define Excel file structure and formatting rules
- [x] Define PDF report layout and content rules

### Unit 6: SMS
- [x] Define SMS parsing patterns and extraction rules
- [x] Define detection confidence logic and user confirmation flow

### Unit 7: Auth & Settings
- [x] Define PIN validation and security rules
- [x] Define backup/restore data format and validation
