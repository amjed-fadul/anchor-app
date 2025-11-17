package com.anchorapp.mobile

import android.app.Activity
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.util.Log

/**
 * ShareActivity - Handles sharing URLs from other apps to Anchor
 *
 * This activity is launched when the user selects "Anchor" from the
 * system share sheet in apps like Chrome, Twitter, etc.
 *
 * Flow:
 * 1. Receives ACTION_SEND intent with text/plain MIME type
 * 2. Extracts URL from EXTRA_TEXT
 * 3. Launches MainActivity with deep link: anchor://share?url=...
 * 4. Closes itself
 */
class ShareActivity : Activity() {

    companion object {
        private const val TAG = "ShareActivity"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        Log.d(TAG, "🔵 ShareActivity onCreate START")
        Log.d(TAG, "🔵 Intent action: ${intent?.action}")
        Log.d(TAG, "🔵 Intent type: ${intent?.type}")
        Log.d(TAG, "🔵 Intent data: ${intent?.data}")
        Log.d(TAG, "🔵 Intent extras: ${intent?.extras?.keySet()?.joinToString(", ")}")

        // Handle the share intent
        when (intent?.action) {
            Intent.ACTION_SEND -> {
                // Accept text/plain or any text/* MIME type
                if (intent.type?.startsWith("text/") == true) {
                    handleTextShare(intent)
                } else {
                    Log.e(TAG, "🔴 Unsupported MIME type: ${intent.type}")
                    finish()
                }
            }
            else -> {
                Log.e(TAG, "🔴 Unknown intent action: ${intent?.action}")
                finish()
            }
        }
    }

    /**
     * Extract URL from shared text and launch main app
     */
    private fun handleTextShare(intent: Intent) {
        val sharedText = intent.getStringExtra(Intent.EXTRA_TEXT)

        if (sharedText.isNullOrBlank()) {
            Log.e(TAG, "🔴 Shared text is null or empty")
            finish()
            return
        }

        Log.d(TAG, "🔵 Received shared text: ${sharedText.take(100)}...")

        // Extract URL from text
        // The shared text might be:
        // - Just the URL: "https://example.com"
        // - URL with title: "Page Title https://example.com"
        // - Multiple lines with URL
        val url = extractUrl(sharedText)

        if (url.isNullOrBlank()) {
            Log.e(TAG, "🔴 No URL found in shared text")
            finish()
            return
        }

        Log.d(TAG, "🟢 Extracted URL: $url")

        // Launch main app with deep link
        launchMainAppWithUrl(url)

        // Close this activity
        finish()
    }

    /**
     * Extract URL from text
     *
     * Tries to find a URL in the shared text using simple pattern matching.
     * Returns the first URL found, or the entire text if it looks like a URL.
     */
    private fun extractUrl(text: String): String? {
        // First, check if the entire text is a URL
        if (text.startsWith("http://", ignoreCase = true) ||
            text.startsWith("https://", ignoreCase = true)) {
            return text.trim()
        }

        // Otherwise, try to find a URL in the text
        val urlPattern = Regex("https?://[^\\s]+", RegexOption.IGNORE_CASE)
        val match = urlPattern.find(text)

        return match?.value
    }

    /**
     * Launch main app with shared URL via deep link
     *
     * Creates a deep link: anchor://share?url=...
     * and launches MainActivity with it.
     */
    private fun launchMainAppWithUrl(url: String) {
        try {
            // URL encode the shared URL for use in query parameter
            val encodedUrl = Uri.encode(url)

            // Create deep link
            val deepLinkUri = Uri.parse("anchor://share?url=$encodedUrl")

            Log.d(TAG, "🔵 Launching MainActivity with deep link: $deepLinkUri")

            // Create intent to launch MainActivity
            val launchIntent = Intent(this, MainActivity::class.java).apply {
                action = Intent.ACTION_VIEW
                data = deepLinkUri
                // Clear the task stack and create a new task
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TOP
            }

            startActivity(launchIntent)

            Log.d(TAG, "🟢 MainActivity launched successfully")

        } catch (e: Exception) {
            Log.e(TAG, "🔴 Error launching MainActivity: ${e.message}", e)
        }
    }
}
