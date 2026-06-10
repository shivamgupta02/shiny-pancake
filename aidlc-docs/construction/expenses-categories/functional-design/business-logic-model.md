# Business Logic — Unit 2: Expenses & Categories

## Expense CRUD Logic

### Create Expense
1. Validate all fields per BR-1 rules
2. Generate UUID for id
3. Set createdAt and updatedAt to current time
4. Set source to `manual` (SMS source is set by Unit 6)
5. Save to database
6. Emit success state with saved expense

### Update Expense
1. Load existing expense by ID (fail if not found)
2. Validate updated fields per BR-1 rules
3. Update updatedAt to current time
4. Save changes to database
5. Emit success state with updated expense

### Delete Expense
1. Load existing expense by ID (fail if not found)
2. Permanently remove from database (no soft delete per BR-3.2)
3. Emit success state

---

## Category Management Logic

### Create Custom Category
1. Trim name, validate per BR-2 rules
2. Check uniqueness (case-insensitive comparison against all categories)
3. Set isDefault = false
4. Set sortOrder = max(existing sortOrder) + 1
5. Generate UUID for id
6. Save to database

### Edit Custom Category
1. Verify category is not default (BR-2.3)
2. Validate new name uniqueness (excluding current category)
3. Update name, icon, or color as changed
4. Existing expenses automatically reflect changes (they reference by ID)

### Delete Custom Category
1. Verify category is not default (BR-2.3)
2. Count expenses using this category
3. If count > 0: Require user to select reassignment target
4. Reassign all expenses from deleted category to target category
5. Delete category from database

---

## Filter Logic

### Date Range Filter
- If dateFrom specified: include expenses where date >= dateFrom (start of day)
- If dateTo specified: include expenses where date <= dateTo (end of day)
- Predefined ranges: "This Week" (Monday–today), "This Month" (1st–today), "Last Month" (full previous month)

### Category Filter
- Accept list of category IDs
- Include expenses where categoryId is in the list
- Empty list = no filter (show all)

### Amount Range Filter
- If amountMin specified: include expenses where amount >= amountMin
- If amountMax specified: include expenses where amount <= amountMax

### Search
- Case-insensitive substring match on description field
- Empty search = no filter

### Combined Filters
- All filters are AND conditions (must satisfy all active filters)
- Order: Apply all filters, then sort by date descending (newest first)

---

## Expense List Pagination
- Load 20 expenses per page
- Infinite scroll triggers next page load when user scrolls to bottom
- Total count shown in header
- Empty state shown when no expenses match filters
