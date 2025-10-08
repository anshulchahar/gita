package com.schepor.gita.presentation.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.schepor.gita.data.repository.ContentRepository
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
    val chapterFirstLessons: Map<String, String> = emptyMap(), // chapterId to first lessonId
    val error: String? = null
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val contentRepository: ContentRepository
) : ViewModel() {

    private val _homeState = MutableStateFlow(HomeState())
    val homeState: StateFlow<HomeState> = _homeState.asStateFlow()

    init {
        loadChapters()
    }

    fun loadChapters() {
        viewModelScope.launch {
            _homeState.value = _homeState.value.copy(isLoading = true, error = null)
            
            when (val result = contentRepository.getChapters()) {
                is Resource.Success -> {
                    val chapters = result.data ?: emptyList()
                    println("DEBUG ViewModel: Loaded ${chapters.size} chapters")
                    
                    // Load first lesson for each chapter
                    val firstLessonsMap = mutableMapOf<String, String>()
                    chapters.forEach { chapter ->
                        println("DEBUG ViewModel: Loading lessons for chapter ${chapter.chapterId} (${chapter.chapterNameEn})")
                        println("DEBUG ViewModel: Calling getLessons with chapterId: ${chapter.chapterId}")
                        when (val lessonsResult = contentRepository.getLessons(chapter.chapterId)) {
                            is Resource.Success -> {
                                val lessons = lessonsResult.data ?: emptyList()
                                println("DEBUG ViewModel: SUCCESS - Found ${lessons.size} lessons for chapter ${chapter.chapterId}")
                                lessons.forEach { lesson ->
                                    println("DEBUG ViewModel: - Lesson: ${lesson.lessonId}, Name: ${lesson.lessonNameEn}, ChapterId in Lesson: ${lesson.chapterId}")
                                }
                                val firstLesson = lessons.firstOrNull()
                                if (firstLesson != null) {
                                    println("DEBUG ViewModel: First lesson ID: ${firstLesson.lessonId}, Name: ${firstLesson.lessonNameEn}")
                                    firstLessonsMap[chapter.chapterId] = firstLesson.lessonId
                                } else {
                                    println("DEBUG ViewModel: WARNING - Lessons list is empty for chapter ${chapter.chapterId}")
                                }
                            }
                            is Resource.Error -> {
                                println("DEBUG ViewModel: ERROR loading lessons: ${lessonsResult.message}")
                            }
                            else -> {
                                println("DEBUG ViewModel: Loading state for lessons")
                            }
                        }
                    }
                    
                    println("DEBUG ViewModel: Final first lessons map: $firstLessonsMap")
                    _homeState.value = _homeState.value.copy(
                        isLoading = false,
                        chapters = chapters,
                        chapterFirstLessons = firstLessonsMap
                    )
                }
                is Resource.Error -> {
                    println("DEBUG ViewModel: Error loading chapters: ${result.message}")
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
