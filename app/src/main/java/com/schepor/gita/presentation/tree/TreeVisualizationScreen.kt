package com.schepor.gita.presentation.tree

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.gestures.detectTransformGestures
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.PathEffect
import androidx.compose.ui.graphics.drawscope.Stroke
import androidx.compose.ui.graphics.graphicsLayer
import androidx.compose.ui.input.pointer.pointerInput
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import com.schepor.gita.domain.model.Chapter
import com.schepor.gita.presentation.theme.Spacing

/**
 * Tree Visualization Screen - Wisdom Tree
 * Displays chapters as connected nodes in a tree structure
 */
@Composable
fun TreeVisualizationScreen(
    chapters: List<Chapter>,
    unlockedChapters: Set<String>,
    chapterProgress: Map<String, Int>, // chapterId to progress percentage
    onChapterClick: (Chapter) -> Unit,
    modifier: Modifier = Modifier
) {
    var scale by remember { mutableStateOf(1f) }
    var offsetX by remember { mutableStateOf(0f) }
    var offsetY by remember { mutableStateOf(0f) }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(MaterialTheme.colorScheme.background)
            .pointerInput(Unit) {
                detectTransformGestures { _, pan, zoom, _ ->
                    scale = (scale * zoom).coerceIn(0.5f, 3f)
                    offsetX += pan.x
                    offsetY += pan.y
                }
            }
    ) {
        // Tree visualization
        WisdomTreeCanvas(
            chapters = chapters,
            unlockedChapters = unlockedChapters,
            chapterProgress = chapterProgress,
            scale = scale,
            offsetX = offsetX,
            offsetY = offsetY,
            onChapterClick = onChapterClick
        )

        // Zoom controls
        Column(
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(Spacing.space16),
            verticalArrangement = Arrangement.spacedBy(Spacing.space8)
        ) {
            SmallFloatingActionButton(
                onClick = { scale = (scale + 0.2f).coerceAtMost(3f) },
                containerColor = MaterialTheme.colorScheme.primaryContainer
            ) {
                Text("+", style = MaterialTheme.typography.titleLarge)
            }
            SmallFloatingActionButton(
                onClick = { scale = (scale - 0.2f).coerceAtLeast(0.5f) },
                containerColor = MaterialTheme.colorScheme.primaryContainer
            ) {
                Text("−", style = MaterialTheme.typography.titleLarge)
            }
            SmallFloatingActionButton(
                onClick = {
                    scale = 1f
                    offsetX = 0f
                    offsetY = 0f
                },
                containerColor = MaterialTheme.colorScheme.secondaryContainer
            ) {
                Text("⟲", style = MaterialTheme.typography.titleMedium)
            }
        }
    }
}

@Composable
fun WisdomTreeCanvas(
    chapters: List<Chapter>,
    unlockedChapters: Set<String>,
    chapterProgress: Map<String, Int>,
    scale: Float,
    offsetX: Float,
    offsetY: Float,
    onChapterClick: (Chapter) -> Unit
) {
    BoxWithConstraints(modifier = Modifier.fillMaxSize()) {
        val screenWidth = constraints.maxWidth.toFloat()
        val screenHeight = constraints.maxHeight.toFloat()
        
        // Calculate node positions
        val nodePositions = remember(chapters.size) {
            calculateNodePositions(chapters.size, screenWidth, screenHeight)
        }

        // Draw connection lines
        Canvas(
            modifier = Modifier
                .fillMaxSize()
                .graphicsLayer(
                    scaleX = scale,
                    scaleY = scale,
                    translationX = offsetX,
                    translationY = offsetY
                )
        ) {
            // Draw lines connecting nodes
            for (i in 0 until chapters.size - 1) {
                val start = nodePositions[i]
                val end = nodePositions[i + 1]
                
                val isUnlocked = unlockedChapters.contains(chapters[i + 1].chapterId)
                val lineColor = if (isUnlocked) {
                    Color(0xFFFF9933) // Saffron for unlocked
                } else {
                    Color.Gray.copy(alpha = 0.3f)
                }
                
                val pathEffect = if (!isUnlocked) {
                    PathEffect.dashPathEffect(floatArrayOf(10f, 10f), 0f)
                } else null
                
                drawLine(
                    color = lineColor,
                    start = start,
                    end = end,
                    strokeWidth = 4.dp.toPx(),
                    pathEffect = pathEffect
                )
            }
        }

        // Draw chapter nodes
        chapters.forEachIndexed { index, chapter ->
            val position = nodePositions[index]
            val isUnlocked = unlockedChapters.contains(chapter.chapterId)
            val progress = chapterProgress[chapter.chapterId] ?: 0

            ChapterNode(
                chapter = chapter,
                isUnlocked = isUnlocked,
                progress = progress,
                position = position,
                scale = scale,
                offsetX = offsetX,
                offsetY = offsetY,
                onClick = { if (isUnlocked) onChapterClick(chapter) }
            )
        }
    }
}

