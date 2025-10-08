package com.schepor.gita.presentation.navigation

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.navigation.NavHostController
import androidx.navigation.NavType
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import androidx.navigation.navArgument
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
        .requestIdToken("130647293969-h9homid4an61g9ih6ngd1one2b1n785a.apps.googleusercontent.com") // Web OAuth client ID from google-services.json
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
                    println("DEBUG Navigation: Navigating to lesson/$chapterId/$lessonId")
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
        
        composable(
            route = Constants.ROUTE_LESSON,
            arguments = listOf(
                navArgument("chapterId") { type = NavType.StringType },
                navArgument("lessonId") { type = NavType.StringType }
            )
        ) { backStackEntry ->
            val chapterId = backStackEntry.arguments?.getString("chapterId") ?: ""
            val lessonId = backStackEntry.arguments?.getString("lessonId") ?: ""
            
            println("DEBUG Navigation: LessonScreen composable - chapterId: $chapterId, lessonId: $lessonId")
            
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
