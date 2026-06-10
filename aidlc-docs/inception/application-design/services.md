# Services — Expense Calculator App

## Service Layer Overview

Services provide cross-cutting functionality that multiple features depend on. They are injected into BLoCs via dependency injection.

---

## 1. SmsParsingService

**Purpose**: Parse SMS messages to extract expense information  
**Used by**: SMS Feature (SmsBloc)

| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `parseMessage(String smsBody)` | Raw SMS text | DetectedExpense? | Attempt to parse expense from SMS |
| `isTransactionSms(String smsBody)` | Raw SMS text | bool | Quick check if SMS is a transaction |
| `extractAmount(String text)` | Text fragment | double? | Extract monetary amount from text |
| `extractMerchant(String text)` | Text fragment | String? | Extract merchant/description |

**Patterns Handled**:
- Debit alerts: "debited", "spent", "paid", "withdrawn"
- Amount formats: "Rs.", "INR", "₹" followed by numbers
- Generic bank SMS structures

---

## 2. ExportService

**Purpose**: Generate Excel and PDF files from expense data  
**Used by**: Export Feature (ExportBloc)

| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `generateExcel(List<Expense> expenses, ExportFilter filter)` | Expenses + filter | String (file path) | Create .xlsx file |
| `generatePdf(MonthlyReport report)` | Report data | String (file path) | Create PDF with charts |
| `getExportDirectory()` | — | String (dir path) | Get app's export directory |

**Libraries**:
- Excel: `excel` package
- PDF: `pdf` package with `printing` for sharing

---

## 3. SecureStorageService

**Purpose**: Securely store sensitive data (PIN hash, biometric keys)  
**Used by**: Auth Feature (AuthBloc), Settings Feature

| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `storePin(String pinHash)` | Hashed PIN | void | Save PIN to secure storage |
| `getPin()` | — | String? (hash) | Retrieve stored PIN hash |
| `isBiometricAvailable()` | — | bool | Check device biometric support |
| `authenticateWithBiometric()` | — | bool | Perform biometric auth |
| `clearAll()` | — | void | Clear all secure data |

**Libraries**: `flutter_secure_storage`, `local_auth`

---

## 4. NotificationService

**Purpose**: Show local notifications for detected expenses  
**Used by**: SMS Feature (background processing)

| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `showExpenseDetected(DetectedExpense expense)` | Detected expense | void | Show notification with expense details |
| `initialize()` | — | void | Set up notification channels |

**Libraries**: `flutter_local_notifications`

---

## 5. BackupService

**Purpose**: Handle data backup and restore operations  
**Used by**: Settings Feature (SettingsBloc)

| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `createBackup()` | — | String (file path) | Export all DB data to JSON file |
| `restoreBackup(String filePath)` | Backup file path | void | Import data from backup file |
| `validateBackup(String filePath)` | Backup file path | bool | Verify backup file integrity |
| `getBackupInfo(String filePath)` | Backup file path | BackupInfo | Get metadata (date, size, count) |

---

## 6. DatabaseService

**Purpose**: Initialize and manage Hive/Isar database lifecycle  
**Used by**: All repositories

| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `initialize()` | — | void | Open DB, register adapters |
| `close()` | — | void | Close DB connections |
| `clearAll()` | — | void | Delete all data |
| `getSize()` | — | int (bytes) | Get database storage size |

---

## Service Dependency Map

```
Features (BLoCs)
    │
    ├── SmsBloc ──────────► SmsParsingService
    │                       NotificationService
    │
    ├── ExportBloc ───────► ExportService
    │
    ├── AuthBloc ─────────► SecureStorageService
    │
    ├── SettingsBloc ─────► BackupService
    │                       SecureStorageService
    │
    └── All BLoCs ────────► Repositories ──► DatabaseService
```
