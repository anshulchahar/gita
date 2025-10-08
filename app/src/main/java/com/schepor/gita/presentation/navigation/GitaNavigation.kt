package com.schepor.gita.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.NavHostController
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import com.schepor.gita.presentation.admin.AdminScreen
import com.schepor.gita.presentation.auth.LoginScreen
import com.schepor.gita.presentation.auth.SignupScreen
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
    val context = LocalContext.current
    
    // Create GoogleSignInClient
    val googleSignInOptions = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
        .requestIdToken("1091827331036-s76h7kefpj9spt9o3ug6d4cebedtc0n1.apps.googleusercontent.com")
        .requestEmail()
        .requestProfile()
        .build()
    
    val googleSignInClient = GoogleSignIn.getClient(context, googleSignInOptions)
    
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
                },
                googleSignInClient = googleSignInClient
            )
        }
        
        composable(Constants.ROUTE_SIGNUP) {
            SignupScreen(
                onNavigateToLogin = {
                    navController.popBackStack()
                },
                onNavigateToHome = {
                    navController.navigate(Constants.ROUTE_HOME) {
                        popUpTo(Constants.ROUTE_SIGNUP) { inclusive = true }
                    }
                },
                googleSignInClient = googleSignInClient
            )
        }
        
        // Main App Flow
        composable(Constants.ROUTE_HOME) {
            HomeScreen(
                onNavigateToLesson = { chapterId, lessonId ->
                    navController.navigate("lesson/$chapterId/$lessonId")
                },
                onNavigateToAdmin = {
                    navController.navigate(Constants.ROUTE_ADMIN)
                },
                onNavigateToLogin = {
                    navController.navigate(Constants.ROUTE_LOGIN) {
                        popUpTo(Constants.ROUTE_HOME) { inclusive = true }
                    }
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
        
        // Admin Panel
        composable(Constants.ROUTE_ADMIN) {
            AdminScreen()
        }
    }
}
