package com.example.bulldozer

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo

class BrowserAccessibilityService : AccessibilityService() {

    companion object{
        var isServiceActive: Boolean = false
    }

    override fun onServiceConnected() {
        super.onServiceConnected() // 부모 클래스의 메서드 호출
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                    AccessibilityEvent.TYPE_VIEW_CLICKED or
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_GENERIC
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            packageNames = arrayOf("com.android.chrome", "org.mozilla.firefox", "com.microsoft.emmx")
        }
        serviceInfo = info
    }


    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isServiceActive) return

        if (event != null) {
            val source = event.source ?: return

            if (event.packageName == "com.android.chrome") {
                val urlNode = findUrlBarNode(source)
                if (urlNode != null) {
                    val url = urlNode.text?.toString() ?: "Unknown"
                    sendUrlToApp(url)
                }
            }
        }
    }

    private fun findUrlBarNode(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
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
    }

    private fun sendUrlToApp(url: String) {
        val intent = Intent("com.example.bulldozer.URL_UPDATE")
        intent.putExtra("url", url)
        sendBroadcast(intent)
        Log.d("BrowserAccessibilityService", "Broadcast sent with URL: $url")
    }
}