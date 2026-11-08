package com.zizai.zizai

import android.app.NotificationChannel
import android.app.NotificationManager
import android.content.Context
import android.os.Build
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Ensure R.drawable.ic_notification is retained by R8 resource optimizer
        val _keepIcon = R.drawable.ic_notification
        createLocationNotificationChannel()
    }

    override fun onResume() {
        super.onResume()
        createLocationNotificationChannel()
    }

    private fun createLocationNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channelId = "geolocator_channel_01"
            val channelName = "ZizAI Salida GPS"
            val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as? NotificationManager
                ?: return

            val existingChannel = notificationManager.getNotificationChannel(channelId)
            // If the channel does not exist or was created with IMPORTANCE_NONE (< IMPORTANCE_LOW)
            if (existingChannel != null && existingChannel.importance < NotificationManager.IMPORTANCE_LOW) {
                notificationManager.deleteNotificationChannel(channelId)
            }

            if (notificationManager.getNotificationChannel(channelId) == null) {
                val channel = NotificationChannel(
                    channelId,
                    channelName,
                    NotificationManager.IMPORTANCE_LOW
                ).apply {
                    description = "Notificación persistente de seguimiento de ruta GPS en el monte"
                    setShowBadge(true)
                }
                notificationManager.createNotificationChannel(channel)
            }
        }
    }
}

