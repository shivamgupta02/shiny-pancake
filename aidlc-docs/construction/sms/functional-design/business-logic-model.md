# Business Logic — Unit 6: SMS Auto-Detection

## SMS Parsing Patterns

### Primary Pattern (Indian Bank Debit Alert)
**Format**: "Rs.{amount} debited from A/c {account} on {date}. {method}/{merchant}. Avl bal: Rs.{balance}"

**Regex patterns to match**:
```
Pattern 1 (Debit): /(?:Rs\.?|INR|₹)\s*([0-9,]+\.?\d*)\s*(?:debited|spent|paid|withdrawn)/i
Pattern 2 (UPI):   /(?:UPI|IMPS|NEFT)\/?(.+?)(?:\.|Avl|Bal|$)/i  
Pattern 3 (Date):  /on\s+(\d{1,2}[-\/]\w{3}[-\/]?\d{0,4})/i
Pattern 4 (Bal):   /(?:Avl\.?\s*[Bb]al|Balance)[:\s]*(?:Rs\.?|INR|₹)\s*([0-9,]+\.?\d*)/i
```

### Detection Keywords (isTransactionSms check)
A message is considered a potential transaction if it contains ANY of:
- Amount indicator: "Rs.", "Rs", "INR", "₹" followed by a number
- AND action keyword: "debited", "spent", "paid", "withdrawn", "charged", "deducted"

### Exclusion Patterns (NOT a transaction)
Skip messages containing:
- "credited" (income, not expense)
- "OTP", "One Time Password" (security messages)
- "ATM Cash" without debit keyword (balance inquiry)
- "available balance" without debit action

---

## Extraction Logic

### extractAmount(String smsBody)
1. Search for pattern: `(?:Rs\.?|INR|₹)\s*([0-9,]+\.?\d*)` 
2. Remove commas from matched group
3. Parse as double
4. Validate: amount > 0 and amount <= 10,000,000
5. Return amount or null if not found/invalid

### extractMerchant(String smsBody)
1. Look for patterns after UPI/, IMPS/, at, to:
   - `(?:UPI|IMPS|NEFT)\/?(.+?)(?:\.|Avl|Bal|Info|$)`
   - `(?:at|to|@)\s+(.+?)(?:\s+on|\s+ref|\.|\s+Avl)`
2. Trim result, capitalize first letter
3. Truncate at 50 characters
4. Return merchant or "Unknown" if not found

### extractDate(String smsBody)
1. Look for date patterns:
   - `(\d{1,2}[-\/]\w{3}[-\/]?\d{2,4})` → "09-Jun-26" or "09/Jun/2026"
   - `(\d{1,2}[-\/]\d{1,2}[-\/]\d{2,4})` → "09-06-2026" or "09/06/26"
2. Parse matched date
3. Validate: not future, not > 2 years ago
4. If no date found or invalid: default to today

---

## Detection Flow

### Real-Time Background Listener
1. Register SMS broadcast receiver (Android)
2. On new SMS received:
   a. Check isTransactionSms() — quick keyword check
   b. If true: parseMessage() to extract details
   c. If extraction successful: create DetectedExpense
   d. Show local notification: "₹{amount} spent at {merchant}. Tap to save."
   e. Store DetectedExpense in pending queue (not saved to expenses yet)

### On-Demand Scan
1. User triggers scan from SMS feature screen
2. Read last 7 days of SMS messages (configurable)
3. For each SMS: apply isTransactionSms() + parseMessage()
4. Collect all DetectedExpense results
5. Present as a list for batch confirmation
6. User can confirm, edit, or dismiss each one

---

## DetectedExpense (Temporary Entity)

| Field | Type | Description |
|-------|------|-------------|
| amount | double | Extracted amount |
| merchant | String | Extracted merchant/description |
| date | DateTime | Extracted or defaulted date |
| rawSmsBody | String | Original SMS for reference |
| smsDate | DateTime | When SMS was received |
| confidence | double | 0.0–1.0 extraction confidence |
| status | DetectionStatus | pending / confirmed / dismissed |

---

## Confidence Scoring

| Factor | Score |
|--------|-------|
| Amount extracted successfully | +0.4 |
| Merchant extracted successfully | +0.3 |
| Date extracted successfully | +0.2 |
| Known bank sender (e.g., starts with VM-, VD-, BZ-) | +0.1 |

- **High confidence (>= 0.7)**: All fields extracted, show auto-suggest
- **Medium confidence (0.4–0.7)**: Partial extraction, show with "Review" label
- **Low confidence (< 0.4)**: Likely false positive, don't show notification

---

## User Confirmation Flow
1. User opens detected expense (from notification or scan list)
2. Shows: Amount, Merchant (as description), Date, Category (auto-suggest "Other")
3. User can:
   - **Confirm**: Save as expense (amount, category, description=merchant, date, source=sms)
   - **Edit & Confirm**: Modify any field, then save
   - **Dismiss**: Discard detection (don't show again for this SMS)
