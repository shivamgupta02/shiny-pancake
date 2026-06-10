# Units of Work — Expense Calculator App

## Decomposition Strategy
**Approach**: By layer — Foundation first, then features incrementally  
**Priority**: Core first (Data → Expenses → Categories → Dashboard → Reports → Export → SMS → Auth)  
**Type**: Single monolithic Flutter app with logical development units

---

## Unit 1: Foundation

**Purpose**: Core infrastructure, data models, database setup, DI, theming, navigation shell  
**Priority**: 1 (must be built first — all other units depend on this)

### Scope
- Project scaffolding (Flutter project creation, folder structure)
- Core module: theme (light/dark, Material Design 3), constants, utils, DI setup (get_it)
- Data models: Expense, Category, AppSettings (Isar entities)
- Database service: Isar initialization, schema registration
- Repositories: ExpenseRepository, CategoryRepository, SettingsRepository
- Navigation shell: Bottom navigation bar with 4 tabs (placeholder screens)
- App entry point (main.dart) with BLoC providers

### Deliverables
- Complete project structure matching application-design.md
- Working app shell with navigation (empty screens)
- Database initialized with schema
- All repositories functional
- Default categories seeded on first launch

---

## Unit 2: Expenses & Categories

**Purpose**: Core expense management (CRUD) and category management  
**Priority**: 2 (primary user interaction — add, view, edit, delete expenses)

### Scope
- **Expenses Feature**:
  - ExpenseBloc with all CRUD operations
  - Add Expense screen (amount, category, description, date)
  - Expense list screen with infinite scroll
  - Edit Expense screen
  - Delete with confirmation dialog
  - Filter bar (date range, category, amount)
  - Search by description
- **Categories Feature**:
  - CategoryBloc with CRUD operations
  - Category list screen (default + custom)
  - Create custom category screen (name, icon, color picker)
  - Edit/delete custom category with reassignment
  - Category picker widget (reusable)

### Deliverables
- Full expense CRUD functional
- Full category management functional
- Filter and search working
- Category picker integrated with expense forms

---

## Unit 3: Dashboard & Visualization

**Purpose**: Home dashboard with charts, metrics, and spending insights  
**Priority**: 3 (gives value to the data entered in Unit 2)

### Scope
- **Dashboard Feature**:
  - DashboardBloc loading all metrics
  - Monthly total with previous month comparison
  - Category breakdown pie chart (fl_chart)
  - Daily spending trend bar chart (fl_chart)
  - Top spending categories display
  - Recent transactions list (last 5-10)
  - Month picker for historical view

### Deliverables
- Dashboard as home screen (Tab 0)
- Pie chart and bar chart rendering correctly
- Month navigation working
- Auto-refresh when expenses change

---

## Unit 4: Reports

**Purpose**: Weekly and monthly report generation with period comparison  
**Priority**: 4 (builds on dashboard data, adds detailed reporting)

### Scope
- **Reports Feature**:
  - ReportBloc for weekly and monthly reports
  - Weekly report screen (totals, category breakdown, day-by-day chart, comparison)
  - Monthly report screen (totals, pie chart, trend, top 5, average daily, comparison)
  - Period comparison logic (percentage changes, direction indicators)
  - Report date/week selection

### Deliverables
- Weekly report screen functional
- Monthly report screen functional
- Comparison with previous period working
- Charts rendering in reports

---

## Unit 5: Export

**Purpose**: Export expense data to Excel and PDF formats  
**Priority**: 5 (data output — depends on expenses and reports being complete)

### Scope
- **Export Feature**:
  - ExportBloc managing export operations
  - ExportService for Excel generation (.xlsx)
  - ExportService for PDF generation (with charts)
  - Export options screen (date range, category filter)
  - Progress indicator during generation
  - Share via device share sheet (share_plus)

### Deliverables
- Excel export with filtered data
- PDF export with formatted report
- Share functionality working
- Files saved to accessible location

---

## Unit 6: SMS Auto-Detection

**Purpose**: Background SMS reading and expense auto-detection  
**Priority**: 6 (Android-specific feature, adds automation to manual flow)

### Scope
- **SMS Feature**:
  - SmsBloc managing listener and scanning
  - SmsParsingService with generic pattern matching
  - Background SMS listener (real-time detection)
  - On-demand scan of past messages
  - SMS confirmation screen (confirm/edit/dismiss)
  - NotificationService for detected expense alerts
  - SMS permission request flow

### Deliverables
- Real-time SMS detection working
- Manual scan of past messages working
- Generic patterns matching common bank formats
- Confirmation flow integrated with ExpenseRepository
- Notification shown when expense detected

---

## Unit 7: Authentication & Settings

**Purpose**: App security (PIN/biometric) and settings management  
**Priority**: 7 (wraps the app with security, adds onboarding and preferences)

### Scope
- **Auth Feature**:
  - AuthBloc for PIN/biometric verification
  - SecureStorageService for PIN storage
  - PIN entry screen with keypad
  - Biometric prompt integration (local_auth)
  - Inactivity timeout logic
  - PIN setup and change flow
- **Onboarding Feature**:
  - OnboardingBloc for setup flow
  - Welcome → Name → PIN setup → SMS permission → Complete
- **Settings Feature**:
  - SettingsBloc for all preferences
  - Theme selection (light/dark/system)
  - Timeout configuration
  - Biometric toggle
  - BackupService for data backup/restore
  - Backup and restore screens

### Deliverables
- PIN lock on app launch
- Biometric authentication working
- Inactivity timeout locking app
- Onboarding flow complete for new users
- All settings functional
- Backup/restore working

---

## Code Organization Strategy

```
expense_calculator/           # Flutter project root
├── lib/
│   ├── core/                # Unit 1: Foundation
│   ├── data/                # Unit 1: Foundation (models, repos, datasources)
│   ├── services/            # Units 5-7: Services added incrementally
│   ├── features/
│   │   ├── expenses/        # Unit 2
│   │   ├── categories/      # Unit 2
│   │   ├── dashboard/       # Unit 3
│   │   ├── reports/         # Unit 4
│   │   ├── export/          # Unit 5
│   │   ├── sms/             # Unit 6
│   │   ├── auth/            # Unit 7
│   │   ├── onboarding/      # Unit 7
│   │   └── settings/        # Unit 7
│   └── main.dart            # Unit 1
├── test/                    # Tests mirror lib/ structure
├── android/
├── pubspec.yaml
└── README.md
```
