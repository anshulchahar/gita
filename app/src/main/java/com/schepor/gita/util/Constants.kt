package com.schepor.gita.util

/**
 * Constants used throughout the app
 */
object Constants {
    
    // Firebase Collections
    const val COLLECTION_USERS = "users"
    const val COLLECTION_CONTENT = "content"
    const val COLLECTION_LESSONS = "lessons"
    const val COLLECTION_QUESTIONS = "questions"
    const val COLLECTION_AI_CONTENT = "ai_generated_content"
    const val COLLECTION_LEADERBOARDS = "leaderboards"
    const val COLLECTION_ACHIEVEMENTS = "achievements"
    
    // Shared Preferences Keys
    const val PREF_USER_ID = "user_id"
    const val PREF_IS_LOGGED_IN = "is_logged_in"
    const val PREF_THEME = "theme"
    const val PREF_LANGUAGE = "language"
    
    // Default Values
    const val DEFAULT_LESSON_POINTS = 50
    const val DEFAULT_STREAK_POINTS = 10
    const val DEFAULT_PERFECT_SCORE_BONUS = 25
    
    // Lesson Completion Threshold
    const val LESSON_PASS_THRESHOLD = 70 // 70% to pass
    
    // Navigation Routes
    const val ROUTE_SPLASH = "splash"
    const val ROUTE_LOGIN = "login"
    const val ROUTE_SIGNUP = "signup"
    const val ROUTE_HOME = "home"
    const val ROUTE_LESSON = "lesson/{chapterId}/{lessonId}"
    const val ROUTE_PROFILE = "profile"
    const val ROUTE_LEADERBOARD = "leaderboard"
    
    // Animation
    const val ANIMATION_DURATION_SHORT = 200
    const val ANIMATION_DURATION_MEDIUM = 300
    const val ANIMATION_DURATION_LONG = 500
}
