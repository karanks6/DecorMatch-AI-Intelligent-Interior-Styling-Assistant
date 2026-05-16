package com.example.app

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.PowerManager
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "decormatch/battery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openBatterySettings" -> {
                        try {
                            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                                val pm = getSystemService(POWER_SERVICE) as PowerManager
                                if (!pm.isIgnoringBatteryOptimizations(packageName)) {
                                    // Request direct exemption — opens the exact toggle
                                    val intent = Intent(
                                        Settings.ACTION_REQUEST_IGNORE_BATTERY_OPTIMIZATIONS,
                                        Uri.parse("package:$packageName")
                                    )
                                    startActivity(intent)
                                } else {
                                    // Already whitelisted — open general battery settings
                                    startActivity(Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS))
                                }
                            }
                            result.success(null)
                        } catch (e: Exception) {
                            // Fallback to general settings if intent not supported
                            try {
                                startActivity(Intent(Settings.ACTION_BATTERY_SAVER_SETTINGS))
                                result.success(null)
                            } catch (ex: Exception) {
                                result.error("UNAVAILABLE", "Cannot open battery settings", null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
