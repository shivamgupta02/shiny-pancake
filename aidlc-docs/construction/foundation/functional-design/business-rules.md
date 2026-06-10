# Business Rules — Unit 1: Foundation

## BR-1: Expense Validation Rules

| Rule ID | Rule | Error Message |
|---------|------|---------------|
| BR-1.1 | Amount must be > 0 | "Amount must be greater than zero" |
| BR-1.2 | Amount must be <= 10,000,000 | "Amount cannot exceed ₹1 crore" |
| BR-1.3 | Category ID must reference existing category | "Please select a valid category" |
| BR-1.4 | Date cannot be in the future | "Expense date cannot be in the future" |
| BR-1.5 | Date cannot be more than 2 years in the past | "Expense date cannot be more than 2 years ago" |
| BR-1.6 | Description max 200 characters | "Description cannot exceed 200 characters" |
| BR-1.7 | Amount and Category are required fields | "Please fill all required fields" |

---

## BR-2: Category Validation Rules

| Rule ID | Rule | Error Message |
|---------|------|---------------|
| BR-2.1 | Name must be 1-30 characters (trimmed) | "Category name must be 1-30 characters" |
| BR-2.2 | Name must be unique (case-insensitive) | "A category with this name already exists" |
| BR-2.3 | Default categories cannot be edited or deleted | "Default categories cannot be modified" |
| BR-2.4 | Icon must be a valid Material icon identifier | "Please select an icon" |
| BR-2.5 | Color must be a valid ARGB color value | "Please select a color" |
| BR-2.6 | Deleting custom category requires reassigning its expenses | "Please choose a category for existing expenses" |

---

## BR-3: Data Retention Rules

| Rule ID | Rule | Description |
|---------|------|-------------|
| BR-3.1 | Store up to 2 years of expense data | Expenses older than 2 years may be purged |
| BR-3.2 | Permanent deletion — no soft delete | Deleted expenses are removed immediately and permanently |
| BR-3.3 | Database size should not exceed 100MB | Warn user if approaching limit |

---

## BR-4: Default Data Rules

| Rule ID | Rule | Description |
|---------|------|-------------|
| BR-4.1 | Seed 13 default categories on first launch | If no categories exist, create defaults |
| BR-4.2 | Create singleton AppSettings on first launch | Default values as specified in entity definition |
| BR-4.3 | Default categories always have isDefault = true | Cannot be changed |
| BR-4.4 | Custom categories always have isDefault = false | Set on creation |

---

## BR-5: Database Integrity Rules

| Rule ID | Rule | Description |
|---------|------|-------------|
| BR-5.1 | Expense.categoryId must reference valid Category | Enforce referential integrity |
| BR-5.2 | Category deletion cascades to expense reassignment | No orphaned expenses allowed |
| BR-5.3 | AppSettings always has exactly one record | Singleton pattern |
| BR-5.4 | IDs are UUIDs — globally unique | No collision risk |
