package com.example.bulldozer

import android.accessibilityservice.AccessibilityService
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.text.TextUtils
import android.util.Log
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val FOREGROUND_SERVICE_CHANNEL = "ForegroundServiceChannel"
    private val BROWSER_CHANNEL = "com.example.bulldozer/browser"
    private lateinit var methodChannel: MethodChannel
    private lateinit var receiver: UrlUpdateReceiver

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, BROWSER_CHANNEL)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, FOREGROUND_SERVICE_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startForegroundService" -> {
                    startForegroundService()
                    result.success(null)
                }
                "stopForegroundService" -> {
                    stopForegroundService()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "launchBulldozer" -> {
                    launchBulldozer()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }


        receiver = UrlUpdateReceiver()
        val filter = IntentFilter("com.example.bulldozer.URL_UPDATE")
        registerReceiver(receiver, filter)

//        // 6.13 접근성 서비스 활성화 상태 확인 후 설정 화면으로 이동
//        if (!isAccessibilityServiceEnabled(this, BrowserAccessibilityService::class.java)) {
//            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
//            startActivity(intent)
//        }
    }

    // 6.13 추가
    override fun onResume() {
        super.onResume()
        // 접근성 서비스가 활성화된 경우 설정 화면으로 이동하지 않도록 추가 확인
        if (!isAccessibilityServiceEnabled(this, BrowserAccessibilityService::class.java)) {
            val intent = Intent(Settings.ACTION_ACCESSIBILITY_SETTINGS)
            startActivity(intent)
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(receiver)
    }

    private fun startForegroundService() {
        BrowserAccessibilityService.isServiceActive = true
        val serviceIntent = Intent(this, KotlinForegroundService::class.java).apply {
            action = "START_FOREGROUND_SERVICE"
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            ContextCompat.startForegroundService(this, serviceIntent)
        } else {
            startService(serviceIntent)
        }
    }

    private fun stopForegroundService() {
        BrowserAccessibilityService.isServiceActive = false
        val serviceIntent = Intent(this, KotlinForegroundService::class.java)
        stopService(serviceIntent)
    }

    private fun isAccessibilityServiceEnabled(context: Context, service: Class<out AccessibilityService>): Boolean {
        val enabledServices = Settings.Secure.getString(context.contentResolver, Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES)
        if (enabledServices.isNullOrEmpty()) {
            return false
        }
        val colonSplitter = TextUtils.SimpleStringSplitter(':')
        colonSplitter.setString(enabledServices)
        while (colonSplitter.hasNext()) {
            val componentName = colonSplitter.next()
            // 6.13 추가
            if (componentName.equals("${context.packageName}/${service.name}", ignoreCase = true)) {
                return true
            }
        }
        return false
    }

    inner class UrlUpdateReceiver : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            if (intent != null && intent.action == "com.example.bulldozer.URL_UPDATE") {
                val url = intent.getStringExtra("url")
                Log.d("MainActivity", "BroadcastReceiver: $url")
                methodChannel.invokeMethod("updateUrl", url)
            }
        }
    }

    //6.15 추가
    private fun launchBulldozer() {
        val intent = Intent(this, BrowserAccessibilityService::class.java)
        intent.action = "LAUNCH_BULLDOZER"
        startService(intent)
    }
}
