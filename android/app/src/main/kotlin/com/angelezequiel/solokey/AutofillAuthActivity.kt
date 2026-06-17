package com.angelezequiel.solokey

import android.app.Activity
import android.app.PendingIntent
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.os.Bundle
import android.os.Handler
import android.os.Parcelable
import android.service.autofill.Dataset
import android.service.autofill.FillResponse
import android.service.autofill.InlinePresentation
import android.view.autofill.AutofillId
import android.view.autofill.AutofillManager
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import android.widget.Toast
import androidx.annotation.RequiresApi
import androidx.autofill.inline.UiVersions
import androidx.autofill.inline.v1.InlineSuggestionUi
import androidx.biometric.BiometricManager
import androidx.biometric.BiometricPrompt
import androidx.core.content.ContextCompat
import androidx.fragment.app.FragmentActivity
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel

/**
 * Transparent activity launched when the user taps the "Unlock SoloKey" autofill
 * suggestion. It gates on biometrics (the "biometría antes de inyectar" step),
 * then asks the Dart `autofillEntrypoint` — in a short-lived headless engine —
 * for the decrypted matches and returns them to the framework as a FillResponse
 * (response-level authentication result).
 */
class AutofillAuthActivity : FragmentActivity() {

    private val channelName = "com.solokey/autofill"

    private var callerPackage = ""
    private var callerDomain = ""
    private var usernameId: AutofillId? = null
    private var passwordId: AutofillId? = null

    // Typed as Any? to avoid a class-verification error on API < 30 where
    // android.view.inputmethod.InlineSuggestionsRequest does not exist.
    private var inlineRequest: Any? = null

