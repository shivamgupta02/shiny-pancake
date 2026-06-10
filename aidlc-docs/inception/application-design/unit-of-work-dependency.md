# Unit of Work Dependencies — Expense Calculator App

## Dependency Matrix

| Unit | Depends On | Required Before |
|------|-----------|-----------------|
| **Unit 1: Foundation** | — (no dependencies) | All other units |
| **Unit 2: Expenses & Categories** | Unit 1 | Units 3, 4, 5, 6 |
| **Unit 3: Dashboard** | Unit 1, Unit 2 | — |
| **Unit 4: Reports** | Unit 1, Unit 2 | Unit 5 (PDF export uses report data) |
| **Unit 5: Export** | Unit 1, Unit 2, Unit 4 | — |
| **Unit 6: SMS** | Unit 1, Unit 2 | — |
| **Unit 7: Auth & Settings** | Unit 1 | — (wraps existing app) |

---

## Dependency Graph

```
Unit 1: Foundation
    │
    ├──────────────────────────────────────┐
    │                                      │
    ▼                                      ▼
Unit 2: Expenses & Categories        Unit 7: Auth & Settings
    │
    ├─────────────┬─────────────┐
    │             │             │
    ▼             ▼             ▼
Unit 3:       Unit 4:       Unit 6:
Dashboard     Reports       SMS
                │
                ▼
            Unit 5:
            Export
```

---

## Build Order (Sequential)

| Order | Unit | Can Start After | Estimated Complexity |
|-------|------|-----------------|---------------------|
| 1 | Foundation | — | Medium (project setup, DB, models) |
| 2 | Expenses & Categories | Unit 1 complete | High (CRUD, filters, search, picker) |
| 3 | Dashboard & Visualization | Unit 2 complete | Medium (charts, metrics) |
| 4 | Reports | Unit 2 complete | Medium (report logic, charts) |
| 5 | Export | Unit 4 complete | Medium (Excel/PDF generation) |
| 6 | SMS Auto-Detection | Unit 2 complete | High (SMS parsing, background service) |
| 7 | Auth & Settings | Unit 1 complete | Medium (PIN, biometric, backup) |

**Note**: Units 3, 4, 6, and 7 can technically be developed in parallel after Unit 2 is complete. The sequential order (A priority) is recommended for solo development.

---

## Integration Points Between Units

| From | To | Integration Type | Description |
|------|-----|-----------------|-------------|
| Unit 2 → Unit 3 | Data stream | Dashboard subscribes to expense changes for auto-refresh |
| Unit 2 → Unit 4 | Data query | Reports query expenses via repository |
| Unit 4 → Unit 5 | Data pass | PDF export receives MonthlyReport data |
| Unit 2 → Unit 5 | Data query | Excel export queries filtered expenses |
| Unit 6 → Unit 2 | Data write | Confirmed SMS expenses saved via ExpenseRepository |
| Unit 7 → All | Gate | Auth screen wraps entire app navigation |
| Unit 7 → Unit 6 | Permission | Onboarding requests SMS permission for Unit 6 |

---

## Shared Resources

| Resource | Owner Unit | Used By |
|----------|-----------|---------|
| ExpenseRepository | Unit 1 (defined) / Unit 2 (implemented) | Units 3, 4, 5, 6 |
| CategoryRepository | Unit 1 (defined) / Unit 2 (implemented) | Units 3, 4, 5 |
| SettingsRepository | Unit 1 (defined) / Unit 7 (implemented) | Unit 6 (SMS enabled check) |
| DatabaseService | Unit 1 | All units (via repositories) |
| fl_chart widgets | Unit 3 (introduced) | Unit 4 (reuses chart patterns) |
