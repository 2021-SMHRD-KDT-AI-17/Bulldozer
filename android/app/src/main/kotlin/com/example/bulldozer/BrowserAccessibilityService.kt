package com.example.bulldozer
import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class BrowserAccessibilityService : AccessibilityService()   {
    override fun onServiceConnected() {
        val info = AccessibilityServiceInfo()
        info.eventTypes = AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or AccessibilityEvent.TYPE_VIEW_CLICKED or AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
        info.feedbackType = AccessibilityServiceInfo.FEEDBACK_SPOKEN
        info.flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
        info.packageNames = arrayOf("com.android.chrome", "org.mozilla.firefox", "com.microsoft.emmx")
        serviceInfo = info
        Log.d("BrowserAccessibilityService", "Service connected")
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (event != null) {
            val source = event.source ?: return
            Log.d("BrowserAccessibilityService", "Event source class: ${source.className}")
            Log.d("BrowserAccessibilityService", "Event type: ${AccessibilityEvent.eventTypeToString(event.eventType)}")
            Log.d("BrowserAccessibilityService", "Package name: ${event.packageName}")

            if (event.packageName == "com.android.chrome") {
                val urlNode = findUrlBarNode(source)
                if (urlNode != null) {
                    val url = urlNode.text?.toString() ?: "Unknown"
                    Log.d("BrowserAccessibilityService", "URL: $url")
                    sendUrlToApp(url)
                } else {
                    Log.d("BrowserAccessibilityService", "URL bar not found")
                }
            }
        }
    }

    private fun findUrlBarNode(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        Log.d("BrowserAccessibilityService", "Checking node: ${node.className}, ${node.viewIdResourceName}")
        if (node.className == "android.widget.EditText" && node.viewIdResourceName == "com.android.chrome:id/url_bar") {
            return node
        }
        for (i in 0 until node.childCount) {
            node.getChild(i)?.let { childNode ->
                val result = findUrlBarNode(childNode)
                if (result != null) {
                    return result
                }
            }
        }
        return null
    }

    override fun onInterrupt() {
        Log.d("BrowserAccessibilityService", "Service interrupted")
    }

    private fun sendUrlToApp(url: String) {
        val intent = Intent("com.example.bulldozer.URL_UPDATE")
        intent.putExtra("url", url)
        sendBroadcast(intent)
        Log.d("BrowserAccessibilityService", "Broadcast sent with URL: $url")
    }
}