    private var engine: FlutterEngine? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        callerPackage = intent.getStringExtra(SoloKeyAutofillService.EXTRA_PACKAGE) ?: ""
        callerDomain = intent.getStringExtra(SoloKeyAutofillService.EXTRA_DOMAIN) ?: ""
        usernameId = intent.parcelable(SoloKeyAutofillService.EXTRA_USERNAME_ID)
        passwordId = intent.parcelable(SoloKeyAutofillService.EXTRA_PASSWORD_ID)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            inlineRequest = intent.parcelable<android.view.inputmethod.InlineSuggestionsRequest>(
                SoloKeyAutofillService.EXTRA_INLINE_REQUEST,
            )
        }

        promptBiometric()
    }

    // ── Biometric gate ─────────────────────────────────────────────────────

    private fun promptBiometric() {
        // BIOMETRIC_STRONG | DEVICE_CREDENTIAL is unsupported on API 28-29 and
        // throws at build() — use the weak class there to keep the PIN fallback.
        val authenticators = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            BiometricManager.Authenticators.BIOMETRIC_STRONG or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        } else {
            BiometricManager.Authenticators.BIOMETRIC_WEAK or
                BiometricManager.Authenticators.DEVICE_CREDENTIAL
        }
        val executor = ContextCompat.getMainExecutor(this)
        val prompt = BiometricPrompt(
            this,
            executor,
            object : BiometricPrompt.AuthenticationCallback() {
                override fun onAuthenticationSucceeded(result: BiometricPrompt.AuthenticationResult) {
                    fetchAndReturn()
                }

                override fun onAuthenticationError(errorCode: Int, errString: CharSequence) {
                    cancel()
                }

                override fun onAuthenticationFailed() {
                    // Keep the prompt open for retries; the system handles lockout.
                }
            },
        )
        val info = BiometricPrompt.PromptInfo.Builder()
            .setTitle("SoloKey")
            .setSubtitle("Verifica tu identidad para autocompletar")
            .setAllowedAuthenticators(authenticators)
            .build()
        prompt.authenticate(info)
    }

    // ── Decrypt + match via headless Dart engine ─────────────────────────────

    private fun fetchAndReturn() {
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(applicationContext)
        loader.ensureInitializationComplete(applicationContext, emptyArray())

        val eng = FlutterEngine(applicationContext)
        engine = eng
        eng.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(loader.findAppBundlePath(), "autofillEntrypoint"),
        )

        val channel = MethodChannel(eng.dartExecutor.binaryMessenger, channelName)
        invokeFetch(channel, retriesLeft = 3)
    }

    private fun invokeFetch(channel: MethodChannel, retriesLeft: Int) {
        channel.invokeMethod(
            "fetchMatches",
            mapOf("package" to callerPackage, "domain" to callerDomain),
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    @Suppress("UNCHECKED_CAST")
                    val raw = result as? List<Map<String, Any?>> ?: emptyList()
                    returnDatasets(
                        raw.map {
                            AutofillCredential(
                                title = it["title"] as? String ?: "",
                                username = it["username"] as? String,
                                password = it["password"] as? String,
                            )
                        },
                    )
                }

                override fun error(code: String, message: String?, details: Any?) {
                    cancel()
                }

                override fun notImplemented() {
                    // The Dart handler may not be registered yet — retry shortly.
                    if (retriesLeft > 0) {
                        Handler(mainLooper).postDelayed(
                            { invokeFetch(channel, retriesLeft - 1) },
                            200,
                        )
                    } else {
                        cancel()
                    }
                }
            },
        )
    }

    // ── Build the resolved FillResponse ──────────────────────────────────────

    private fun returnDatasets(creds: List<AutofillCredential>) {
        if (creds.isEmpty()) {
            Toast.makeText(
                this,
                "Activa el desbloqueo biométrico en SoloKey o no hay coincidencias",
                Toast.LENGTH_LONG,
            ).show()
            cancel()
            return
        }

        val datasets = creds.take(5).mapIndexedNotNull { index, cred ->
            buildDataset(cred, index)
        }
        if (datasets.isEmpty()) {
            cancel()
            return
        }

        val responseBuilder = FillResponse.Builder()
        datasets.forEach { responseBuilder.addDataset(it) }

        val reply = Intent().apply {
            putExtra(AutofillManager.EXTRA_AUTHENTICATION_RESULT, responseBuilder.build())
        }
        setResult(Activity.RESULT_OK, reply)
        finishAndCleanup()
    }

    private fun buildDataset(cred: AutofillCredential, index: Int): Dataset? {
        val presentation = RemoteViews(packageName, R.layout.autofill_dataset_item).apply {
            setTextViewText(R.id.autofill_title, cred.title)
            setTextViewText(R.id.autofill_subtitle, cred.username ?: "")
        }
        val inline = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            buildInline(cred, index)
        } else {
            null
        }

        val builder = Dataset.Builder()
        var hasValue = false

        usernameId?.let { id ->
            val value = AutofillValue.forText(cred.username ?: "")
            if (inline != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                builder.setValue(id, value, presentation, inline)
            } else {
                builder.setValue(id, value, presentation)
            }
            hasValue = true
        }
        passwordId?.let { id ->
            val value = AutofillValue.forText(cred.password ?: "")
            if (inline != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                builder.setValue(id, value, presentation, inline)
            } else {
                builder.setValue(id, value, presentation)
            }
            hasValue = true
        }
        return if (hasValue) builder.build() else null
    }

    @RequiresApi(Build.VERSION_CODES.R)
    private fun buildInline(cred: AutofillCredential, index: Int): InlinePresentation? {
        val req = inlineRequest as? android.view.inputmethod.InlineSuggestionsRequest ?: return null
        val specs = req.inlinePresentationSpecs
        if (specs.isEmpty()) return null
        val spec = specs[minOf(index, specs.size - 1)]
        if (!UiVersions.getVersions(spec.style).contains(UiVersions.INLINE_UI_VERSION_1)) {
            return null
        }
        val pi = PendingIntent.getActivity(
            this,
            2000 + index,
            Intent(this, MainActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_CANCEL_CURRENT,
        )
        val content = InlineSuggestionUi.newContentBuilder(pi)
            .setTitle(cred.title)
            .setSubtitle(cred.username ?: "")
            .setStartIcon(Icon.createWithResource(this, R.mipmap.ic_launcher))
            .build()
        return InlinePresentation(content.slice, spec, false)
    }

    // ── Lifecycle helpers ────────────────────────────────────────────────────

    private fun cancel() {
        setResult(Activity.RESULT_CANCELED)
        finishAndCleanup()
    }

    private fun finishAndCleanup() {
        engine?.destroy()
        engine = null
        finish()
    }
}

/** API-aware Intent.getParcelableExtra. */
private inline fun <reified T : Parcelable> Intent.parcelable(key: String): T? =
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
        getParcelableExtra(key, T::class.java)
    } else {
        @Suppress("DEPRECATION")
        getParcelableExtra(key) as? T
    }
