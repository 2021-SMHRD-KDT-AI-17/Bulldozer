package com.example.bulldozer

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat

class KotlinForegroundService : Service() {
    private val CHANNEL_ID = "ForegroundServiceChannel"
    private val TAG = "KotlinForegroundService"
    private val handler = Handler()
    private val runnableCode: Runnable = object : Runnable {
        override fun run() {
//            Log.d(TAG, "Service is still running")
//            // 알림을 주기적으로 업데이트하는 코드를 추가할 수 있습니다.
//            updateNotification("검사가 활성화 되있습니다")
//            handler.postDelayed(this, 5000) // 5초마다 로그 출력 및 알림 업데이트
        }
    }

    override fun onCreate() {
        super.onCreate()
        createNotificationChannel()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent != null && intent.action == "START_FOREGROUND_SERVICE") {
            startForegroundServiceNotification()
        }
        // Do background work here
        Log.d(TAG, "Service is running in the background")
        handler.post(runnableCode)
        return START_NOT_STICKY
    }

    override fun onBind(intent: Intent?): IBinder? {
        Log.d(TAG, "onBind called")
        return null
    }

    override fun onDestroy() {
        handler.removeCallbacks(runnableCode)
        super.onDestroy()
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                    CHANNEL_ID,
                    "Foreground Service Channel",
                    NotificationManager.IMPORTANCE_DEFAULT
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    private fun startForegroundServiceNotification() {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("My App Service 문구 테스트")
                .setContentText("Running in the background 감시중")
                .setSmallIcon(R.drawable.ic_notification)  // 리소스 추가 필요
                .setContentIntent(pendingIntent)
                .build()

        startForeground(1, notification)
        Log.d(TAG, "startForeground called")
    }

    private fun updateNotification(contentText: String) {
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_UPDATE_CURRENT)
        val notification: Notification = NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("My App Service")
                .setContentText(contentText)
                .setSmallIcon(R.drawable.ic_notification)  // 리소스 추가 필요
                .setContentIntent(pendingIntent)
                .build()

        val notificationManager = getSystemService(NotificationManager::class.java)
        notificationManager.notify(1, notification)
    }

    private fun stopForegroundService() {
        Log.d(TAG, "Stop Foreground Service")
        stopForeground(true)
        stopSelf()
    }
}