# Domain Entities — Unit 1: Foundation

## Entity: Expense

| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| id | String (UUID) | Yes | Auto-generated | Primary key |
| amount | double | Yes | > 0, max 10,000,000 | In INR |
| categoryId | String | Yes | Must reference existing Category | FK to Category |
| description | String | No | Max 200 characters | User note |
| date | DateTime | Yes | Cannot be future date, max 2 years ago | Expense date |
| source | ExpenseSource (enum) | Yes | manual / sms | How expense was created |
| createdAt | DateTime | Yes | Auto-set to current time | Record creation |
| updatedAt | DateTime | Yes | Auto-set on modification | Last update time |

### ExpenseSource Enum
- `manual` — User manually entered
- `sms` — Auto-detected from SMS

---

## Entity: Category

| Field | Type | Required | Validation | Notes |
|-------|------|----------|------------|-------|
| id | String (UUID) | Yes | Auto-generated | Primary key |
| name | String | Yes | 1-30 chars, unique, trimmed | Display name |
| icon | String | Yes | Valid icon identifier | Material icon name |
| color | int | Yes | Valid color value (0xFFxxxxxx) | ARGB color integer |
| isDefault | bool | Yes | Cannot be changed after creation | True for seeded categories |
| createdAt | DateTime | Yes | Auto-set | Record creation |
| sortOrder | int | Yes | >= 0 | Display ordering |

---

## Entity: AppSettings

| Field | Type | Required | Default | Notes |
|-------|------|----------|---------|-------|
| id | int | Yes | 0 (singleton) | Always single record |
| userName | String | Yes | "" | Set during onboarding |
| themeMode | int | Yes | 0 (system) | 0=system, 1=light, 2=dark |
| timeoutMinutes | int | Yes | 1 | Inactivity lock timeout |
| biometricEnabled | bool | Yes | false | Biometric auth toggle |
| onboardingComplete | bool | Yes | false | Setup status flag |
| smsEnabled | bool | Yes | false | SMS monitoring active |
| lastBackupDate | DateTime? | No | null | Last successful backup |

---

## Default Category Seed Data

| Name | Icon | Color | Sort Order |
|------|------|-------|-----------|
| Food & Dining | restaurant | 0xFFE53935 (Red) | 0 |
| Groceries | shopping_cart | 0xFF43A047 (Green) | 1 |
| Transport | directions_car | 0xFF1E88E5 (Blue) | 2 |
| Fuel | local_gas_station | 0xFFFB8C00 (Orange) | 3 |
| Rent | home | 0xFF8E24AA (Purple) | 4 |
| Utilities | bolt | 0xFFFFB300 (Amber) | 5 |
| Shopping | shopping_bag | 0xFFD81B60 (Pink) | 6 |
| Entertainment | movie | 0xFF5E35B1 (Deep Purple) | 7 |
| Health | local_hospital | 0xFF00897B (Teal) | 8 |
| Education | school | 0xFF3949AB (Indigo) | 9 |
| Travel | flight | 0xFF00ACC1 (Cyan) | 10 |
| Subscriptions | subscriptions | 0xFF6D4C41 (Brown) | 11 |
| Other | more_horiz | 0xFF757575 (Gray) | 12 |

---

## Database Schema Relationships

```
+-------------------+       +-------------------+
|     Expense       |       |     Category      |
+-------------------+       +-------------------+
| id (PK)           |       | id (PK)           |
| amount            |       | name              |
| categoryId (FK) ──┼──────>| icon              |
| description       |       | color             |
| date              |       | isDefault         |
| source            |       | createdAt         |
| createdAt         |       | sortOrder         |
| updatedAt         |       +-------------------+
+-------------------+

+-------------------+
|   AppSettings     |
+-------------------+
| id (singleton)    |
| userName          |
| themeMode         |
| timeoutMinutes    |
| biometricEnabled  |
| onboardingComplete|
| smsEnabled        |
| lastBackupDate    |
+-------------------+
```

**Relationships:**
- Expense → Category: Many-to-one (each expense has exactly one category)
- Category → Expense: One-to-many (each category can have many expenses)
- AppSettings: Singleton (always one record)
