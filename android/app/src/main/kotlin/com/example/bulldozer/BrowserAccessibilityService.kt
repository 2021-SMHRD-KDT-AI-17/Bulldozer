package com.example.bulldozer

import android.accessibilityservice.AccessibilityService
import android.accessibilityservice.AccessibilityServiceInfo
import android.content.Intent
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.os.Handler
import android.os.Looper

class BrowserAccessibilityService : AccessibilityService() {

    companion object {
        var isServiceActive: Boolean = false
        private var lastSentUrl: String? = null
        private var isActionInProgress: Boolean = false
    }

    override fun onServiceConnected() {
        super.onServiceConnected()
        val info = AccessibilityServiceInfo().apply {
            eventTypes = AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED or
                    AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED
            feedbackType = AccessibilityServiceInfo.FEEDBACK_VISUAL
            flags = AccessibilityServiceInfo.FLAG_REPORT_VIEW_IDS
            packageNames = arrayOf("com.android.chrome", "org.mozilla.firefox", "com.microsoft.emmx")
        }
        serviceInfo = info
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        if (!isServiceActive) return

        val supportedBrowsers = arrayOf("com.android.chrome", "org.mozilla.firefox", "com.microsoft.emmx")

        if (event != null) {
            val source = event.source ?: return

            if (supportedBrowsers.contains(event.packageName)) {
                val urlNode = findUrlBarNode(source)
                if (urlNode != null) {
                    val url = urlNode.text?.toString() ?: "Unknown"
                    if (url != lastSentUrl && !isEditingUrlField(urlNode)) {
                        lastSentUrl = url
                        sendUrlToApp(url)
                    }
                }
            }
        }
    }

    private fun findUrlBarNode(node: AccessibilityNodeInfo): AccessibilityNodeInfo? {
        if (node.className == "android.widget.EditText" &&
                (node.viewIdResourceName == "com.android.chrome:id/url_bar" ||
                        node.viewIdResourceName == "org.mozilla.firefox:id/url_bar" ||
                        node.viewIdResourceName == "com.microsoft.emmx:id/url_bar")) {
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

    private fun isEditingUrlField(nodeInfo: AccessibilityNodeInfo): Boolean {
        return nodeInfo.isFocused
    }


    //6.15 추가
    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == "LAUNCH_BULLDOZER") {
            closeChromeAndLaunchBulldozer()
        }
        return super.onStartCommand(intent, flags, startId)
    }

    private fun closeChromeAndLaunchBulldozer() {
        //6.13 추가
        isActionInProgress = true
        val handler = Handler(Looper.getMainLooper())

        // Chrome 종료 시도
        performGlobalAction(GLOBAL_ACTION_BACK) // 뒤로 가기 액션 수행

        // 홈으로 가기 액션 수행
        handler.postDelayed({
            performGlobalAction(GLOBAL_ACTION_HOME)
        }, 300) // 딜레이

        // Bulldozer 앱 실행
        handler.postDelayed({
            val launchIntent = packageManager.getLaunchIntentForPackage("com.bulldozer.stop")
            if (launchIntent != null) {
                launchIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                startActivity(launchIntent)
            } else {
                Log.e("BrowserAccessibilityService", "Bulldozer 앱을 찾을 수 없습니다.")
            }
            isActionInProgress = false
        }, 600) // 딜레이
    }

    private fun sendUrlToApp(url: String) {
        val intent = Intent("com.example.bulldozer.URL_UPDATE")
        intent.putExtra("url", url)
        sendBroadcast(intent)
    }
    override fun onInterrupt() {
        // 접근성 서비스 중지시
    }
}
