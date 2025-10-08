package com.schepor.gita.presentation.home

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import com.schepor.gita.presentation.theme.Spacing

/**
 * Home Screen - Wisdom Tree
 * Displays chapters and lessons in a tree-like structure
 */
@Composable
fun HomeScreen(
    onNavigateToLesson: (String, String) -> Unit,
    onNavigateToAdmin: () -> Unit = {},
    viewModel: HomeViewModel = hiltViewModel()
) {
    val homeState by viewModel.homeState.collectAsState()
    
    // Admin access via long press on title (hidden feature for development)
    var clickCount by remember { mutableStateOf(0) }
    
    LaunchedEffect(clickCount) {
        if (clickCount >= 5) {
            onNavigateToAdmin()
            clickCount = 0
        }
    }
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(Spacing.space24),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        // Header
        Text(
            text = "Wisdom Tree",
            style = MaterialTheme.typography.displayMedium,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.clickable(
                indication = null,
                interactionSource = remember { MutableInteractionSource() }
            ) {
                clickCount++
            }
        )
        
        Spacer(modifier = Modifier.height(Spacing.space32))
        
        // Loading state
        if (homeState.isLoading) {
            CircularProgressIndicator(
                modifier = Modifier.padding(Spacing.space24)
            )
        }
        
        // Error state
        homeState.error?.let { error ->
            Text(
                text = error,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.error,
                modifier = Modifier.padding(Spacing.space16)
            )
        }
        
        // Chapters list
        if (homeState.chapters.isEmpty() && !homeState.isLoading) {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(Spacing.space16),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                Text(
                    text = "No chapters available yet.",
                    style = MaterialTheme.typography.titleMedium,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Spacer(modifier = Modifier.height(Spacing.space8))
                Text(
                    text = "Content will be available soon!",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                )
                Spacer(modifier = Modifier.height(Spacing.space16))
                Text(
                    text = "💡 Developer tip: Tap the title 5 times to access admin panel",
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.primary.copy(alpha = 0.5f)
                )
            }
        } else {
            LazyColumn(
                modifier = Modifier.fillMaxWidth(),
                verticalArrangement = Arrangement.spacedBy(Spacing.space12)
            ) {
                items(homeState.chapters) { chapter ->
                    ChapterCard(
                        chapter = chapter,
                        onClick = {
                            // Navigate to first lesson of this chapter
                            // For now, using placeholder IDs
                            onNavigateToLesson(chapter.chapterId, "lesson_1")
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun ChapterCard(
    chapter: com.schepor.gita.domain.model.Chapter,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick),
        colors = CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    ) {
        Column(
            modifier = Modifier.padding(Spacing.space16)
        ) {
            Text(
                text = "Chapter ${chapter.chapterNumber}",
                style = MaterialTheme.typography.labelMedium,
                color = MaterialTheme.colorScheme.primary
            )
            Spacer(modifier = Modifier.height(Spacing.space4))
            Text(
                text = chapter.chapterNameEn,
                style = MaterialTheme.typography.headlineSmall
            )
            Spacer(modifier = Modifier.height(Spacing.space4))
            Text(
                text = chapter.chapterName,
                style = MaterialTheme.typography.bodyLarge,
                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
            )
            Spacer(modifier = Modifier.height(Spacing.space8))
            Text(
                text = chapter.descriptionEn,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
            )
            Spacer(modifier = Modifier.height(Spacing.space8))
            Text(
                text = "${chapter.shlokaCount} verses",
                style = MaterialTheme.typography.labelSmall,
                color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.6f)
            )
        }
    }
}
