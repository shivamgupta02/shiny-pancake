package com.expensecalculator.expense_calculator

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.provider.Telephony

/**
 * BroadcastReceiver that listens for incoming SMS messages.
 * When a new SMS arrives, it stores it in SharedPreferences as a pending message.
 * The Flutter app reads pending messages via the MethodChannel on next launch/resume.
 */
class SmsReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return

        val messages = Telephony.Sms.Intents.getMessagesFromIntent(intent)
        if (messages.isEmpty()) return

        // Combine multi-part messages
        val fullBody = StringBuilder()
        var sender = ""
        var timestamp = System.currentTimeMillis()

        for (message in messages) {
            fullBody.append(message.messageBody)
            sender = message.originatingAddress ?: ""
            timestamp = message.timestampMillis
        }

        val body = fullBody.toString()

        // Store in SharedPreferences for Flutter to pick up
        val prefs = context.getSharedPreferences("pending_sms", Context.MODE_PRIVATE)
        val existingCount = prefs.getInt("count", 0)
        val newIndex = existingCount

        prefs.edit()
            .putString("body_$newIndex", body)
            .putString("sender_$newIndex", sender)
            .putLong("date_$newIndex", timestamp)
            .putInt("count", existingCount + 1)
            .apply()
    }
}
