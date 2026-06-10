# Requirements Verification Questions

Please answer the following questions to help clarify the requirements for the Expense Calculator mobile app. Fill in the letter choice after each [Answer]: tag.

---

## Question 1
You mentioned the app should "read my messages" for expenses. What does this mean?

A) Read SMS messages to automatically detect expenses (e.g., bank transaction alerts)

B) Read notification messages from banking/payment apps

C) Allow copy-pasting text from messages for expense parsing

D) This feature is not critical — manual input is sufficient

E) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 2
What platforms should the app support at launch?

A) Android only initially, iOS later

B) iOS only initially, Android later

C) Both Android and iOS simultaneously from launch

D) Other (please describe after [Answer]: tag below)

[Answer]: A

---

## Question 3
What kind of regular reports do you want?

A) Daily expense summary

B) Weekly expense summary

C) Monthly expense summary with category breakdown

D) Both weekly and monthly reports with charts

E) Other (please describe after [Answer]: tag below)

[Answer]: D

---

## Question 4
How should the reports be presented visually?

A) Simple list with totals

B) Charts and graphs (pie charts for categories, bar charts for trends)

C) Dashboard-style view with key metrics and visualizations

D) Other (please describe after [Answer]: tag below)

[Answer]: C

---

## Question 5
What currency should the app support?

A) Single currency (specify which one)

B) Multiple currencies with manual selection per expense

C) Multiple currencies with automatic conversion

D) Other (please describe after [Answer]: tag below)

[Answer]: A (INR)

---

## Question 6
What local storage approach do you prefer?

A) SQLite database (structured, good for querying)

B) Hive/Isar (NoSQL, Flutter-optimized, fast)

C) No preference — let me recommend the best option

D) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 7
What default expense categories should be included?

A) Basic: Food, Transport, Bills, Shopping, Entertainment, Health, Other

B) Detailed: Food & Dining, Groceries, Transport, Fuel, Rent, Utilities, Shopping, Entertainment, Health, Education, Travel, Subscriptions, Other

C) Minimal: Food, Transport, Bills, Other (user creates the rest)

D) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 8
Should the app have any authentication/security features?

A) No authentication — open access (personal device only)

B) Simple PIN/password lock

C) Biometric authentication (fingerprint/face)

D) Both PIN and biometric options

E) Other (please describe after [Answer]: tag below)

[Answer]: D

---

## Question 9
What is the target audience for this app?

A) Personal use only (single user)

B) Personal use with potential for multi-user/family sharing later

C) Small business expense tracking

D) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 10
Should the app support recurring/scheduled expenses (e.g., monthly subscriptions, rent)?

A) Yes — allow users to set up recurring expenses that auto-add

B) No — all expenses are manually added each time

C) Nice-to-have but not critical for first version

D) Other (please describe after [Answer]: tag below)

[Answer]: C

---

## Question 11: Security Extensions
Should security extension rules be enforced for this project?

A) Yes — enforce all SECURITY rules as blocking constraints (recommended for production-grade applications)

B) No — skip all SECURITY rules (suitable for PoCs, prototypes, and experimental projects)

C) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 12: Resiliency Extensions
Should the resiliency baseline be applied to this project?

**What this extension is.** Enabling it applies a set of directional, design-time best practices for building resilient systems, derived from the AWS Well-Architected Framework (Reliability Pillar) and resilience-review guidance. It steers requirements, design, and code toward fault tolerance, high availability, observability, and recoverability.

**What this extension is NOT.** This is a mobile app with local storage, so many cloud-focused resiliency practices may not directly apply. However, data durability and graceful error handling are relevant.

A) Yes — apply the resiliency baseline as directional best practices and design-time guidance

B) No — skip the resiliency baseline (suitable for this local-storage mobile app)

C) Other (please describe after [Answer]: tag below)

[Answer]: B

---

## Question 13: Property-Based Testing Extension
Should property-based testing (PBT) rules be enforced for this project?

A) Yes — enforce all PBT rules as blocking constraints (recommended for projects with business logic, data transformations, serialization, or stateful components)

B) Partial — enforce PBT rules only for pure functions and serialization round-trips (suitable for projects with limited algorithmic complexity)

C) No — skip all PBT rules (suitable for simple CRUD applications, UI-only projects, or thin integration layers with no significant business logic)

D) Other (please describe after [Answer]: tag below)

[Answer]: B

---
