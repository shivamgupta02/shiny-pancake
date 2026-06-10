# Expense Calculator

A Flutter-based mobile expense tracker for Android with SMS auto-detection, local storage, and rich reporting.

## Features

### Expense Management
- Manual expense entry with amount, category, description, and date
- Edit and delete existing expenses
- Filter by date range, category, and amount
- Full-text search by description

### SMS Auto-Detection
- Reads bank transaction SMS messages (Indian banks — debit alerts)
- Generic pattern matching for multiple bank formats (SBI, HDFC, ICICI, Axis, etc.)
- On-demand scanning of past 7 or 30 days
- Confidence scoring for detected expenses (High / Review)
- User confirmation flow before saving detected expenses

### SMS Learning System
- Correct wrongly-parsed SMS and teach the app the right format
- App learns sender-specific parsing rules using regex patterns built from corrections
- Learned rules applied automatically on future messages from the same sender
- View, manage, and delete learned rules
- Success tracking per rule

### Dashboard
- Monthly total with previous month comparison (percentage change)
- Category breakdown pie chart (top 5 + Others)
- Daily spending trend bar chart with average line
- Top spending categories with progress bars

### Reports
- Weekly reports: total, day-by-day bar chart (Mon–Sun), category breakdown, previous week comparison
- Monthly reports: total, daily trend chart, top 5 categories, full category breakdown, average daily
- Period comparison with color-coded indicators (green for decrease, red for increase)
- Export expenses to Excel (.xlsx) with date range and category filters
- Export monthly report as PDF with summary, category table, and footer

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter |
| State Management | BLoC / Cubit (flutter_bloc) |
| Local Database | Hive (NoSQL, no code gen) |
| Charts | fl_chart |
| Dependency Injection | get_it |
| Authentication | flutter_secure_storage, local_auth, crypto |
| Export | excel, pdf, printing, share_plus |
| SMS (Android) | Platform Channels (Kotlin MethodChannel + BroadcastReceiver) |
| Architecture | Feature-first with BLoC per feature |


## Getting Started

### Prerequisites
- Flutter SDK 3.2+
- Android SDK (API 21+)
- Android Studio (for emulator)

### Setup
```bash
git clone <repo-url>
cd shiny-pancake
flutter pub get
flutter run
```

### Testing SMS on Emulator
```bash
adb emu sms send 1234567890 "Rs.500 debited from A/c XX1234 on 10-Jun-26. UPI/Swiggy. Avl bal: Rs.15000"
```

Then scan from Settings → SMS Expense Detection → Scan Last 7 Days.

## Platform Support

| Platform | Status |
|----------|--------|
| Android | ✅ Supported (primary) |
| iOS | 🔜 Ready for future (Flutter cross-platform, SMS features Android-only) |

## Data Storage
- All data stored locally on device (no internet required)
- Hive NoSQL database
- Up to 2 years of expense data
- Encrypted PIN storage via flutter_secure_storage
