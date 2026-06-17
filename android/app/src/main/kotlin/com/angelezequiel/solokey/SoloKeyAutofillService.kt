package com.angelezequiel.solokey

import android.app.PendingIntent
import android.app.assist.AssistStructure
import android.content.Intent
import android.graphics.drawable.Icon
import android.os.Build
import android.os.CancellationSignal
import android.service.autofill.AutofillService
import android.service.autofill.FillCallback
import android.service.autofill.FillRequest
import android.service.autofill.FillResponse
import android.service.autofill.InlinePresentation
import android.service.autofill.SaveCallback
import android.service.autofill.SaveRequest
import android.text.InputType
import android.view.View
import android.view.autofill.AutofillId
import android.widget.RemoteViews
import androidx.annotation.RequiresApi
import androidx.autofill.inline.UiVersions
import androidx.autofill.inline.v1.InlineSuggestionUi

/**
 * SoloKey AutofillService — offers credential suggestions to login forms across
 * all apps, using the locked-vault "authentication-first" pattern.
 *
 * Why authentication-first:
 *   This service runs in its own process with the vault LOCKED, and the website
 *   needed to match a credential lives inside the AES-256-GCM encrypted payload,
 *   so we cannot decrypt/match here. Instead we publish a single "Unlock SoloKey"
 *   entry — both as a classic dropdown row AND, on Android 11+ (API 30), as an
 *   inline chip inside the keyboard. Tapping it launches [AutofillAuthActivity],
 *   which gates on biometrics, decrypts via a short-lived headless Flutter engine
 *   and returns the real datasets. The password never crosses the OS in cleartext
 *   until the framework injects it into the destination field.
 *
 * onSaveRequest stays a stub — SoloKey doesn't capture new credentials from here.
 */
class SoloKeyAutofillService : AutofillService() {

    override fun onFillRequest(
        request: FillRequest,
        cancellationSignal: CancellationSignal,
        callback: FillCallback,
    ) {
        val structure = request.fillContexts.lastOrNull()?.structure
        if (structure == null) {
            callback.onSuccess(null)
            return
        }

        val parser = StructureParser(structure).apply { parse() }
        if (parser.usernameId == null && parser.passwordId == null) {
            // No autofillable login fields found — nothing to suggest.
            callback.onSuccess(null)
            return
        }

        val appPackage = structure.activityComponent?.packageName ?: ""
        val webDomain = parser.webDomain ?: ""
        val autofillIds = listOfNotNull(parser.usernameId, parser.passwordId).toTypedArray()

        // Intent that performs biometric unlock + credential fetch and returns
        // the resolved FillResponse to the framework.
        val authIntent = Intent(this, AutofillAuthActivity::class.java).apply {
            putExtra(EXTRA_PACKAGE, appPackage)
            putExtra(EXTRA_DOMAIN, webDomain)
            parser.usernameId?.let { putExtra(EXTRA_USERNAME_ID, it) }
            parser.passwordId?.let { putExtra(EXTRA_PASSWORD_ID, it) }
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                request.inlineSuggestionsRequest?.let { putExtra(EXTRA_INLINE_REQUEST, it) }
            }
        }
        val authFlags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            PendingIntent.FLAG_MUTABLE or PendingIntent.FLAG_CANCEL_CURRENT
        } else {
            PendingIntent.FLAG_CANCEL_CURRENT
        }
        val intentSender = PendingIntent
            .getActivity(this, REQUEST_CODE_AUTH, authIntent, authFlags)
            .intentSender

        val presentation = unlockRemoteViews()
        val responseBuilder = FillResponse.Builder()

        val inline = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            buildUnlockInline(request)
        } else {
            null
        }
        if (inline != null && Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            responseBuilder.setAuthentication(autofillIds, intentSender, presentation, inline)
        } else {
            responseBuilder.setAuthentication(autofillIds, intentSender, presentation)
        }

        callback.onSuccess(responseBuilder.build())
    }

    override fun onSaveRequest(request: SaveRequest, callback: SaveCallback) {
        callback.onSuccess()
    }

    // ── presentations ───────────────────────────────────────────────────────

    private fun unlockRemoteViews(): RemoteViews =
        RemoteViews(packageName, R.layout.autofill_dataset_item).apply {
            setTextViewText(R.id.autofill_title, "Desbloquear SoloKey")
            setTextViewText(R.id.autofill_subtitle, "Toca para autenticarte y rellenar")
        }

    @RequiresApi(Build.VERSION_CODES.R)
    private fun buildUnlockInline(request: FillRequest): InlinePresentation? {
        val specs = request.inlineSuggestionsRequest?.inlinePresentationSpecs ?: return null
        if (specs.isEmpty()) return null
        val spec = specs[0]
        if (!UiVersions.getVersions(spec.style).contains(UiVersions.INLINE_UI_VERSION_1)) {
            return null
        }
        // The inline content API requires a PendingIntent even though the
        // response-level authentication is what actually handles the tap.
        val pi = PendingIntent.getActivity(
            this,
            REQUEST_CODE_INLINE,
            Intent(this, AutofillAuthActivity::class.java),
            PendingIntent.FLAG_IMMUTABLE or PendingIntent.FLAG_CANCEL_CURRENT,
        )
        val content = InlineSuggestionUi.newContentBuilder(pi)
            .setTitle("Desbloquear SoloKey")
            .setStartIcon(Icon.createWithResource(this, R.mipmap.ic_launcher))
            .build()
        return InlinePresentation(content.slice, spec, false)
    }

    companion object {
        const val EXTRA_PACKAGE = "extra_package"
        const val EXTRA_DOMAIN = "extra_domain"
        const val EXTRA_USERNAME_ID = "extra_username_id"
        const val EXTRA_PASSWORD_ID = "extra_password_id"
        const val EXTRA_INLINE_REQUEST = "extra_inline_request"
        private const val REQUEST_CODE_AUTH = 1001
        private const val REQUEST_CODE_INLINE = 1002
    }
}

