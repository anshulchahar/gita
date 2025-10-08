package com.schepor.gita

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.schepor.gita.presentation.navigation.GitaNavigation
import com.schepor.gita.presentation.theme.GitaTheme
import dagger.hilt.android.AndroidEntryPoint

/**
 * Main Activity - Entry point of the app
 * Uses Jetpack Compose for the entire UI
 */
@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        setContent {
            GitaTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    GitaNavigation()
                }
            }
        }
    }
}
