package com.schepor.gita

import android.app.Application
import dagger.hilt.android.HiltAndroidApp

/**
 * Gita Application class with Hilt integration
 * This initializes dependency injection for the entire app
 */
@HiltAndroidApp
class GitaApplication : Application() {
    
    override fun onCreate() {
        super.onCreate()
        // Firebase and other SDKs are auto-initialized
        // Additional initialization can be added here if needed
    }
}