// ── Supporting types ────────────────────────────────────────────────────────

/** Plain holder for a decrypted credential returned from the Dart side. */
data class AutofillCredential(
    val title: String,
    val username: String?,
    val password: String?,
)

/**
 * Traverses the AssistStructure looking for the username/password fields.
 * Primary signal is the app's `autofillHints`; when missing (many apps don't set
 * them) it falls back to inputType flags and hint/resource-id text heuristics.
 */
class StructureParser(private val structure: AssistStructure) {

    var usernameId: AutofillId? = null
    var passwordId: AutofillId? = null
    var webDomain: String? = null

    fun parse() {
        for (i in 0 until structure.windowNodeCount) {
            parseNode(structure.getWindowNodeAt(i).rootViewNode)
        }
    }

    private fun parseNode(node: AssistStructure.ViewNode) {
        if (webDomain == null && !node.webDomain.isNullOrEmpty()) {
            webDomain = node.webDomain
        }

        val id = node.autofillId
        if (id != null) {
            val hints = node.autofillHints
            if (hints != null && hints.isNotEmpty()) {
                when {
                    hints.any { it.contains("password", ignoreCase = true) } ->
                        passwordId = passwordId ?: id
                    hints.any {
                        it.contains("username", ignoreCase = true) ||
                            it.contains("email", ignoreCase = true)
                    } -> usernameId = usernameId ?: id
                }
            } else if (isEditable(node)) {
                if (isPasswordField(node)) {
                    passwordId = passwordId ?: id
                } else if (isUsernameField(node)) {
                    usernameId = usernameId ?: id
                }
            }
        }

        for (i in 0 until node.childCount) parseNode(node.getChildAt(i))
    }

    private fun isEditable(node: AssistStructure.ViewNode): Boolean =
        node.className?.contains("EditText") == true ||
            node.autofillType == View.AUTOFILL_TYPE_TEXT

    private fun isPasswordField(node: AssistStructure.ViewNode): Boolean {
        val type = node.inputType
        val klass = type and InputType.TYPE_MASK_CLASS
        val variation = type and InputType.TYPE_MASK_VARIATION
        val textPwd = klass == InputType.TYPE_CLASS_TEXT && (
            variation == InputType.TYPE_TEXT_VARIATION_PASSWORD ||
                variation == InputType.TYPE_TEXT_VARIATION_VISIBLE_PASSWORD ||
                variation == InputType.TYPE_TEXT_VARIATION_WEB_PASSWORD
            )
        val numberPwd = klass == InputType.TYPE_CLASS_NUMBER &&
            variation == InputType.TYPE_NUMBER_VARIATION_PASSWORD
        if (textPwd || numberPwd) return true
        val h = hintText(node)
        return h.contains("password") || h.contains("contrase")
    }

    private fun isUsernameField(node: AssistStructure.ViewNode): Boolean {
        val variation = node.inputType and InputType.TYPE_MASK_VARIATION
        if (variation == InputType.TYPE_TEXT_VARIATION_EMAIL_ADDRESS ||
            variation == InputType.TYPE_TEXT_VARIATION_WEB_EMAIL_ADDRESS
        ) {
            return true
        }
        val h = hintText(node)
        return h.contains("user") || h.contains("email") ||
            h.contains("usuario") || h.contains("correo") || h.contains("login")
    }

    private fun hintText(node: AssistStructure.ViewNode): String =
        ((node.hint ?: "") + " " + (node.idEntry ?: "")).lowercase()
}
