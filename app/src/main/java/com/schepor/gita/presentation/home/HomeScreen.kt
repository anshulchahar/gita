package com.schepor.gita.presentation.home

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import com.schepor.gita.presentation.theme.Spacing

/**
 * Home Screen - Wisdom Tree
 * Displays chapters and lessons in a tree-like structure
 */
@Composable
fun HomeScreen(
    onNavigateToLesson: (String, String) -> Unit
) {
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
            color = MaterialTheme.colorScheme.primary
        )
        
        Spacer(modifier = Modifier.height(Spacing.space32))
        
        // Placeholder content
        Card(
            modifier = Modifier.fillMaxWidth(),
            colors = CardDefaults.cardColors(
                containerColor = MaterialTheme.colorScheme.primaryContainer
            )
        ) {
            Column(
                modifier = Modifier.padding(Spacing.space16)
            ) {
                Text(
                    text = "Chapter 1",
                    style = MaterialTheme.typography.headlineMedium
                )
                Spacer(modifier = Modifier.height(Spacing.space8))
                Text(
                    text = "अर्जुन विषाद योग",
                    style = MaterialTheme.typography.bodyLarge
                )
                Spacer(modifier = Modifier.height(Spacing.space8))
                Text(
                    text = "Arjuna's Dilemma",
                    style = MaterialTheme.typography.bodyMedium,
                    color = MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                )
            }
        }
        
        Spacer(modifier = Modifier.height(Spacing.space16))
        
        Button(
            onClick = { onNavigateToLesson("chapter_1", "lesson_1") },
            modifier = Modifier.fillMaxWidth()
        ) {
            Text("Start Lesson 1")
        }
    }
}
