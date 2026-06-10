# Application Components — Expense Calculator App

## Architecture Overview

**Pattern**: Feature-first with BLoC per feature  
**State Management**: BLoC/Cubit  
**Navigation**: Bottom Navigation Bar (Dashboard, Expenses, Reports, Settings)

```
lib/
├── core/                    # Shared utilities, themes, constants
├── features/                # Feature modules (each self-contained)
│   ├── auth/               # Authentication (PIN/Biometric)
│   ├── dashboard/          # Home dashboard with charts
│   ├── expenses/           # Expense list, add, edit, delete
│   ├── categories/         # Category management
│   ├── reports/            # Weekly/monthly reports
│   ├── export/             # Excel and PDF export
│   ├── sms/               # SMS parsing and detection
│   ├── settings/          # App settings, backup/restore
│   └── onboarding/        # First-time setup
├── data/                   # Data layer (shared across features)
│   ├── models/            # Data models (Hive/Isar entities)
│   ├── repositories/     # Repository implementations
│   └── datasources/      # Local data sources (Hive/Isar)
├── services/              # Application services
└── main.dart
```

---

## Component Definitions

### 1. Core Component
**Purpose**: Shared utilities, constants, and theme configuration  
**Responsibilities**:
- App theme definitions (light/dark, Material Design 3)
- Shared constants (colors, dimensions, strings)
- Utility functions (date formatting, currency formatting)
- Route definitions and navigation setup
- Dependency injection configuration

---

### 2. Auth Feature
**Purpose**: App access control via PIN and biometric authentication  
**Responsibilities**:
- PIN entry and validation screen
- Biometric prompt handling
- PIN setup and change flow
- Inactivity timeout management
- Secure storage of credentials

---

### 3. Dashboard Feature
**Purpose**: Home screen showing financial overview at a glance  
**Responsibilities**:
- Monthly expense total with comparison to previous month
- Category breakdown pie chart
- Daily spending trend chart (bar/line)
- Top spending categories display
- Recent transactions list (limited)
- Month picker for viewing past months

---

### 4. Expenses Feature
**Purpose**: Full expense list management (view, add, edit, delete)  
**Responsibilities**:
- Chronological expense list with infinite scroll
- Add new expense screen (manual entry)
- Edit existing expense screen
- Delete expense with confirmation
- Filter by date range, category, amount
- Search by description text

---

### 5. Categories Feature
**Purpose**: Manage expense categories (default and custom)  
**Responsibilities**:
- Display all categories (default + custom)
- Create custom category (name, icon, color)
- Edit custom category
- Delete custom category with expense reassignment
- Category picker widget (reused by Expenses feature)

---

### 6. Reports Feature
**Purpose**: Generate and display weekly/monthly expense reports  
**Responsibilities**:
- Weekly report view with totals and charts
- Monthly report view with detailed breakdown
- Period comparison (vs previous week/month)
- Report date range selection

---

### 7. Export Feature
**Purpose**: Export expense data to Excel and PDF formats  
**Responsibilities**:
- Excel (.xlsx) generation with date/category filters
- PDF report generation with charts and formatting
- Share via device share sheet
- Export progress indication

---

### 8. SMS Feature
**Purpose**: Parse SMS messages to auto-detect expenses  
**Responsibilities**:
- Background SMS listener for real-time detection
- On-demand scan of past SMS messages
- Generic pattern matching for bank transaction alerts
- Present detected expense for user confirmation
- SMS permission management

---

### 9. Settings Feature
**Purpose**: App configuration and data management  
**Responsibilities**:
- Theme selection (light/dark/system)
- Inactivity timeout configuration
- PIN change
- Biometric toggle
- Data backup (export to file)
- Data restore (import from file)
- About/version info

---

### 10. Onboarding Feature
**Purpose**: First-time user setup flow  
**Responsibilities**:
- Welcome screen
- Name entry
- PIN setup
- SMS permission request with explanation
- Completion and redirect to dashboard

---

### 11. Data Layer (Shared)
**Purpose**: Data persistence and access across all features  
**Responsibilities**:
- Hive/Isar database initialization and management
- Data model definitions (Expense, Category, Settings entities)
- Repository pattern for data access abstraction
- Data migration handling
- Encrypted storage for sensitive data

---

### 12. Services Layer (Shared)
**Purpose**: Cross-cutting application services  
**Responsibilities**:
- SMS parsing service (pattern matching engine)
- Export service (Excel/PDF generation)
- Notification service (expense detected alerts)
- Secure storage service (PIN, biometric keys)
- Backup/restore service
