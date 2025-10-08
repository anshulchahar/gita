package com.schepor.gita.presentation.home

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
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
import com.schepor.gita.presentation.components.KrishnaAnimation
import com.schepor.gita.presentation.components.KrishnaEmotion
import com.schepor.gita.presentation.components.KrishnaMascot
import com.schepor.gita.presentation.components.KrishnaMessages
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
    
    // Admin access via long press on menu icon (hidden feature for development)
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
                        // User stats row instead of title
                        Row(
                            modifier = Modifier.fillMaxWidth(),
                            horizontalArrangement = Arrangement.SpaceEvenly,
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            // Streak
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Text(
                                    text = "🔥",
                                    style = MaterialTheme.typography.titleMedium
                                )
                                Text(
                                    text = "${homeState.currentStreak}",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                            
                            // Gems
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Text(
                                    text = "💎",
                                    style = MaterialTheme.typography.titleMedium
                                )
                                Text(
                                    text = "${homeState.gems}",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                            
                            // Energy
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                horizontalArrangement = Arrangement.spacedBy(4.dp)
                            ) {
                                Text(
                                    text = "⚡",
                                    style = MaterialTheme.typography.titleMedium
                                )
                                Text(
                                    text = "${homeState.energy}",
                                    style = MaterialTheme.typography.titleMedium,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                        }
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
                        containerColor = MaterialTheme.colorScheme.surface,
                        titleContentColor = MaterialTheme.colorScheme.onSurface
                    )
                )
            }
        ) { paddingValues ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(paddingValues)
            ) {
                // Loading state
                if (homeState.isLoading) {
                    CircularProgressIndicator(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .padding(Spacing.space24)
                    )
                }
                
                // Error state
                homeState.error?.let { error ->
                    Column(
                        modifier = Modifier
                            .align(Alignment.Center)
                            .padding(Spacing.space16),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "⚠️",
                            style = MaterialTheme.typography.displayMedium
                        )
                        Spacer(modifier = Modifier.height(Spacing.space8))
                        Text(
                            text = error,
                            style = MaterialTheme.typography.bodyMedium,
                            color = MaterialTheme.colorScheme.error,
                            textAlign = androidx.compose.ui.text.style.TextAlign.Center
                        )
                    }
                }
                
                // Duolingo-style progression view
                if (!homeState.isLoading && homeState.error == null) {
                    if (homeState.chapters.isEmpty()) {
                        // Empty state
                        Column(
                            modifier = Modifier
                                .align(Alignment.Center)
                                .padding(Spacing.space24),
                            horizontalAlignment = Alignment.CenterHorizontally
                        ) {
                            KrishnaMascot(
                                emotion = KrishnaEmotion.NEUTRAL,
                                animation = KrishnaAnimation.IDLE_FLOAT,
                                size = 120.dp
                            )
                            Spacer(modifier = Modifier.height(Spacing.space16))
                            Text(
                                text = "No chapters available yet",
                                style = MaterialTheme.typography.titleLarge,
                                color = MaterialTheme.colorScheme.onSurface
                            )
                            Spacer(modifier = Modifier.height(Spacing.space8))
                            Text(
                                text = "Content will be available soon!",
                                style = MaterialTheme.typography.bodyMedium,
                                color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
                            )
                        }
                    } else {
                        // Main progression list
                        LazyColumn(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(horizontal = Spacing.space16),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.spacedBy(Spacing.space4)
                        ) {
                            // Welcome message at top
                            item {
                                Spacer(modifier = Modifier.height(Spacing.space8))
                                KrishnaMascot(
                                    emotion = KrishnaEmotion.HAPPY,
                                    animation = KrishnaAnimation.IDLE_FLOAT,
                                    size = 80.dp
                                )
                                Spacer(modifier = Modifier.height(Spacing.space8))
                                Text(
                                    text = KrishnaMessages.WELCOME.random(),
                                    style = MaterialTheme.typography.bodyMedium,
                                    color = MaterialTheme.colorScheme.onSurface,
                                    textAlign = androidx.compose.ui.text.style.TextAlign.Center
                                )
                                Spacer(modifier = Modifier.height(Spacing.space16))
                            }
                            
                            // Iterate through chapters and their lessons
                            homeState.chapters.forEachIndexed { chapterIndex, chapter ->
                                val isChapterUnlocked = homeState.unlockedChapters.contains(chapter.chapterId)
                                val lessons = homeState.chapterLessons[chapter.chapterId] ?: emptyList()
                                
                                // Section header for each chapter
                                item(key = "header_${chapter.chapterId}") {
                                    SectionHeader(
                                        sectionNumber = chapter.chapterNumber,
                                        unitNumber = chapter.chapterNumber,
                                        description = chapter.chapterNameEn
                                    )
                                }
                                
                                // Lessons in this chapter
                                lessons.forEachIndexed { lessonIndex, lesson ->
                                    val isUnlocked = homeState.unlockedLessons.contains(lesson.lessonId)
                                    val isCompleted = homeState.completedLessons.contains(lesson.lessonId)
                                    
                                    // Determine if this is the current lesson (first uncompleted unlocked lesson)
                                    val isCurrent = isUnlocked && !isCompleted && 
                                        lessons.take(lessonIndex).all { homeState.completedLessons.contains(it.lessonId) }
                                    
                                    // Progress path before lesson (except for first)
                                    if (lessonIndex > 0) {
                                        item(key = "path_before_${lesson.lessonId}") {
                                            ProgressPath(
                                                isUnlocked = isUnlocked,
                                                height = 32
                                            )
                                        }
                                    }
                                    
                                    // Lesson node
                                    item(key = "lesson_${lesson.lessonId}") {
                                        LessonNode(
                                            lessonNumber = lesson.lessonNumber,
                                            isUnlocked = isUnlocked,
                                            isCompleted = isCompleted,
                                            isCurrent = isCurrent,
                                            description = lesson.lessonNameEn,
                                            onClick = {
                                                onNavigateToLesson(chapter.chapterId, lesson.lessonId)
                                            }
                                        )
                                    }
                                    
                                    // Add milestone after every 3 lessons
                                    if ((lessonIndex + 1) % 3 == 0 && lessonIndex < lessons.size - 1) {
                                        item(key = "path_after_${lesson.lessonId}") {
                                            ProgressPath(
                                                isUnlocked = isUnlocked,
                                                height = 32
                                            )
                                        }
                                        item(key = "milestone_${lesson.lessonId}") {
                                            ChapterMilestone(
                                                type = when ((lessonIndex + 1) / 3 % 3) {
                                                    0 -> MilestoneType.TREASURE
                                                    1 -> MilestoneType.CHARACTER
                                                    else -> MilestoneType.KRISHNA
                                                },
                                                isUnlocked = isCompleted
                                            )
                                        }
                                    }
                                }
                                
                                // Chapter completion trophy
                                if (lessons.isNotEmpty()) {
                                    val allLessonsCompleted = lessons.all { 
                                        homeState.completedLessons.contains(it.lessonId) 
                                    }
                                    
                                    item(key = "path_chapter_end_${chapter.chapterId}") {
                                        ProgressPath(
                                            isUnlocked = allLessonsCompleted,
                                            height = 40
                                        )
                                    }
                                    
                                    item(key = "trophy_${chapter.chapterId}") {
                                        ChapterMilestone(
                                            type = MilestoneType.TROPHY,
                                            isUnlocked = allLessonsCompleted
                                        )
                                    }
                                    
                                    // Add spacing between chapters
                                    if (chapterIndex < homeState.chapters.size - 1) {
                                        item(key = "spacing_${chapter.chapterId}") {
                                            Spacer(modifier = Modifier.height(Spacing.space24))
                                        }
                                    }
                                }
                            }
                            
                            // Bottom spacing
                            item {
                                Spacer(modifier = Modifier.height(Spacing.space32))
                            }
                        }
                    }
                }
            }
        }
    }
}
