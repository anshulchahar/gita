package com.schepor.gita.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.schepor.gita.presentation.auth.LoginScreen
import com.schepor.gita.presentation.home.HomeScreen
import com.schepor.gita.presentation.lesson.LessonScreen
import com.schepor.gita.util.Constants

/**
 * Main navigation graph for the app
 */
@Composable
fun GitaNavigation(
    navController: NavHostController = rememberNavController()
) {
    NavHost(
        navController = navController,
        startDestination = Constants.ROUTE_LOGIN
    ) {
        // Authentication Flow
        composable(Constants.ROUTE_LOGIN) {
            LoginScreen(
                onNavigateToSignup = {
                    navController.navigate(Constants.ROUTE_SIGNUP)
                },
                onNavigateToHome = {
                    navController.navigate(Constants.ROUTE_HOME) {
                        popUpTo(Constants.ROUTE_LOGIN) { inclusive = true }
                    }
                }
            )
        }
        
        composable(Constants.ROUTE_SIGNUP) {
            // TODO: Implement SignupScreen
            LoginScreen(
                onNavigateToSignup = { },
                onNavigateToHome = {
                    navController.navigate(Constants.ROUTE_HOME) {
                        popUpTo(Constants.ROUTE_SIGNUP) { inclusive = true }
                    }
                }
            )
        }
        
        // Main App Flow
        composable(Constants.ROUTE_HOME) {
            HomeScreen(
                onNavigateToLesson = { chapterId, lessonId ->
                    navController.navigate("lesson/$chapterId/$lessonId")
                }
            )
        }
        
        composable(Constants.ROUTE_LESSON) { backStackEntry ->
            val chapterId = backStackEntry.arguments?.getString("chapterId") ?: ""
            val lessonId = backStackEntry.arguments?.getString("lessonId") ?: ""
            
            LessonScreen(
                chapterId = chapterId,
                lessonId = lessonId,
                onNavigateBack = { navController.popBackStack() }
            )
        }
    }
}
