# Component Methods — Expense Calculator App

## Auth Feature

### AuthBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `verifyPin(String pin)` | PIN string | AuthState (success/failure) | Validate entered PIN against stored PIN |
| `authenticateBiometric()` | — | AuthState (success/failure) | Trigger biometric prompt and validate |
| `setupPin(String pin, String confirmPin)` | Two PIN strings | AuthState (success/error) | Set initial PIN during onboarding |
| `changePin(String currentPin, String newPin)` | Current + new PIN | AuthState (success/error) | Change PIN from settings |
| `checkLockStatus()` | — | AuthState (locked/unlocked) | Check if app should be locked based on timeout |

---

## Dashboard Feature

### DashboardBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `loadDashboard(DateTime month)` | Target month | DashboardState (data loaded) | Load all dashboard metrics for given month |
| `loadCategoryBreakdown(DateTime month)` | Target month | List of CategoryTotal | Get spending per category for pie chart |
| `loadDailyTrend(DateTime month)` | Target month | List of DailyTotal | Get daily spending for trend chart |
| `loadRecentTransactions(int limit)` | Count limit | List of Expense | Get latest N transactions |
| `changeMonth(DateTime month)` | New month | DashboardState (refreshed) | Switch dashboard to different month |

---

## Expenses Feature

### ExpenseBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `loadExpenses(ExpenseFilter filter)` | Filter criteria | List of Expense | Fetch filtered expense list |
| `addExpense(ExpenseInput input)` | Expense data | Expense (saved) | Create new expense record |
| `updateExpense(String id, ExpenseInput input)` | ID + updated data | Expense (updated) | Modify existing expense |
| `deleteExpense(String id)` | Expense ID | void | Remove expense permanently |
| `searchExpenses(String query)` | Search text | List of Expense | Full-text search by description |

### ExpenseFilter (Value Object)
| Field | Type | Purpose |
|-------|------|---------|
| `dateFrom` | DateTime? | Start of date range |
| `dateTo` | DateTime? | End of date range |
| `categories` | List<String>? | Filter by category IDs |
| `amountMin` | double? | Minimum amount |
| `amountMax` | double? | Maximum amount |

---

## Categories Feature

### CategoryBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `loadCategories()` | — | List of Category | Fetch all categories (default + custom) |
| `createCategory(CategoryInput input)` | Name, icon, color | Category (saved) | Create new custom category |
| `updateCategory(String id, CategoryInput input)` | ID + updated data | Category (updated) | Modify custom category |
| `deleteCategory(String id, String reassignToId)` | Category ID + target | void | Delete category, reassign expenses |

---

## Reports Feature

### ReportBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `generateWeeklyReport(DateTime weekStart)` | Week start date | WeeklyReport | Generate weekly summary with comparisons |
| `generateMonthlyReport(DateTime month)` | Target month | MonthlyReport | Generate monthly summary with charts data |
| `compareWithPrevious(ReportType type, DateTime period)` | Report type + period | ComparisonData | Compare current vs previous period |

---

## Export Feature

### ExportBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `exportToExcel(ExportFilter filter)` | Date range, categories | File path | Generate .xlsx file |
| `exportToPdf(DateTime month)` | Target month | File path | Generate PDF report |
| `shareFile(String filePath)` | File path | void | Open device share sheet |

---

## SMS Feature

### SmsBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `startListening()` | — | void | Begin background SMS monitoring |
| `stopListening()` | — | void | Stop background SMS monitoring |
| `scanPastMessages(int days)` | Days to scan | List of DetectedExpense | Scan past N days of SMS |
| `confirmExpense(DetectedExpense expense)` | Detected expense | Expense (saved) | Save confirmed detected expense |
| `dismissExpense(DetectedExpense expense)` | Detected expense | void | Dismiss false positive |

---

## Settings Feature

### SettingsBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `loadSettings()` | — | AppSettings | Load all app settings |
| `updateTheme(ThemeMode mode)` | Theme mode | void | Change app theme |
| `updateTimeout(Duration timeout)` | Timeout duration | void | Change inactivity timeout |
| `toggleBiometric(bool enabled)` | Enable/disable | void | Toggle biometric auth |
| `backupData()` | — | File path | Export all data to backup file |
| `restoreData(String filePath)` | Backup file path | void | Restore data from backup |

---

## Onboarding Feature

### OnboardingBloc
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `setupUser(String name)` | User name | void | Store user name |
| `requestSmsPermission()` | — | bool (granted/denied) | Request SMS read permission |
| `completeOnboarding()` | — | void | Mark onboarding as done, navigate to dashboard |

---

## Data Layer — Repositories

### ExpenseRepository
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `getAll(ExpenseFilter? filter)` | Optional filter | List of Expense | Fetch expenses with optional filtering |
| `getById(String id)` | Expense ID | Expense | Fetch single expense |
| `create(Expense expense)` | Expense entity | Expense | Insert new expense |
| `update(Expense expense)` | Expense entity | Expense | Update existing expense |
| `delete(String id)` | Expense ID | void | Remove expense |
| `getTotalByMonth(DateTime month)` | Month | double | Sum expenses for month |
| `getByCategory(String categoryId, DateTime month)` | Category + month | List of Expense | Expenses in category for month |

### CategoryRepository
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `getAll()` | — | List of Category | Fetch all categories |
| `getDefaults()` | — | List of Category | Fetch default categories only |
| `create(Category category)` | Category entity | Category | Insert custom category |
| `update(Category category)` | Category entity | Category | Update custom category |
| `delete(String id)` | Category ID | void | Remove custom category |
| `reassignExpenses(String fromId, String toId)` | Source + target IDs | void | Move expenses between categories |

### SettingsRepository
| Method | Input | Output | Purpose |
|--------|-------|--------|---------|
| `getSettings()` | — | AppSettings | Fetch app settings |
| `updateSettings(AppSettings settings)` | Settings entity | void | Save updated settings |
| `isOnboardingComplete()` | — | bool | Check if setup is done |
| `setOnboardingComplete()` | — | void | Mark setup as done |

---

## Note
Detailed business rules (e.g., SMS parsing regex patterns, report calculation logic, export formatting rules) will be defined in the **Functional Design** stage during CONSTRUCTION phase.
