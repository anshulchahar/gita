package com.schepor.gita.presentation.theme

import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp

/**
 * Spacing system for consistent layouts throughout the app
 */
object Spacing {
    val space2: Dp = 2.dp
    val space4: Dp = 4.dp
    val space8: Dp = 8.dp
    val space12: Dp = 12.dp
    val space16: Dp = 16.dp
    val space20: Dp = 20.dp
    val space24: Dp = 24.dp
    val space32: Dp = 32.dp
    val space40: Dp = 40.dp
    val space48: Dp = 48.dp
    val space64: Dp = 64.dp
}

/**
 * Elevation levels for Material Design
 */
object Elevation {
    val level0: Dp = 0.dp
    val level1: Dp = 2.dp  // Cards at rest
    val level2: Dp = 4.dp  // Raised cards
    val level3: Dp = 8.dp  // Modal sheets
    val level4: Dp = 16.dp // Navigation drawer
    val level5: Dp = 24.dp // Dialogs
}

/**
 * Animation durations in milliseconds
 */
object AnimationDurations {
    const val Fast = 150
    const val Normal = 300
    const val Slow = 500
}
