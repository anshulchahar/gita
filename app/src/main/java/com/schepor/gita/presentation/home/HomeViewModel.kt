package com.schepor.gita.presentation.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.firebase.auth.FirebaseAuth
import com.schepor.gita.data.repository.ContentRepository
import com.schepor.gita.data.repository.UserRepository
import com.schepor.gita.domain.model.Chapter
import com.schepor.gita.util.Resource
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeState(
    val isLoading: Boolean = false,
    val chapters: List<Chapter> = emptyList(),
    val chapterLessons: Map<String, List<com.schepor.gita.domain.model.Lesson>> = emptyMap(), // chapterId to lessons
    val chapterFirstLessons: Map<String, String> = emptyMap(), // chapterId to first lessonId
    val unlockedChapters: Set<String> = emptySet(), // Set of unlocked chapter IDs
    val unlockedLessons: Set<String> = emptySet(), // Set of unlocked lesson IDs
    val completedLessons: Set<String> = emptySet(), // Set of completed lesson IDs
    val error: String? = null,
    // User stats for header
    val wisdomPoints: Int = 0,
    val gems: Int = 0,
    val energy: Int = 5,
    val maxEnergy: Int = 5,
    val currentStreak: Int = 0
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val contentRepository: ContentRepository,
    private val userRepository: UserRepository
) : ViewModel() {

    private val _homeState = MutableStateFlow(HomeState())
    val homeState: StateFlow<HomeState> = _homeState.asStateFlow()

    init {
        loadChapters()
        loadUserStats()
    }

    fun loadUserStats() {
        viewModelScope.launch {
            val userId = FirebaseAuth.getInstance().currentUser?.uid ?: return@launch
            
            when (val result = userRepository.getUser(userId)) {
                is Resource.Success -> {
                    val user = result.data
                    if (user != null) {
                        _homeState.value = _homeState.value.copy(
                            wisdomPoints = user.gamification.wisdomPoints,
                            gems = user.gamification.gems,
                            energy = user.gamification.energy,
                            maxEnergy = user.gamification.maxEnergy,
                            currentStreak = user.gamification.currentStreak
                        )
                    }
                }
                is Resource.Error -> {
                    // Silently fail for stats - not critical
                }
                is Resource.Loading -> {}
            }
        }
    }

    fun loadChapters() {
        viewModelScope.launch {
            _homeState.value = _homeState.value.copy(isLoading = true, error = null)
            
            val userId = FirebaseAuth.getInstance().currentUser?.uid ?: ""
            
            when (val result = contentRepository.getChapters()) {
                is Resource.Success -> {
                    val chapters = result.data ?: emptyList()
                    
                    // Load lessons for each chapter and check unlock status
                    val lessonsMap = mutableMapOf<String, List<com.schepor.gita.domain.model.Lesson>>()
                    val firstLessonsMap = mutableMapOf<String, String>()
                    val unlockedChaptersSet = mutableSetOf<String>()
                    val unlockedLessonsSet = mutableSetOf<String>()
                    val completedLessonsSet = mutableSetOf<String>()
                    
                    // Get user data for progress tracking
                    val user = if (userId.isNotEmpty()) {
                        when (val userResult = userRepository.getUser(userId)) {
                            is Resource.Success -> userResult.data
                            else -> null
                        }
                    } else null
                    
                    chapters.forEach { chapter ->
                        // Check if chapter is unlocked
                        if (userId.isNotEmpty()) {
                            when (val unlockResult = userRepository.isChapterUnlocked(
                                userId = userId,
                                chapterNumber = chapter.chapterNumber,
                                totalLessonsInPreviousChapter = 3 // TODO: Get actual count
                            )) {
                                is Resource.Success -> {
                                    if (unlockResult.data == true) {
                                        unlockedChaptersSet.add(chapter.chapterId)
                                    }
                                }
                                else -> {} // Skip on error
                            }
                        } else {
                            // If no user, unlock first chapter only
                            if (chapter.chapterNumber == 1) {
                                unlockedChaptersSet.add(chapter.chapterId)
                            }
                        }
                        
                        // Load lessons for unlocked chapters
                        if (unlockedChaptersSet.contains(chapter.chapterId)) {
                            when (val lessonsResult = contentRepository.getLessons(chapter.chapterId)) {
                                is Resource.Success -> {
                                    val lessons = lessonsResult.data ?: emptyList()
                                    lessonsMap[chapter.chapterId] = lessons
                                    val firstLesson = lessons.firstOrNull()
                                    
                                    if (firstLesson != null) {
                                        firstLessonsMap[chapter.chapterId] = firstLesson.lessonId
                                        
                                        // Check unlock status for each lesson
                                        lessons.forEach { lesson ->
                                            val lessonKey = "${chapter.chapterId}_${lesson.lessonId}"
                                            
                                            // Check if completed
                                            if (user?.progress?.containsKey(lessonKey) == true) {
                                                completedLessonsSet.add(lesson.lessonId)
                                            }
                                            
                                            if (userId.isNotEmpty()) {
                                                when (val lessonUnlockResult = userRepository.isLessonUnlocked(
                                                    userId = userId,
                                                    chapterId = chapter.chapterId,
                                                    lessonId = lesson.lessonId,
                                                    lessonNumber = lesson.lessonNumber,
                                                    chapterNumber = chapter.chapterNumber,
                                                    prerequisiteLessonId = lesson.prerequisite
                                                )) {
                                                    is Resource.Success -> {
                                                        if (lessonUnlockResult.data == true) {
                                                            unlockedLessonsSet.add(lesson.lessonId)
                                                        }
                                                    }
                                                    else -> {} // Skip on error
                                                }
                                            } else {
                                                // If no user, unlock first lesson only
                                                if (lesson.lessonNumber == 1 && chapter.chapterNumber == 1) {
                                                    unlockedLessonsSet.add(lesson.lessonId)
                                                }
                                            }
                                        }
                                    }
                                }
                                else -> {} // Skip if lessons can't be loaded
                            }
                        }
                    }
                    
                    _homeState.value = _homeState.value.copy(
                        isLoading = false,
                        chapters = chapters,
                        chapterLessons = lessonsMap,
                        chapterFirstLessons = firstLessonsMap,
                        unlockedChapters = unlockedChaptersSet,
                        unlockedLessons = unlockedLessonsSet,
                        completedLessons = completedLessonsSet
                    )
                }
                is Resource.Error -> {
                    _homeState.value = _homeState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                is Resource.Loading -> {
                    _homeState.value = _homeState.value.copy(isLoading = true)
                }
            }
        }
    }
}
