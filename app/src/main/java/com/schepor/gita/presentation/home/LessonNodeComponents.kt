package com.schepor.gita.presentation.home

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.schepor.gita.presentation.theme.Spacing

/**
 * Section Header - Displays "SECTION X, UNIT Y" style header
 */
@Composable
fun SectionHeader(
    sectionNumber: Int,
    unitNumber: Int,
    description: String,
    modifier: Modifier = Modifier
) {
    Card(
        modifier = modifier
            .fillMaxWidth()
            .padding(vertical = Spacing.space8),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(Spacing.space16)
        ) {
            Text(
                text = "SECTION $sectionNumber, UNIT $unitNumber",
                style = MaterialTheme.typography.labelLarge,
                fontWeight = FontWeight.Bold,
                color = MaterialTheme.colorScheme.primary
            )
            Spacer(modifier = Modifier.height(Spacing.space4))
            Text(
                text = description,
                style = MaterialTheme.typography.titleMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer
            )
        }
    }
}

/**
 * Lesson Node - Circular button representing a lesson
 */
@Composable
fun LessonNode(
    lessonNumber: Int,
    isUnlocked: Boolean,
    isCompleted: Boolean,
    isCurrent: Boolean,
    description: String = "",
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // The circular lesson button
        Box(
            modifier = Modifier
                .size(if (isCurrent) 80.dp else 64.dp)
                .shadow(
                    elevation = if (isCurrent) 8.dp else 0.dp,
                    shape = CircleShape
                )
                .background(
                    color = when {
                        !isUnlocked -> MaterialTheme.colorScheme.surfaceVariant
                        isCurrent -> Color(0xFF66BB6A) // Bright green for current
                        isCompleted -> Color(0xFF4CAF50) // Green for completed
                        else -> Color(0xFF4CAF50) // Green for unlocked
                    },
                    shape = CircleShape
                )
                .border(
                    width = if (isCurrent) 4.dp else 0.dp,
                    color = if (isCurrent) Color(0xFF81C784) else Color.Transparent,
                    shape = CircleShape
                )
                .clickable(enabled = isUnlocked, onClick = onClick),
            contentAlignment = Alignment.Center
        ) {
            when {
                !isUnlocked -> {
                    Icon(
                        imageVector = Icons.Default.Lock,
                        contentDescription = "Locked",
                        tint = MaterialTheme.colorScheme.onSurfaceVariant,
                        modifier = Modifier.size(32.dp)
                    )
                }
                isCompleted -> {
                    Icon(
                        imageVector = Icons.Default.Star,
                        contentDescription = "Completed",
                        tint = Color.White,
                        modifier = Modifier.size(40.dp)
                    )
                }
                else -> {
                    Icon(
                        imageVector = Icons.Default.Star,
                        contentDescription = "Available",
                        tint = Color.White.copy(alpha = 0.5f),
                        modifier = Modifier.size(40.dp)
                    )
                }
            }
        }
        
        // Description text below the node
        if (description.isNotEmpty()) {
            Spacer(modifier = Modifier.height(Spacing.space8))
            Text(
                text = description,
                style = MaterialTheme.typography.bodyMedium,
                color = if (isUnlocked) 
                    MaterialTheme.colorScheme.onSurface 
                else 
                    MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.6f),
                textAlign = TextAlign.Center,
                modifier = Modifier.widthIn(max = 120.dp)
            )
        }
    }
}

/**
 * Progress Path - Vertical line connecting lesson nodes
 */
@Composable
fun ProgressPath(
    isUnlocked: Boolean,
    height: Int = 40,
    modifier: Modifier = Modifier
) {
    Canvas(
        modifier = modifier
            .width(4.dp)
            .height(height.dp)
    ) {
        drawLine(
            color = if (isUnlocked) Color(0xFFE0E0E0) else Color(0xFFE0E0E0).copy(alpha = 0.3f),
            start = Offset(size.width / 2, 0f),
            end = Offset(size.width / 2, size.height),
            strokeWidth = size.width
        )
    }
}

/**
 * Chapter Milestone - Special markers like treasure chests, characters, trophies
 */
@Composable
fun ChapterMilestone(
    type: MilestoneType,
    isUnlocked: Boolean,
    onClick: (() -> Unit)? = null,
    modifier: Modifier = Modifier
) {
    Box(
        modifier = modifier
            .size(72.dp)
            .background(
                color = if (isUnlocked) 
                    MaterialTheme.colorScheme.tertiaryContainer 
                else 
                    MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
                shape = CircleShape
            )
            .then(
                if (onClick != null && isUnlocked) {
                    Modifier.clickable(onClick = onClick)
                } else {
                    Modifier
                }
            ),
        contentAlignment = Alignment.Center
    ) {
        Text(
            text = when (type) {
                MilestoneType.TREASURE -> "🎁"
                MilestoneType.CHARACTER -> "🦜"
                MilestoneType.TROPHY -> "🏆"
                MilestoneType.KRISHNA -> "🪷"
            },
            style = MaterialTheme.typography.displaySmall,
            modifier = Modifier.size(48.dp)
        )
    }
}

/**
 * Types of milestones that can appear in the progression
 */
enum class MilestoneType {
    TREASURE,   // Completion rewards
    CHARACTER,  // Krishna mascot checkpoints
    TROPHY,     // Chapter completion
    KRISHNA     // Special Krishna wisdom points
}
