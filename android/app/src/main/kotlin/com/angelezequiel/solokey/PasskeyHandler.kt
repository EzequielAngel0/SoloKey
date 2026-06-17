package com.angelezequiel.solokey

import android.app.Activity
import android.content.Context
import android.os.Build
import androidx.credentials.CreatePublicKeyCredentialRequest
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.GetPublicKeyCredentialOption
import androidx.credentials.PublicKeyCredential
import androidx.credentials.exceptions.CreateCredentialException
import androidx.credentials.exceptions.GetCredentialException
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

/**
 * SoloKey Passkey Handler
 *
 * Bridges the Android Credential Manager API (API 34+ / Credential Manager)
 * with the Flutter/Dart side via [MethodChannel].
 *
 * Security model:
 *  - The private key NEVER leaves the Android Keystore / FIDO2 authenticator.
 *  - What we store in our vault is the *credentialId* and metadata (rpId, etc.)
 *    so the user can track which passkeys they have registered.
 *  - Actual authentication/assertion is delegated entirely to the platform.
 *
 * Channel: "com.solokey/passkeys"
 * Methods:
 *  - createPasskey(requestJson: String) -> Map  (registration)
 *  - assertPasskey(requestJson: String) -> Map  (authentication)
 *  - isPasskeySupported() -> Boolean
 */
class PasskeyHandler(
    private val activity: Activity,
    private val scope: CoroutineScope = CoroutineScope(Dispatchers.Main),
) : MethodChannel.MethodCallHandler {

    companion object {
        const val CHANNEL = "com.solokey/passkeys"

        fun register(flutterEngine: FlutterEngine, activity: Activity) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(PasskeyHandler(activity))
        }
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "isPasskeySupported" -> result.success(isPasskeySupported())

            "createPasskey" -> {
                val requestJson = call.argument<String>("requestJson")
                    ?: return result.error("INVALID_ARG", "requestJson is required", null)
                createPasskey(requestJson, result)
            }

            "assertPasskey" -> {
                val requestJson = call.argument<String>("requestJson")
                    ?: return result.error("INVALID_ARG", "requestJson is required", null)
                assertPasskey(requestJson, result)
            }

            else -> result.notImplemented()
        }
    }

    // ── Passkey support check ─────────────────────────────────────────────────

    private fun isPasskeySupported(): Boolean =
        Build.VERSION.SDK_INT >= Build.VERSION_CODES.P // API 28+

    // ── Passkey Registration (create) ─────────────────────────────────────────

    private fun createPasskey(requestJson: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.error("UNSUPPORTED", "Passkeys require Android 9+", null)
            return
        }

        scope.launch {
            try {
                val credentialManager = CredentialManager.create(activity)
                val request = CreatePublicKeyCredentialRequest(requestJson)
                val response = credentialManager.createCredential(
                    context = activity,
                    request = request,
                )
                // Return the registration response JSON to Dart
                result.success(
                    mapOf(
                        "type" to response.type,
                        "responseJson" to (response.data.getString("androidx.credentials.BUNDLE_KEY_REGISTRATION_RESPONSE_JSON") ?: "{}"),
                    )
                )
            } catch (e: CreateCredentialException) {
                result.error("CREATE_PASSKEY_FAILED", e.message, e.type)
            } catch (e: Exception) {
                result.error("CREATE_PASSKEY_ERROR", e.message, null)
            }
        }
    }

    // ── Passkey Assertion (authenticate) ─────────────────────────────────────

    private fun assertPasskey(requestJson: String, result: MethodChannel.Result) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.P) {
            result.error("UNSUPPORTED", "Passkeys require Android 9+", null)
            return
        }

        scope.launch {
            try {
                val credentialManager = CredentialManager.create(activity)
                val option = GetPublicKeyCredentialOption(requestJson)
                val request = GetCredentialRequest(listOf(option))
                val response = credentialManager.getCredential(
                    context = activity,
                    request = request,
                )

                val credential = response.credential
                if (credential is PublicKeyCredential) {
                    result.success(
                        mapOf(
                            "type" to "publicKey",
                            "responseJson" to credential.authenticationResponseJson,
                        )
                    )
                } else {
                    result.error("UNEXPECTED_TYPE", "Unexpected credential type: ${credential.type}", null)
                }
            } catch (e: GetCredentialException) {
                result.error("ASSERT_PASSKEY_FAILED", e.message, e.type)
            } catch (e: Exception) {
                result.error("ASSERT_PASSKEY_ERROR", e.message, null)
            }
        }
    }
}
