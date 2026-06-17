package com.angelezequiel.solokey

import android.app.assist.AssistStructure
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.Dataset
import android.service.autofill.FillCallback
import android.service.autofill.FillContext
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.view.autofill.AutofillValue
import android.widget.RemoteViews
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodChannel
import io.flutter.FlutterInjector

/**
 * SoloKey AutofillService
 *
 * Integrates with the Android Autofill Framework (API 26+) to provide
 * credential suggestions for login forms across all apps.
 *
 * Flow:
 *   1. Android detects a login form -> calls onFillRequest.
 *   2. We parse the AssistStructure to find username/password fields.
 *   3. We ask the Flutter side (via MethodChannel) for matching credentials.
 *   4. We build a FillResponse with one Dataset per matching credential.
 *   5. User picks a credential -> fields are filled automatically.
 *
 * Security notes:
 *   - Credentials are only returned if the vault session is active (unlocked).
 *   - We NEVER store credentials in the AutofillService process memory.
 *   - save is a stub (v1): we don't prompt to save new credentials here.
 */
class SoloKeyAutofillService : AutofillService() {

    companion object {
        private const val CHANNEL = "com.solokey/autofill"
    }

    // ── onFillRequest ────────────────────────────────────────────────────────

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback,
    ) {
        val context: List<FillContext> = request.fillContexts
        val structure: AssistStructure = context.last().structure

        // 1. Parse the view hierarchy to discover autofillable fields
        val parser = StructureParser(structure)
        parser.parse()

        if (parser.usernameId == null && parser.passwordId == null) {
            // No autofillable fields found — nothing to suggest
            callback.onSuccess(null)
            return
        }

        val appPackage = structure.activityComponent?.packageName ?: ""
        val webDomain = parser.webDomain

        // 2. Query Flutter side for matching credentials
        queryCredentials(appPackage, webDomain) { credentials ->
            if (credentials.isEmpty()) {
                callback.onSuccess(null)
                return@queryCredentials
            }

            // 3. Build FillResponse with one Dataset per credential
            val responseBuilder = FillResponse.Builder()

            credentials.take(5).forEach { cred ->
                val datasetBuilder = Dataset.Builder()

                // Presentation view shown in the autofill dropdown
                val presentation = RemoteViews(packageName, R.layout.autofill_dataset_item)
                presentation.setTextViewText(R.id.autofill_title, cred.title)
                presentation.setTextViewText(R.id.autofill_subtitle, cred.username ?: "")

                parser.usernameId?.let { id ->
                    datasetBuilder.setValue(
                        id,
                        AutofillValue.forText(cred.username ?: ""),
                        presentation,
                    )
                }
                parser.passwordId?.let { id ->
                    datasetBuilder.setValue(
                        id,
                        AutofillValue.forText(cred.password ?: ""),
                        presentation,
                    )
                }

                responseBuilder.addDataset(datasetBuilder.build())
            }

            callback.onSuccess(responseBuilder.build())
        }
    }

    // ── onSaveRequest ─────────────────────────────────────────────────────────

    /**
     * Stub for v1 — SoloKey does not prompt to save new credentials from
     * the autofill service. Users add credentials manually via the app.
     */
    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        callback.onSuccess()
    }

    // ── Communication with Flutter ────────────────────────────────────────────

    private fun queryCredentials(
        callerPackage: String,
        callerDomain: String?,
        onResult: (List<AutofillCredential>) -> Unit,
    ) {
        // Spin up a headless FlutterEngine to communicate with Dart business logic
        val flutterLoader = FlutterInjector.instance().flutterLoader()
        flutterLoader.startInitialization(applicationContext)
        flutterLoader.ensureInitializationComplete(applicationContext, emptyArray())

        val engine = FlutterEngine(applicationContext)
        engine.dartExecutor.executeDartEntrypoint(DartExecutor.DartEntrypoint.createDefault())

        val channel = MethodChannel(engine.dartExecutor.binaryMessenger, CHANNEL)
        channel.invokeMethod(
            "queryCredentials",
            mapOf("package" to callerPackage, "domain" to (callerDomain ?: "")),
            object : MethodChannel.Result {
                override fun success(result: Any?) {
                    @Suppress("UNCHECKED_CAST")
                    val raw = result as? List<Map<String, Any?>> ?: emptyList()
                    val credentials = raw.map { map ->
                        AutofillCredential(
                            title = map["title"] as? String ?: "",
                            username = map["username"] as? String,
                            password = map["password"] as? String,
                        )
                    }
                    engine.destroy()
                    onResult(credentials)
                }

                override fun error(code: String, message: String?, details: Any?) {
                    engine.destroy()
                    onResult(emptyList())
                }

                override fun notImplemented() {
                    engine.destroy()
                    onResult(emptyList())
                }
            },
        )
    }
}

// ── Supporting types ──────────────────────────────────────────────────────────

data class AutofillCredential(
    val title: String,
    val username: String?,
    val password: String?,
)

/**
 * Traverses the AssistStructure view hierarchy looking for fields
 * that Android has tagged as username or password autofill hints.
 */
class StructureParser(private val structure: AssistStructure) {

    var usernameId: android.view.autofill.AutofillId? = null
    var passwordId: android.view.autofill.AutofillId? = null
    var webDomain: String? = null

    fun parse() {
        repeat(structure.windowNodeCount) { i ->
            parseNode(structure.getWindowNodeAt(i).rootViewNode)
        }
    }

    private fun parseNode(node: AssistStructure.ViewNode) {
        // Capture web domain from the first node that declares it
        if (webDomain == null && !node.webDomain.isNullOrEmpty()) {
            webDomain = node.webDomain
        }

        val hints = node.autofillHints ?: emptyArray()
        when {
            hints.any { it.contains("username", ignoreCase = true) ||
                        it.contains("email", ignoreCase = true) } -> {
                usernameId = node.autofillId
            }
            hints.any { it.contains("password", ignoreCase = true) } -> {
                passwordId = node.autofillId
            }
        }

        repeat(node.childCount) { i -> parseNode(node.getChildAt(i)) }
    }
}
