package com.expensecalculator.expense_calculator

import android.Manifest
import android.app.Activity
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class SmsPlugin(private val activity: Activity) : MethodChannel.MethodCallHandler {

    companion object {
        private const val SMS_PERMISSION_REQUEST_CODE = 101
    }

    private var pendingResult: MethodChannel.Result? = null

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "hasPermission" -> {
                val granted = ContextCompat.checkSelfPermission(
                    activity,
                    Manifest.permission.READ_SMS
                ) == PackageManager.PERMISSION_GRANTED
                result.success(granted)
            }
            "requestPermission" -> {
                if (ContextCompat.checkSelfPermission(
                        activity,
                        Manifest.permission.READ_SMS
                    ) == PackageManager.PERMISSION_GRANTED &&
                    ContextCompat.checkSelfPermission(
                        activity,
                        Manifest.permission.RECEIVE_SMS
                    ) == PackageManager.PERMISSION_GRANTED
                ) {
                    result.success(true)
                } else {
                    pendingResult = result
                    ActivityCompat.requestPermissions(
                        activity,
                        arrayOf(
                            Manifest.permission.READ_SMS,
                            Manifest.permission.RECEIVE_SMS
                        ),
                        SMS_PERMISSION_REQUEST_CODE
                    )
                }
            }
            "readMessages" -> {
                if (ContextCompat.checkSelfPermission(
                        activity,
                        Manifest.permission.READ_SMS
                    ) != PackageManager.PERMISSION_GRANTED
                ) {
                    result.error("PERMISSION_DENIED", "READ_SMS permission not granted", null)
                    return
                }

                val days = call.argument<Int>("days") ?: 7
                val messages = readSmsMessages(days)
                result.success(messages)
            }
            "getPendingMessages" -> {
                val messages = getPendingMessages()
                result.success(messages)
            }
            "clearPendingMessages" -> {
                clearPendingMessages()
                result.success(true)
            }
            else -> result.notImplemented()
        }
    }

    fun onRequestPermissionsResult(requestCode: Int, grantResults: IntArray) {
        if (requestCode == SMS_PERMISSION_REQUEST_CODE) {
            val granted = grantResults.isNotEmpty() &&
                    grantResults[0] == PackageManager.PERMISSION_GRANTED
            pendingResult?.success(granted)
            pendingResult = null
        }
    }

    private fun readSmsMessages(days: Int): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        val cutoffTime = System.currentTimeMillis() - (days.toLong() * 24 * 60 * 60 * 1000)

        val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI
        val projection = arrayOf(
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
            Telephony.Sms.ADDRESS
        )
        val selection = "${Telephony.Sms.DATE} >= ?"
        val selectionArgs = arrayOf(cutoffTime.toString())
        val sortOrder = "${Telephony.Sms.DATE} DESC"

        val cursor = activity.contentResolver.query(
            uri,
            projection,
            selection,
            selectionArgs,
            sortOrder
        )

        cursor?.use { c ->
            val bodyIndex = c.getColumnIndexOrThrow(Telephony.Sms.BODY)
            val dateIndex = c.getColumnIndexOrThrow(Telephony.Sms.DATE)
            val addressIndex = c.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)

            while (c.moveToNext()) {
                val body = c.getString(bodyIndex) ?: continue
                val date = c.getLong(dateIndex)
                val sender = c.getString(addressIndex) ?: ""

                messages.add(
                    mapOf(
                        "body" to body,
                        "date" to date,
                        "sender" to sender
                    )
                )
            }
        }

        return messages
    }

    private fun getPendingMessages(): List<Map<String, Any>> {
        val prefs = activity.getSharedPreferences("pending_sms", android.content.Context.MODE_PRIVATE)
        val count = prefs.getInt("count", 0)
        val messages = mutableListOf<Map<String, Any>>()

        for (i in 0 until count) {
            val body = prefs.getString("body_$i", null) ?: continue
            val sender = prefs.getString("sender_$i", "") ?: ""
            val date = prefs.getLong("date_$i", System.currentTimeMillis())

            messages.add(
                mapOf(
                    "body" to body,
                    "sender" to sender,
                    "date" to date
                )
            )
        }

        return messages
    }

    private fun clearPendingMessages() {
        val prefs = activity.getSharedPreferences("pending_sms", android.content.Context.MODE_PRIVATE)
        prefs.edit().clear().apply()
    }
}