@Composable
fun ChapterNode(
    chapter: Chapter,
    isUnlocked: Boolean,
    progress: Int,
    position: Offset,
    scale: Float,
    offsetX: Float,
    offsetY: Float,
    onClick: () -> Unit
) {
    Box(
        modifier = Modifier
            .offset(
                x = ((position.x * scale) + offsetX).dp,
                y = ((position.y * scale) + offsetY).dp
            )
            .size(120.dp)
    ) {
        // Progress ring
        CircularProgressIndicator(
            progress = progress / 100f,
            modifier = Modifier
                .size(120.dp)
                .align(Alignment.Center),
            color = if (isUnlocked) MaterialTheme.colorScheme.primary else Color.Gray,
            strokeWidth = 4.dp
        )

        // Chapter node
        Card(
            modifier = Modifier
                .size(100.dp)
                .align(Alignment.Center)
                .clickable(enabled = isUnlocked, onClick = onClick),
            colors = CardDefaults.cardColors(
                containerColor = if (isUnlocked) 
                    MaterialTheme.colorScheme.primaryContainer 
                else 
                    MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
            )
        ) {
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(Spacing.space8),
                horizontalAlignment = Alignment.CenterHorizontally,
                verticalArrangement = Arrangement.Center
            ) {
                if (!isUnlocked) {
                    Icon(
                        imageVector = Icons.Default.Lock,
                        contentDescription = "Locked",
                        modifier = Modifier.size(32.dp),
                        tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                    )
                } else {
                    Text(
                        text = chapter.icon,
                        style = MaterialTheme.typography.headlineLarge
                    )
                }
                
                Spacer(modifier = Modifier.height(Spacing.space4))
                
                Text(
                    text = "Ch. ${chapter.chapterNumber}",
                    style = MaterialTheme.typography.labelMedium,
                    textAlign = TextAlign.Center,
                    color = if (isUnlocked)
                        MaterialTheme.colorScheme.primary
                    else
                        MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                )
                
                if (progress > 0) {
                    Text(
                        text = "$progress%",
                        style = MaterialTheme.typography.bodySmall,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.primary
                    )
                }
            }
        }
    }
}

/**
 * Calculate positions for nodes in a vertical tree layout
 */
private fun calculateNodePositions(
    nodeCount: Int,
    screenWidth: Float,
    screenHeight: Float
): List<Offset> {
    val positions = mutableListOf<Offset>()
    val centerX = screenWidth / 2
    val verticalSpacing = screenHeight / (nodeCount + 1)
    
    // Simple vertical layout for now
    for (i in 0 until nodeCount) {
        val y = verticalSpacing * (i + 1)
        // Alternate left and right slightly for visual interest
        val xOffset = if (i % 2 == 0) -50f else 50f
        positions.add(Offset(centerX + xOffset, y))
    }
    
    return positions
}
