package com.schepor.gita.presentation.home

import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.interaction.MutableInteractionSource
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Menu
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ViewList
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
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.schepor.gita.R
import com.schepor.gita.presentation.auth.AuthViewModel
import com.schepor.gita.presentation.components.KrishnaAnimation
import com.schepor.gita.presentation.components.KrishnaEmotion
import com.schepor.gita.presentation.components.KrishnaMascot
import com.schepor.gita.presentation.components.KrishnaMessages
import com.schepor.gita.presentation.theme.Spacing
import com.schepor.gita.presentation.tree.TreeVisualizationScreen
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
    var showTreeView by remember { mutableStateOf(true) } // Default to tree view
    
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
                    actions = {
                        IconButton(onClick = { showTreeView = !showTreeView }) {
                            Icon(
                                imageVector = if (showTreeView) Icons.Default.ViewList else Icons.Default.Menu,
                                contentDescription = if (showTreeView) "Switch to List View" else "Switch to Tree View"
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
                // Krishna Mascot Welcome
                Column(
                    horizontalAlignment = Alignment.CenterHorizontally,
                    modifier = Modifier.fillMaxWidth()
                ) {
                    KrishnaMascot(
                        emotion = KrishnaEmotion.NEUTRAL,
                        animation = KrishnaAnimation.IDLE_FLOAT,
                        size = 100.dp
                    )
                    Spacer(modifier = Modifier.height(Spacing.space12))
                    Text(
                        text = KrishnaMessages.WELCOME.random(),
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                }
                
                Spacer(modifier = Modifier.height(Spacing.space16))
                
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
                
                // Chapters list or tree view
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
                } else if (showTreeView) {
                    // Tree visualization view
                    TreeVisualizationScreen(
                        chapters = homeState.chapters,
                        unlockedChapters = homeState.unlockedChapters,
                        chapterProgress = emptyMap(), // TODO: Calculate from user progress
                        onChapterClick = { chapter ->
                            val firstLessonId = homeState.chapterFirstLessons[chapter.chapterId]
                            val isUnlocked = homeState.unlockedChapters.contains(chapter.chapterId)
                            val isFirstLessonUnlocked = firstLessonId?.let { 
                                homeState.unlockedLessons.contains(it)
                            } ?: false
                            
                            if (isUnlocked && isFirstLessonUnlocked && firstLessonId != null) {
                                onNavigateToLesson(chapter.chapterId, firstLessonId)
                            }
                        },
                        modifier = Modifier.weight(1f)
                    )
                } else {
                    // List view
                    LazyColumn(
                        modifier = Modifier.fillMaxWidth(),
                        verticalArrangement = Arrangement.spacedBy(Spacing.space12)
                    ) {
                        items(homeState.chapters) { chapter ->
                            val isUnlocked = homeState.unlockedChapters.contains(chapter.chapterId)
                            val firstLessonId = homeState.chapterFirstLessons[chapter.chapterId]
                            val isFirstLessonUnlocked = firstLessonId?.let { 
                                homeState.unlockedLessons.contains(it)
                            } ?: false
                            
                            ChapterCard(
                                chapter = chapter,
                                isUnlocked = isUnlocked && isFirstLessonUnlocked,
                                onClick = {
                                    // Navigate to first lesson of this chapter only if unlocked
                                    if (isUnlocked && isFirstLessonUnlocked && firstLessonId != null) {
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
    isUnlocked: Boolean,
    onClick: () -> Unit
) {
    val cardColors = if (isUnlocked) {
        CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.primaryContainer
        )
    } else {
        CardDefaults.cardColors(
            containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f)
        )
    }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(enabled = isUnlocked, onClick = onClick),
        colors = cardColors
    ) {
        Row(
            modifier = Modifier.padding(Spacing.space16),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.Top
        ) {
            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = "Chapter ${chapter.chapterNumber}",
                    style = MaterialTheme.typography.labelMedium,
                    color = if (isUnlocked) 
                        MaterialTheme.colorScheme.primary 
                    else 
                        MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                )
                Spacer(modifier = Modifier.height(Spacing.space4))
                Text(
                    text = chapter.chapterNameEn,
                    style = MaterialTheme.typography.headlineSmall,
                    color = if (isUnlocked)
                        MaterialTheme.colorScheme.onPrimaryContainer
                    else
                        MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f)
                )
                Spacer(modifier = Modifier.height(Spacing.space4))
                Text(
                    text = chapter.chapterName,
                    style = MaterialTheme.typography.bodyLarge,
                    color = if (isUnlocked)
                        MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.8f)
                    else
                        MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                )
                Spacer(modifier = Modifier.height(Spacing.space8))
                Text(
                    text = chapter.descriptionEn,
                    style = MaterialTheme.typography.bodyMedium,
                    color = if (isUnlocked)
                        MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.7f)
                    else
                        MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                )
                Spacer(modifier = Modifier.height(Spacing.space8))
                Text(
                    text = "${chapter.shlokaCount} verses",
                    style = MaterialTheme.typography.labelSmall,
                    color = if (isUnlocked)
                        MaterialTheme.colorScheme.onPrimaryContainer.copy(alpha = 0.6f)
                    else
                        MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f)
                )
            }
            
            if (!isUnlocked) {
                Icon(
                    imageVector = Icons.Default.Lock,
                    contentDescription = "Locked",
                    tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                    modifier = Modifier.size(32.dp)
                )
            }
        }
    }
}
