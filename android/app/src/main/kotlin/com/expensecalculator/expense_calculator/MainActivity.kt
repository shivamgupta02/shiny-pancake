package com.expensecalculator.expense_calculator

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private lateinit var smsPlugin: SmsPlugin

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        smsPlugin = SmsPlugin(this)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.expensecalculator/sms"
        ).setMethodCallHandler(smsPlugin)
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        smsPlugin.onRequestPermissionsResult(requestCode, grantResults)
    }
}
