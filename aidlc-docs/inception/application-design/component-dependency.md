# Component Dependencies — Expense Calculator App

## Dependency Matrix

| Component | Depends On | Depended By |
|-----------|-----------|-------------|
| **Core** | — | All components |
| **Auth Feature** | SecureStorageService, SettingsRepository | App shell (gate) |
| **Dashboard Feature** | ExpenseRepository, CategoryRepository | — |
| **Expenses Feature** | ExpenseRepository, CategoryRepository | Dashboard (refreshes) |
| **Categories Feature** | CategoryRepository, ExpenseRepository | Expenses, Dashboard |
| **Reports Feature** | ExpenseRepository, CategoryRepository | Export |
| **Export Feature** | ExportService, ExpenseRepository, ReportBloc | — |
| **SMS Feature** | SmsParsingService, NotificationService, ExpenseRepository | Dashboard (refreshes) |
| **Settings Feature** | SettingsRepository, BackupService, SecureStorageService | Auth |
| **Onboarding Feature** | SettingsRepository, SecureStorageService | — |
| **Data Layer** | DatabaseService | All features |
| **Services** | — | Features via DI |

---

## Communication Patterns

### Pattern 1: BLoC-to-Repository (Primary Data Access)
```
Feature BLoC → Repository → Hive/Isar DataSource
```
- All data access goes through repositories
- Repositories abstract the storage implementation
- BLoCs never access Hive/Isar directly

### Pattern 2: BLoC-to-Service (Cross-Cutting Operations)
```
Feature BLoC → Service → External API / Platform
```
- Services handle platform-specific operations (SMS, biometric, notifications)
- Services are injected into BLoCs via constructor injection

### Pattern 3: Feature-to-Feature (Event Communication)
```
Feature A BLoC → emits event → App-level listener → Feature B BLoC refresh
```
- When an expense is added/deleted, Dashboard refreshes
- When SMS detects expense and user confirms, Expenses list refreshes
- Communication via stream subscriptions or app-level event bus

### Pattern 4: Navigation (Screen Transitions)
```
Screen A → Navigator → Screen B
```
- Bottom nav handles top-level navigation (Dashboard, Expenses, Reports, Settings)
- Push navigation for detail screens (Add Expense, Edit, Category picker)
- Modal for quick actions (Delete confirmation, SMS confirmation)

---

## Data Flow Diagrams

### Flow 1: SMS Auto-Detection
```
SMS Received
    │
    ▼
SmsParsingService.parseMessage()
    │
    ▼
DetectedExpense created
    │
    ▼
NotificationService.showExpenseDetected()
    │
    ▼
User taps notification / opens app
    │
    ▼
Confirmation screen shown
    │
    ├── Confirm → ExpenseRepository.create() → Dashboard refreshes
    │
    └── Dismiss → Discard detected expense
```

### Flow 2: Manual Expense Entry
```
User taps "Add" button
    │
    ▼
Add Expense Screen shown
    │
    ▼
User fills: amount, category, description, date
    │
    ▼
ExpenseBloc.addExpense()
    │
    ▼
ExpenseRepository.create()
    │
    ▼
Dashboard auto-refreshes (stream)
```

### Flow 3: Report Export
```
User views Monthly Report
    │
    ▼
User taps "Export PDF"
    │
    ▼
ExportBloc.exportToPdf()
    │
    ▼
ExportService.generatePdf(reportData)
    │
    ▼
PDF file created in export directory
    │
    ▼
Share sheet opened with file
```

### Flow 4: App Launch
```
App starts
    │
    ▼
DatabaseService.initialize()
    │
    ▼
Check onboarding status
    │
    ├── Not complete → Onboarding flow
    │
    └── Complete → Auth screen (PIN/Biometric)
                        │
                        ▼
                   Dashboard loaded
                        │
                        ▼
                   SmsBloc.startListening()
```

---

## Dependency Injection Setup

Using `get_it` for service locator pattern:

```
// Registered in order of dependency:
1. DatabaseService (singleton)
2. Repositories (lazy singletons): ExpenseRepository, CategoryRepository, SettingsRepository
3. Services (lazy singletons): SmsParsingService, ExportService, SecureStorageService, NotificationService, BackupService
4. BLoCs (factory — new instance per screen): AuthBloc, DashboardBloc, ExpenseBloc, etc.
```

---

## Key Flutter Packages

| Package | Purpose | Component |
|---------|---------|-----------|
| `flutter_bloc` | State management | All features |
| `isar` / `hive_flutter` | Local database | Data layer |
| `fl_chart` | Charts and graphs | Dashboard, Reports |
| `get_it` | Dependency injection | Core |
| `flutter_secure_storage` | Secure PIN storage | Auth |
| `local_auth` | Biometric auth | Auth |
| `excel` | Excel file generation | Export |
| `pdf` + `printing` | PDF generation | Export |
| `telephony` | SMS reading | SMS feature |
| `flutter_local_notifications` | Local notifications | SMS feature |
| `share_plus` | Share files | Export |
| `path_provider` | File system paths | Export, Backup |
| `intl` | Date/currency formatting | Core |
| `equatable` | Value equality for BLoC states | All BLoCs |
