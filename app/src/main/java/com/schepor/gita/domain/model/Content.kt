package com.schepor.gita.domain.model

/**
 * Domain model representing a chapter in the Bhagavad Gita
 */
data class Chapter(
    val chapterId: String = "",
    val chapterNumber: Int = 0,
    val chapterName: String = "",
    val chapterNameEn: String = "",
    val description: String = "",
    val descriptionEn: String = "",
    val shlokaCount: Int = 0,
    val order: Int = 0,
    val isUnlocked: Boolean = false,
    val icon: String = "",
    val color: String = ""
)

/**
 * Domain model representing a lesson within a chapter
 */
data class Lesson(
    val lessonId: String = "",
    val chapterId: String = "",
    val lessonNumber: Int = 0,
    val lessonName: String = "",
    val lessonNameEn: String = "",
    val order: Int = 0,
    val estimatedTime: Int = 0, // in seconds
    val difficulty: String = "beginner", // beginner, intermediate, advanced
    val shlokasCovered: List<Int> = emptyList(),
    val xpReward: Int = 0,
    val prerequisite: String? = null
)

/**
 * Domain model representing a question in a lesson
 */
data class Question(
    val questionId: String = "",
    val type: QuestionType = QuestionType.MULTIPLE_CHOICE_TRANSLATION,
    val order: Int = 0,
    val content: QuestionContent = QuestionContent(),
    val points: Int = 10,
    val timeLimit: Int = 60 // in seconds
)

/**
 * Content of a question
 */
data class QuestionContent(
    val shlokaSanskrit: String = "",
    val shlokaTransliteration: String = "",
    val shlokaNumber: String = "",
    val questionText: String = "",
    val options: List<String> = emptyList(),
    val correctAnswerIndex: Int = 0,
    val explanation: String = "",
    val realLifeApplication: String = "",
    val keywords: List<String> = emptyList()
)

/**
 * Types of questions available in lessons
 */
enum class QuestionType {
    MULTIPLE_CHOICE_TRANSLATION,
    FILL_IN_BLANK,
    WORD_MATCHING,
    CONTEXTUAL_APPLICATION,
    TRUE_FALSE
}
