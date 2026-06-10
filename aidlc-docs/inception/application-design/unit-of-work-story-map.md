# Unit of Work — Story Map

## Story-to-Unit Assignment

### Unit 1: Foundation
| Story | Description |
|-------|-------------|
| — | No user stories directly (infrastructure unit) |

**Note**: Unit 1 enables all stories but has no direct user-facing stories. It creates the project, models, database, navigation shell, and DI setup.

---

### Unit 2: Expenses & Categories
| Story | Description |
|-------|-------------|
| US-2.2 | Manual Expense Entry |
| US-2.3 | Assign Category to Expense |
| US-2.4 | Edit Existing Expense |
| US-2.5 | Delete Expense |
| US-3.1 | View Default Categories |
| US-3.2 | Create Custom Category |
| US-3.3 | Edit Custom Category |
| US-3.4 | Delete Custom Category |
| US-4.4 | Filter Expense List |

**Total**: 9 stories

---

### Unit 3: Dashboard & Visualization
| Story | Description |
|-------|-------------|
| US-4.1 | View Monthly Dashboard |
| US-4.2 | View Spending Trends |
| US-4.3 | View Top Categories |
| US-4.5 | View Past Months |

**Total**: 4 stories

---

### Unit 4: Reports
| Story | Description |
|-------|-------------|
| US-5.1 | View Weekly Report |
| US-5.2 | View Monthly Report |
| US-5.3 | Compare Periods |

**Total**: 3 stories

---

### Unit 5: Export
| Story | Description |
|-------|-------------|
| US-6.1 | Export to Excel |
| US-6.2 | Export Report as PDF |

**Total**: 2 stories

---

### Unit 6: SMS Auto-Detection
| Story | Description |
|-------|-------------|
| US-2.1 | Auto-Detect Expense from SMS |

**Total**: 1 story (complex implementation)

---

### Unit 7: Authentication & Settings
| Story | Description |
|-------|-------------|
| US-1.1 | Quick Setup (Onboarding) |
| US-1.2 | SMS Permission Request |
| US-1.3 | PIN Setup |
| US-7.1 | Unlock with PIN |
| US-7.2 | Unlock with Biometric |
| US-7.3 | Change PIN |
| US-8.1 | Backup Data |
| US-8.2 | Restore Data |
| US-8.3 | Toggle Theme |
| US-8.4 | Manage Inactivity Timeout |

**Total**: 10 stories

---

## Coverage Validation

| Total Stories | Assigned | Unassigned |
|--------------|----------|------------|
| 26 | 26 (+ 3 in Foundation indirectly) | 0 |

**All 26 user stories are assigned to units. ✅**

---

## Story Count by Unit

| Unit | Stories | Complexity |
|------|---------|-----------|
| Unit 1: Foundation | 0 (infra) | Medium |
| Unit 2: Expenses & Categories | 9 | High |
| Unit 3: Dashboard | 4 | Medium |
| Unit 4: Reports | 3 | Medium |
| Unit 5: Export | 2 | Medium |
| Unit 6: SMS | 1 | High |
| Unit 7: Auth & Settings | 10 | Medium |
| **Total** | **29 assignments** | — |

**Note**: US-1.2 (SMS Permission Request) is in Unit 7 but functionally enables Unit 6.
