# Application Design — Consolidated Document

## Expense Calculator App

---

## Architecture Summary

| Decision | Choice |
|----------|--------|
| **Framework** | Flutter |
| **Platform (v1)** | Android |
| **Architecture** | Feature-first with BLoC per feature |
| **State Management** | BLoC/Cubit (flutter_bloc) |
| **Local Database** | Isar (primary) with Hive for key-value settings |
| **Charts** | fl_chart |
| **DI** | get_it |
| **Navigation** | Bottom navigation (Dashboard, Expenses, Reports, Settings) |
| **SMS Approach** | Real-time background listener + on-demand scan |

---

## Project Structure

```
lib/
├── core/
│   ├── theme/              # Light/dark theme definitions
│   ├── constants/          # App constants, strings
│   ├── utils/              # Formatting, helpers
│   ├── di/                 # Dependency injection setup
│   └── router/             # Navigation and routes
│
├── features/
│   ├── auth/
│   │   ├── bloc/           # AuthBloc, states, events
│   │   ├── screens/        # PIN screen, biometric screen
│   │   └── widgets/        # PIN keypad, biometric button
│   │
│   ├── onboarding/
│   │   ├── bloc/
│   │   ├── screens/        # Welcome, name, PIN setup, SMS permission
│   │   └── widgets/
│   │
│   ├── dashboard/
│   │   ├── bloc/
│   │   ├── screens/        # Dashboard home screen
│   │   └── widgets/        # Chart widgets, stat cards, recent list
│   │
│   ├── expenses/
│   │   ├── bloc/
│   │   ├── screens/        # Expense list, add/edit expense
│   │   └── widgets/        # Expense tile, filter bar, search
│   │
│   ├── categories/
│   │   ├── bloc/
│   │   ├── screens/        # Category list, create/edit
│   │   └── widgets/        # Category picker, icon selector
│   │
│   ├── reports/
│   │   ├── bloc/
│   │   ├── screens/        # Weekly report, monthly report
│   │   └── widgets/        # Report charts, comparison cards
│   │
│   ├── export/
│   │   ├── bloc/
│   │   ├── screens/        # Export options screen
│   │   └── widgets/        # Export progress, filter selection
│   │
│   ├── sms/
│   │   ├── bloc/
│   │   ├── screens/        # SMS confirmation screen
│   │   └── widgets/        # Detected expense card
│   │
│   └── settings/
│       ├── bloc/
│       ├── screens/        # Settings list, backup/restore
│       └── widgets/        # Setting tiles, theme picker
│
├── data/
│   ├── models/
│   │   ├── expense.dart
│   │   ├── category.dart
│   │   └── settings.dart
│   ├── repositories/
│   │   ├── expense_repository.dart
│   │   ├── category_repository.dart
│   │   └── settings_repository.dart
│   └── datasources/
│       └── local_database.dart
│
├── services/
│   ├── sms_parsing_service.dart
│   ├── export_service.dart
│   ├── secure_storage_service.dart
│   ├── notification_service.dart
│   ├── backup_service.dart
│   └── database_service.dart
│
└── main.dart
```

---

## Components (10 Features + 2 Shared Layers)

| # | Component | Type | Responsibility |
|---|-----------|------|----------------|
| 1 | Core | Shared | Theme, constants, utils, DI, routing |
| 2 | Auth | Feature | PIN/biometric access control |
| 3 | Onboarding | Feature | First-time setup flow |
| 4 | Dashboard | Feature | Home screen with charts and metrics |
| 5 | Expenses | Feature | Expense CRUD and list management |
| 6 | Categories | Feature | Category CRUD (default + custom) |
| 7 | Reports | Feature | Weekly/monthly report generation |
| 8 | Export | Feature | Excel and PDF export |
| 9 | SMS | Feature | SMS parsing and auto-detection |
| 10 | Settings | Feature | App configuration and backup |
| 11 | Data Layer | Shared | Models, repositories, datasources |
| 12 | Services | Shared | Cross-cutting services (SMS, export, auth, backup) |

---

## Key Data Models

### Expense
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | String | Yes | Unique identifier |
| amount | double | Yes | In INR |
| categoryId | String | Yes | Reference to Category |
| description | String | No | User note |
| date | DateTime | Yes | Expense date |
| source | ExpenseSource | Yes | Manual / SMS |
| createdAt | DateTime | Yes | Record creation time |

### Category
| Field | Type | Required | Notes |
|-------|------|----------|-------|
| id | String | Yes | Unique identifier |
| name | String | Yes | Display name |
| icon | String | Yes | Icon identifier |
| color | int | Yes | Color value |
| isDefault | bool | Yes | True for built-in categories |

### AppSettings
| Field | Type | Default | Notes |
|-------|------|---------|-------|
| userName | String | — | Set during onboarding |
| themeMode | ThemeMode | system | Light/dark/system |
| timeoutMinutes | int | 1 | Inactivity lock timeout |
| biometricEnabled | bool | false | Biometric auth toggle |
| onboardingComplete | bool | false | Setup status |
| smsEnabled | bool | false | SMS monitoring active |

---

## Service Summary

| Service | Purpose | Key Dependencies |
|---------|---------|------------------|
| SmsParsingService | Parse bank SMS → detected expenses | telephony |
| ExportService | Generate Excel/PDF files | excel, pdf, printing |
| SecureStorageService | Store PIN hash, manage biometric | flutter_secure_storage, local_auth |
| NotificationService | Local notifications for detected expenses | flutter_local_notifications |
| BackupService | Data backup/restore | path_provider |
| DatabaseService | DB lifecycle management | isar / hive_flutter |

---

## Package Dependencies

```yaml
dependencies:
  flutter_bloc: ^8.x
  equatable: ^2.x
  get_it: ^7.x
  isar: ^3.x
  isar_flutter_libs: ^3.x
  fl_chart: ^0.x
  flutter_secure_storage: ^9.x
  local_auth: ^2.x
  excel: ^4.x
  pdf: ^3.x
  printing: ^5.x
  telephony: ^0.x
  flutter_local_notifications: ^17.x
  share_plus: ^7.x
  path_provider: ^2.x
  intl: ^0.x

dev_dependencies:
  isar_generator: ^3.x
  build_runner: ^2.x
  bloc_test: ^9.x
  mocktail: ^1.x
```

---

## Navigation Structure

```
BottomNavigationBar
├── Tab 0: Dashboard (DashboardScreen)
├── Tab 1: Expenses (ExpenseListScreen)
├── Tab 2: Reports (ReportsScreen)
└── Tab 3: Settings (SettingsScreen)

Push Navigation (from any tab):
├── AddExpenseScreen
├── EditExpenseScreen
├── CategoryManagementScreen
├── CreateCategoryScreen
├── WeeklyReportDetailScreen
├── MonthlyReportDetailScreen
├── ExportScreen
├── SmsConfirmationScreen
├── PinSetupScreen
└── BackupRestoreScreen
```
