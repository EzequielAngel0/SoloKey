package com.angelezequiel.solokey

import android.content.ComponentName
import android.content.Intent
import android.os.Build
import android.provider.Settings
import android.view.WindowManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers

class MainActivity : FlutterFragmentActivity() {

    private val SECURITY_CHANNEL = "com.solokey/security"
    private val AUTOFILL_CHANNEL  = "com.solokey/autofill_settings"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // ── Passkey channel ───────────────────────────────────────────────────
        PasskeyHandler.register(flutterEngine, this)

        // ── Security channel ──────────────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SECURITY_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setFlagSecure" -> {
                        val enable = call.argument<Boolean>("enable") ?: false
                        runOnUiThread {
                            try {
                                if (enable) {
                                    window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                                } else {
                                    window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                                }
                                result.success(null)
                            } catch (e: Exception) {
                                result.error("FLAG_SECURE_ERROR", e.message, null)
                            }
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // ── Autofill settings channel ─────────────────────────────────────────
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, AUTOFILL_CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Opens the system Autofill settings page where the user can
                    // select SoloKey as the default Autofill provider.
                    "openAutofillSettings" -> {
                        runOnUiThread {
                            try {
                                val intent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                    Intent(Settings.ACTION_REQUEST_SET_AUTOFILL_SERVICE).apply {
                                        data = android.net.Uri.parse(
                                            "package:${packageName}"
                                        )
                                    }
                                } else {
                                    Intent(Settings.ACTION_SETTINGS)
                                }
                                startActivity(intent)
                                result.success(true)
                            } catch (e: Exception) {
                                result.error("AUTOFILL_SETTINGS_ERROR", e.message, null)
                            }
                        }
                    }

                    // Returns true if SoloKey is currently the active autofill service.
                    "isAutofillEnabled" -> {
                        runOnUiThread {
                            val enabled = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                                val setting = Settings.Secure.getString(
                                    contentResolver,
                                    "autofill_service"
                                )
                                setting?.contains(packageName) == true
                            } else {
                                false
                            }
                            result.success(enabled)
                        }
                    }

                    else -> result.notImplemented()
                }
            }
    }
}
