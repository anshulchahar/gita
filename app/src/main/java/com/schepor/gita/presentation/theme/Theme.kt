package com.schepor.gita.presentation.theme

import android.app.Activity
import androidx.compose.foundation.isSystemInDarkTheme
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.material3.lightColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.runtime.SideEffect
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.toArgb
import androidx.compose.ui.platform.LocalView
import androidx.core.view.WindowCompat

private val LightColorScheme = lightColorScheme(
    primary = Saffron,
    onPrimary = White,
    primaryContainer = LightSaffron,
    onPrimaryContainer = DeepPurple,
    
    secondary = DeepPurple,
    onSecondary = White,
    secondaryContainer = Color(0xFFE1BEE7),
    onSecondaryContainer = DarkPurple,
    
    tertiary = SacredGold,
    onTertiary = Gray900,
    
    error = Error,
    onError = White,
    
    background = LightBackground,
    onBackground = LightOnBackground,
    surface = LightSurface,
    onSurface = LightOnSurface,
    
    surfaceVariant = Gray100,
    onSurfaceVariant = Gray700,
    
    outline = Gray300,
    outlineVariant = Gray100
)

private val DarkColorScheme = darkColorScheme(
    primary = Saffron,
    onPrimary = Gray900,
    primaryContainer = Color(0xFFCC7A29),
    onPrimaryContainer = White,
    
    secondary = Color(0xFF9C27B0),
    onSecondary = White,
    secondaryContainer = DarkPurple,
    onSecondaryContainer = Color(0xFFE1BEE7),
    
    tertiary = SacredGold,
    onTertiary = Gray900,
    
    error = Color(0xFFCF6679),
    onError = Gray900,
    
    background = DarkBackground,
    onBackground = DarkOnBackground,
    surface = DarkSurface,
    onSurface = DarkOnSurface,
    
    surfaceVariant = Color(0xFF2C2C2C),
    onSurfaceVariant = Gray300,
    
    outline = Gray700,
    outlineVariant = Color(0xFF3C3C3C)
)

@Composable
fun GitaTheme(
    darkTheme: Boolean = isSystemInDarkTheme(),
    content: @Composable () -> Unit
) {
    val colorScheme = if (darkTheme) DarkColorScheme else LightColorScheme
    
    val view = LocalView.current
    if (!view.isInEditMode) {
        SideEffect {
            val window = (view.context as Activity).window
            window.statusBarColor = colorScheme.background.toArgb()
            WindowCompat.getInsetsController(window, view).isAppearanceLightStatusBars = !darkTheme
        }
    }

    MaterialTheme(
        colorScheme = colorScheme,
        typography = GitaTypography,
        shapes = GitaShapes,
        content = content
    )
}
