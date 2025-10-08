package com.schepor.gita.presentation.lesson

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.schepor.gita.data.repository.ContentRepository
import com.schepor.gita.data.repository.UserRepository
import com.schepor.gita.domain.model.Lesson
import com.schepor.gita.domain.model.Question
import com.schepor.gita.util.Resource
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

/**
 * State for the lesson screen
 */
data class LessonState(
    val isLoading: Boolean = false,
    val lesson: Lesson? = null,
    val questions: List<Question> = emptyList(),
    val currentQuestionIndex: Int = 0,
    val selectedAnswers: Map<String, Int> = emptyMap(), // questionId to selected option index
    val answeredQuestions: Set<String> = emptySet(), // Set of answered question IDs
    val score: Int = 0,
    val showResults: Boolean = false,
    val error: String? = null
)

/**
 * ViewModel for the Lesson Screen
 * Handles loading lesson data, questions, and managing quiz state
 */
@HiltViewModel
class LessonViewModel @Inject constructor(
    private val contentRepository: ContentRepository,
    private val userRepository: UserRepository
) : ViewModel() {
    
    private val _lessonState = MutableStateFlow(LessonState())
    val lessonState = _lessonState.asStateFlow()
    
    /**
     * Load lesson and its questions
     */
    fun loadLesson(chapterId: String, lessonId: String) {
        viewModelScope.launch {
            _lessonState.value = _lessonState.value.copy(isLoading = true, error = null)
            
            // Load lesson data
            when (val lessonResult = contentRepository.getLesson(lessonId)) {
                is Resource.Success -> {
                    _lessonState.value = _lessonState.value.copy(lesson = lessonResult.data)
                    
                    // Load questions for this lesson
                    when (val questionsResult = contentRepository.getQuestions(lessonId)) {
                        is Resource.Success -> {
                            _lessonState.value = _lessonState.value.copy(
                                questions = questionsResult.data ?: emptyList(),
                                isLoading = false
                            )
                        }
                        is Resource.Error -> {
                            _lessonState.value = _lessonState.value.copy(
                                error = questionsResult.message ?: "Failed to load questions",
                                isLoading = false
                            )
                        }
                        is Resource.Loading -> {
                            _lessonState.value = _lessonState.value.copy(isLoading = true)
                        }
                    }
                }
                is Resource.Error -> {
                    _lessonState.value = _lessonState.value.copy(
                        error = lessonResult.message ?: "Failed to load lesson",
                        isLoading = false
                    )
                }
                is Resource.Loading -> {
                    _lessonState.value = _lessonState.value.copy(isLoading = true)
                }
            }
        }
    }
    
    /**
     * Select an answer for the current question
     */
    fun selectAnswer(questionId: String, optionIndex: Int) {
        val currentState = _lessonState.value
        val updatedAnswers = currentState.selectedAnswers.toMutableMap()
        updatedAnswers[questionId] = optionIndex
        
        _lessonState.value = currentState.copy(
            selectedAnswers = updatedAnswers
        )
    }
    
    /**
     * Submit answer for the current question and check if correct
     */
    fun submitAnswer() {
        val currentState = _lessonState.value
        val currentQuestion = currentState.questions.getOrNull(currentState.currentQuestionIndex)
        
        if (currentQuestion != null) {
            val selectedOption = currentState.selectedAnswers[currentQuestion.questionId]
            val isCorrect = selectedOption == currentQuestion.content.correctAnswerIndex
            
            // Mark question as answered
            val updatedAnsweredQuestions = currentState.answeredQuestions.toMutableSet()
            updatedAnsweredQuestions.add(currentQuestion.questionId)
            
            // Update score if correct
            val newScore = if (isCorrect) currentState.score + 1 else currentState.score
            
            _lessonState.value = currentState.copy(
                answeredQuestions = updatedAnsweredQuestions,
                score = newScore
            )
        }
    }
    
    /**
     * Move to the next question
     */
    fun nextQuestion() {
        val currentState = _lessonState.value
        val nextIndex = currentState.currentQuestionIndex + 1
        
        if (nextIndex < currentState.questions.size) {
            _lessonState.value = currentState.copy(
                currentQuestionIndex = nextIndex
            )
        } else {
            // All questions answered, show results
            _lessonState.value = currentState.copy(
                showResults = true
            )
        }
    }
    
    /**
     * Move to the previous question
     */
    fun previousQuestion() {
        val currentState = _lessonState.value
        val previousIndex = currentState.currentQuestionIndex - 1
        
        if (previousIndex >= 0) {
            _lessonState.value = currentState.copy(
                currentQuestionIndex = previousIndex
            )
        }
    }
    
    /**
     * Check if current question has been answered
     */
    fun isCurrentQuestionAnswered(): Boolean {
        val currentState = _lessonState.value
        val currentQuestion = currentState.questions.getOrNull(currentState.currentQuestionIndex)
        return currentQuestion?.questionId in currentState.answeredQuestions
    }
    
    /**
     * Get the selected option for current question, or null if not selected
     */
    fun getSelectedOptionForCurrentQuestion(): Int? {
        val currentState = _lessonState.value
        val currentQuestion = currentState.questions.getOrNull(currentState.currentQuestionIndex)
        return currentQuestion?.let { currentState.selectedAnswers[it.questionId] }
    }
    
    /**
     * Gets the correct option index for the current question
     */
    fun getCorrectOptionForCurrentQuestion(): Int? {
        val currentQuestion = _lessonState.value.questions.getOrNull(
            _lessonState.value.currentQuestionIndex
        )
        return currentQuestion?.content?.correctAnswerIndex
    }
    
    /**
     * Calculate final score percentage
     */
    fun getScorePercentage(): Int {
        val currentState = _lessonState.value
        val totalQuestions = currentState.questions.size
        if (totalQuestions == 0) return 0
        return (currentState.score * 100) / totalQuestions
    }
    
    /**
     * Save lesson completion to Firestore
     */
    fun saveLessonCompletion(userId: String, chapterId: String, lessonId: String) {
        viewModelScope.launch {
            val currentState = _lessonState.value
            val scorePercentage = getScorePercentage()
            
            // TODO: Implement progress tracking
            // This will be implemented in the next task (Lesson Progress Tracking)
        }
    }
    
    /**
     * Reset the lesson state (for retrying)
     */
    fun resetLesson() {
        _lessonState.value = LessonState(
            lesson = _lessonState.value.lesson,
            questions = _lessonState.value.questions
        )
    }
    
    /**
     * Clear any error
     */
    fun clearError() {
        _lessonState.value = _lessonState.value.copy(error = null)
    }
}
