# Business Logic — Unit 7: Auth & Settings

## PIN Authentication

### PIN Setup (Onboarding)
1. User enters 4-6 digit PIN
2. Validate: digits only, 4-6 length
3. User enters PIN again to confirm
4. If match: hash PIN with SHA-256, store hash in secure storage
5. If mismatch: show "PINs don't match", clear and retry

### PIN Verification (App Unlock)
1. User enters PIN
2. Hash entered PIN with SHA-256
3. Compare hash against stored hash
4. If match: unlock app, reset attempt counter
5. If mismatch: increment attempt counter, show "Incorrect PIN"
6. After 3 failed attempts: lock for 30 seconds, show countdown
7. After 5 failed attempts: lock for 5 minutes

### PIN Change
1. Require current PIN verification first
2. If current PIN valid: proceed to new PIN entry (same as setup)
3. Store new hash, discard old hash

---

## Biometric Authentication

### Setup
1. Check device supports biometric (local_auth canCheckBiometrics)
2. If supported: offer "Enable fingerprint/face unlock?" during setup or settings
3. If user enables: store biometricEnabled = true in settings

### Verification
1. On app launch (if biometricEnabled):
   - Show biometric prompt first
   - If success: unlock app
   - If fail/cancel: fall back to PIN entry
2. If device no longer supports biometric: auto-fall back to PIN

---

## Inactivity Timeout

### Logic
1. Track last user interaction timestamp
2. On app resume (from background):
   - Calculate elapsed = now - lastInteraction
   - If elapsed >= timeoutMinutes: lock app, require PIN/biometric
   - If elapsed < timeout: resume without auth
3. On app pause: record current timestamp
4. Timeout options: Immediately (0), 1 min, 5 min, 15 min

---

## Onboarding Flow

### Steps (sequential, linear)
1. **Welcome**: Display app name and brief description → "Get Started" button
2. **Name**: Enter name (required, 1-30 chars) → "Next" button
3. **PIN Setup**: Enter and confirm PIN (4-6 digits) → auto-advances
4. **SMS Permission**: Explain why needed, "Allow" / "Skip" buttons
   - If Allow: request READ_SMS permission
   - If Skip: set smsEnabled = false, continue
5. **Complete**: "You're all set!" → Navigate to Dashboard

### State Tracking
- onboardingComplete = false until step 5
- If app killed mid-onboarding: restart from step 1 on next launch
- Once complete: never show onboarding again

---

## Settings Management

### Theme Change
1. User selects: System (0), Light (1), Dark (2)
2. Update themeMode in AppSettings
3. Apply theme immediately (MaterialApp rebuilds)
4. Persist across restarts

### Timeout Change
1. User selects from: Immediately, 1 min, 5 min, 15 min
2. Update timeoutMinutes in AppSettings
3. Active immediately

---

## Backup Logic

### Create Backup
1. Read all expenses from database
2. Read all categories (including custom)
3. Read app settings
4. Serialize to JSON structure:
```json
{
  "version": 1,
  "createdAt": "2026-06-09T12:00:00Z",
  "expenses": [...],
  "categories": [...],
  "settings": {...}
}
```
5. Write to file: `expense_backup_{date}.json`
6. Update lastBackupDate in settings
7. Return file path for sharing

### Restore Backup
1. User selects backup file from device
2. Read and parse JSON
3. Validate structure:
   - Check "version" field exists
   - Check "expenses" and "categories" arrays exist
   - Validate each expense and category has required fields
4. Show warning: "This will replace ALL current data. Continue?"
5. If confirmed:
   - Clear all existing expenses
   - Clear all custom categories (keep defaults)
   - Import categories (re-create custom ones)
   - Import expenses (map categoryIds to new/existing categories)
   - Update settings (except PIN and biometric)
6. Show success: "Restored X expenses and Y categories"

### Backup Validation Rules
| Rule | Error Message |
|------|---------------|
| File must be valid JSON | "Invalid backup file format" |
| Must have "version" field | "Unsupported backup format" |
| Version must be 1 | "Unsupported backup version" |
| Must have expenses array | "Backup file is corrupted" |
| Must have categories array | "Backup file is corrupted" |
