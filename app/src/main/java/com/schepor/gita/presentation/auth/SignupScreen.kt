package com.schepor.gita.presentation.auth

import android.app.Activity
import androidx.activity.compose.rememberLauncherForActivityResult
import androidx.activity.result.contract.ActivityResultContracts
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.input.PasswordVisualTransformation
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.common.api.ApiException
import com.schepor.gita.presentation.theme.Spacing

/**
 * Signup Screen
 * Allows users to create a new account
 */
@Composable
fun SignupScreen(
    onNavigateToLogin: () -> Unit,
    onNavigateToHome: () -> Unit,
    viewModel: AuthViewModel = hiltViewModel(),
    googleSignInClient: GoogleSignInClient? = null
) {
    var email by remember { mutableStateOf("") }
    var password by remember { mutableStateOf("") }
    var confirmPassword by remember { mutableStateOf("") }
    
    val authState by viewModel.authState.collectAsState()
    val context = LocalContext.current
    
    // Google Sign-In launcher
    val googleSignInLauncher = rememberLauncherForActivityResult(
        contract = ActivityResultContracts.StartActivityForResult()
    ) { result ->
        when (result.resultCode) {
            Activity.RESULT_OK -> {
                val task = GoogleSignIn.getSignedInAccountFromIntent(result.data)
                try {
                    val account = task.getResult(ApiException::class.java)
                    account?.let { 
                        viewModel.signInWithGoogle(it) 
                    } ?: run {
                        viewModel.setError("No account selected")
                    }
                } catch (e: ApiException) {
                    val errorMessage = when (e.statusCode) {
                        10 -> "Developer Error: Please configure Google Sign-In in Firebase Console (error code 10)"
                        12501 -> "Sign-In cancelled by user"
                        12500 -> "Sign-In failed: Please try again"
                        7 -> "Network error: Check your internet connection"
                        else -> "Google Sign-In failed: Error ${e.statusCode} - ${e.message}"
                    }
                    viewModel.setError(errorMessage)
                }
            }
            Activity.RESULT_CANCELED -> {
                viewModel.setError("Sign-In was cancelled. Please try again.")
            }
            else -> {
                viewModel.setError("Sign-In failed with result code: ${result.resultCode}")
            }
        }
    }
    
    // Navigate to home when signup is successful
    LaunchedEffect(authState.isSuccess) {
        if (authState.isSuccess && authState.user != null) {
            onNavigateToHome()
        }
    }
    
    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(Spacing.space24),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Title
        Text(
            text = "Create Account",
            style = MaterialTheme.typography.displayMedium,
            color = MaterialTheme.colorScheme.primary
        )
        
        Spacer(modifier = Modifier.height(Spacing.space8))
        
        Text(
            text = "Join the journey of wisdom",
            style = MaterialTheme.typography.bodyLarge,
            color = MaterialTheme.colorScheme.onBackground
        )
        
        Spacer(modifier = Modifier.height(Spacing.space48))
        
        // Error Message
        if (authState.error != null) {
            Text(
                text = authState.error ?: "",
                color = MaterialTheme.colorScheme.error,
                style = MaterialTheme.typography.bodySmall
            )
            Spacer(modifier = Modifier.height(Spacing.space8))
        }
        
        // Email Field
        OutlinedTextField(
            value = email,
            onValueChange = { email = it },
            label = { Text("Email") },
            modifier = Modifier.fillMaxWidth(),
            singleLine = true
        )
        
        Spacer(modifier = Modifier.height(Spacing.space16))
        
        // Password Field
        OutlinedTextField(
            value = password,
            onValueChange = { password = it },
            label = { Text("Password") },
            modifier = Modifier.fillMaxWidth(),
            visualTransformation = PasswordVisualTransformation(),
            singleLine = true
        )
        
        Spacer(modifier = Modifier.height(Spacing.space16))
        
        // Confirm Password Field
        OutlinedTextField(
            value = confirmPassword,
            onValueChange = { confirmPassword = it },
            label = { Text("Confirm Password") },
            modifier = Modifier.fillMaxWidth(),
            visualTransformation = PasswordVisualTransformation(),
            singleLine = true
        )
        
        Spacer(modifier = Modifier.height(Spacing.space24))
        
        // Signup Button
        Button(
            onClick = { 
                viewModel.clearError()
                viewModel.signUp(email, password, confirmPassword)
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            enabled = !authState.isLoading
        ) {
            if (authState.isLoading) {
                CircularProgressIndicator(
                    modifier = Modifier.size(24.dp),
                    color = MaterialTheme.colorScheme.onPrimary
                )
            } else {
                Text("Sign Up")
            }
        }
        
        Spacer(modifier = Modifier.height(Spacing.space16))
        
        // Divider with "OR"
        Row(
            modifier = Modifier.fillMaxWidth(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            HorizontalDivider(modifier = Modifier.weight(1f))
            Text(
                text = " OR ",
                style = MaterialTheme.typography.bodyMedium,
                modifier = Modifier.padding(horizontal = Spacing.space8)
            )
            HorizontalDivider(modifier = Modifier.weight(1f))
        }
        
        Spacer(modifier = Modifier.height(Spacing.space16))
        
        // Google Sign-In Button
        OutlinedButton(
            onClick = {
                viewModel.clearError()
                if (googleSignInClient != null) {
                    val signInIntent = googleSignInClient.signInIntent
                    googleSignInLauncher.launch(signInIntent)
                } else {
                    viewModel.setError("Google Sign-In is not configured")
                }
            },
            modifier = Modifier
                .fillMaxWidth()
                .height(48.dp),
            enabled = !authState.isLoading,
            border = BorderStroke(1.dp, MaterialTheme.colorScheme.outline)
        ) {
            Row(
                horizontalArrangement = Arrangement.Center,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Google logo (we'll use a simple "G" for now, replace with actual icon if needed)
                Text(
                    text = "G",
                    style = MaterialTheme.typography.titleLarge,
                    color = MaterialTheme.colorScheme.primary,
                    modifier = Modifier.padding(end = Spacing.space12)
                )
                Text("Sign up with Google")
            }
        }
        
        Spacer(modifier = Modifier.height(Spacing.space16))
        
        // Login Link
        TextButton(onClick = onNavigateToLogin) {
            Text("Already have an account? Login")
        }
    }
}
