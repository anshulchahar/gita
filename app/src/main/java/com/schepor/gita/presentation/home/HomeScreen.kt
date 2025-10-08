package com.schepor.gita.presentation.home

import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.schepor.gita.presentation.auth.AuthViewModel
import com.schepor.gita.presentation.theme.Spacing
import kotlinx.coroutines.launch

/**
 * Home Screen - Wisdom Tree
 * Displays chapters and lessons in a tree-like structure
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigateToLesson: (String, String) -> Unit,
    onNavigateToAdmin: () -> Unit = {},
    onNavigateToLogin: () -> Unit = {},
    viewModel: HomeViewModel = hiltViewModel(),
    authViewModel: AuthViewModel = hiltViewModel()
) {
    val homeState by viewModel.homeState.collectAsState()
    val authState by authViewModel.authState.collectAsState()
    val drawerState = rememberDrawerState(initialValue = DrawerValue.Closed)
    val scope = rememberCoroutineScope()
    
    // Admin access via long press on title (hidden feature for development)
    var clickCount by remember { mutableStateOf(0) }
    
    LaunchedEffect(clickCount) {
        if (clickCount >= 5) {
            onNavigateToAdmin()
            clickCount = 0
        }
    }
    
    // Navigate to login when logged out
    LaunchedEffect(authState.user) {
        if (authState.user == null && !authState.isLoading) {
            onNavigateToLogin()
        }
    }
    
    ModalNavigationDrawer(
        drawerState = drawerState,
        drawerContent = {
            ModalDrawerSheet(
                modifier = Modifier.width(280.dp)
            ) {
                Spacer(modifier = Modifier.height(Spacing.space16))
                
                // User Profile Section
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(Spacing.space16)
                ) {
                    Icon(
                        imageVector = Icons.Default.Person,
                        contentDescription = "Profile",
                        modifier = Modifier.size(64.dp),
                        tint = MaterialTheme.colorScheme.primary
                    )
                    Spacer(modifier = Modifier.height(Spacing.space8))
                    Text(
                        text = authState.user?.email ?: "Guest",
                        style = MaterialTheme.typography.titleMedium,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Spacer(modifier = Modifier.height(Spacing.space4))
                    Text(
                        text = "Seeker of Wisdom",
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                    )
                }
                
                HorizontalDivider(modifier = Modifier.padding(vertical = Spacing.space8))
                
                // Logout Option
                NavigationDrawerItem(
                    icon = {
                        Icon(
                            imageVector = Icons.Default.ExitToApp,
                            contentDescription = "Logout"
                        )
                    },
                    label = { Text("Logout") },
                    selected = false,
                    onClick = {
                        scope.launch {
                            drawerState.close()
                            authViewModel.signOut()
                        }
                    },
                    modifier = Modifier.padding(horizontal = Spacing.space12)
                )
            }
        }
    ) {
        Scaffold(
            topBar = {
                TopAppBar(
                    title = { 
                        Text(
                            text = "Wisdom Tree",
                            modifier = Modifier.clickable(
                                indication = null,
                                interactionSource = remember { MutableInteractionSource() }
                            ) {
                                clickCount++
                            }
                        )
                    },
                    navigationIcon = {
                        IconButton(onClick = { 
                            scope.launch { 
                                drawerState.open() 
                            } 
                        }) {
                            Icon(
                                imageVector = Icons.Default.Menu,
                                contentDescription = "Menu"
                            )
                        }
                    },
                    colors = TopAppBarDefaults.topAppBarColors(
                        containerColor = MaterialTheme.colorScheme.primaryContainer,
                        titleContentColor = MaterialTheme.colorScheme.primary
                    )
                )
            }
        ) { paddingValues ->
            Column(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
                    .padding(horizontal = Spacing.space24)
                    .padding(top = Spacing.space16),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
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
                                    val firstLessonId = homeState.chapterFirstLessons[chapter.chapterId]
                                    if (firstLessonId != null) {
                                        onNavigateToLesson(chapter.chapterId, firstLessonId)
                                    }
                                }
                            )
                        }
                    }
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
