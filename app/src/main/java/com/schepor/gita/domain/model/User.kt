package com.schepor.gita.domain.model

import com.google.firebase.Timestamp

/**
 * Domain model representing a user in the app
 */
data class User(
    val userId: String = "",
    val email: String = "",
    val displayName: String = "",
    val photoUrl: String? = null,
    val createdAt: Timestamp = Timestamp.now(),
    val lastActiveAt: Timestamp = Timestamp.now(),
    val gamification: Gamification = Gamification(),
    val progress: Map<String, LessonProgress> = emptyMap(),
    val weakAreas: List<String> = emptyList(),
    val achievements: List<String> = emptyList(),
    val preferences: UserPreferences = UserPreferences()
)

/**
 * Gamification data for a user
 */
data class Gamification(
    val wisdomPoints: Int = 0,
    val currentStreak: Int = 0,
    val longestStreak: Int = 0,
    val lastCompletedDate: String = "",
    val totalLessonsCompleted: Int = 0,
    val perfectScores: Int = 0
)

/**
 * Progress data for a specific lesson
 */
data class LessonProgress(
    val completedAt: Timestamp = Timestamp.now(),
    val score: Int = 0,
    val attempts: Int = 0,
    val timeSpent: Int = 0 // in seconds
)

/**
 * User preferences
 */
data class UserPreferences(
    val notificationsEnabled: Boolean = true,
    val dailyReminderTime: String = "09:00",
    val language: String = "hi", // Hindi by default
    val theme: String = "light"
)
