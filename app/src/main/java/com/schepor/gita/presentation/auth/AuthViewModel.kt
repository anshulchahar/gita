package com.schepor.gita.presentation.auth

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.google.android.gms.auth.api.signin.GoogleSignInAccount
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import com.schepor.gita.data.repository.UserRepository
import com.schepor.gita.domain.model.User
import com.schepor.gita.util.Resource
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import kotlinx.coroutines.tasks.await
import javax.inject.Inject

data class AuthState(
    val isLoading: Boolean = false,
    val isSuccess: Boolean = false,
    val error: String? = null,
    val user: FirebaseUser? = null
)

@HiltViewModel
class AuthViewModel @Inject constructor(
    private val auth: FirebaseAuth,
    private val userRepository: UserRepository
) : ViewModel() {

    private val _authState = MutableStateFlow(AuthState())
    val authState: StateFlow<AuthState> = _authState.asStateFlow()

    init {
        checkAuthStatus()
    }

    private fun checkAuthStatus() {
        _authState.value = _authState.value.copy(
            user = auth.currentUser,
            isSuccess = auth.currentUser != null
        )
    }

    fun signUp(email: String, password: String, confirmPassword: String) {
        if (email.isBlank() || password.isBlank()) {
            _authState.value = _authState.value.copy(
                error = "Email and password cannot be empty"
            )
            return
        }

        if (password != confirmPassword) {
            _authState.value = _authState.value.copy(
                error = "Passwords do not match"
            )
            return
        }

        if (password.length < 6) {
            _authState.value = _authState.value.copy(
                error = "Password must be at least 6 characters"
            )
            return
        }

        viewModelScope.launch {
            try {
                _authState.value = _authState.value.copy(isLoading = true, error = null)
                
                val result = auth.createUserWithEmailAndPassword(email, password).await()
                
                // Create user document in Firestore
                result.user?.let { firebaseUser ->
                    val user = User(
                        userId = firebaseUser.uid,
                        email = firebaseUser.email ?: email,
                        displayName = firebaseUser.email?.substringBefore("@") ?: "User"
                    )
                    
                    when (val userResult = userRepository.createUser(user)) {
                        is Resource.Error -> {
                            // Log error but don't fail auth
                            _authState.value = _authState.value.copy(
                                isLoading = false,
                                isSuccess = true,
                                user = firebaseUser,
                                error = null
                            )
                        }
                        is Resource.Success -> {
                            _authState.value = _authState.value.copy(
                                isLoading = false,
                                isSuccess = true,
                                user = firebaseUser,
                                error = null
                            )
                        }
                        is Resource.Loading -> {}
                    }
                } ?: run {
                    _authState.value = _authState.value.copy(
                        isLoading = false,
                        isSuccess = false,
                        error = "Failed to create user"
                    )
                }
            } catch (e: Exception) {
                _authState.value = _authState.value.copy(
                    isLoading = false,
                    isSuccess = false,
                    error = e.message ?: "Sign up failed"
                )
            }
        }
    }

    fun signIn(email: String, password: String) {
        if (email.isBlank() || password.isBlank()) {
            _authState.value = _authState.value.copy(
                error = "Email and password cannot be empty"
            )
            return
        }

        viewModelScope.launch {
            try {
                _authState.value = _authState.value.copy(isLoading = true, error = null)
                
                val result = auth.signInWithEmailAndPassword(email, password).await()
                
                _authState.value = _authState.value.copy(
                    isLoading = false,
                    isSuccess = true,
                    user = result.user,
                    error = null
                )
            } catch (e: Exception) {
                _authState.value = _authState.value.copy(
                    isLoading = false,
                    isSuccess = false,
                    error = e.message ?: "Sign in failed"
                )
            }
        }
    }

    fun signInWithGoogle(account: GoogleSignInAccount) {
        viewModelScope.launch {
            try {
                _authState.value = _authState.value.copy(isLoading = true, error = null)
                
                val credential = GoogleAuthProvider.getCredential(account.idToken, null)
                val result = auth.signInWithCredential(credential).await()
                
                // Create or update user in Firestore
                result.user?.let { firebaseUser ->
                    val user = User(
                        userId = firebaseUser.uid,
                        email = firebaseUser.email ?: "",
                        displayName = firebaseUser.displayName ?: "User",
                        photoUrl = firebaseUser.photoUrl?.toString()
                    )
                    
                    when (val userResult = userRepository.createUser(user)) {
                        is Resource.Error -> {
                            // Log error but don't fail auth
                            _authState.value = _authState.value.copy(
                                isLoading = false,
                                isSuccess = true,
                                user = firebaseUser,
                                error = null
                            )
                        }
                        is Resource.Success -> {
                            _authState.value = _authState.value.copy(
                                isLoading = false,
                                isSuccess = true,
                                user = firebaseUser,
                                error = null
                            )
                        }
                        is Resource.Loading -> {}
                    }
                } ?: run {
                    _authState.value = _authState.value.copy(
                        isLoading = false,
                        isSuccess = false,
                        error = "Failed to sign in with Google"
                    )
                }
            } catch (e: Exception) {
                _authState.value = _authState.value.copy(
                    isLoading = false,
                    isSuccess = false,
                    error = e.message ?: "Google sign in failed"
                )
            }
        }
    }

    fun signOut() {
        auth.signOut()
        _authState.value = AuthState()
    }

    fun clearError() {
        _authState.value = _authState.value.copy(error = null)
    }
    
    fun setError(message: String) {
        _authState.value = _authState.value.copy(
            isLoading = false,
            error = message
        )
    }

    fun resetAuthState() {
        _authState.value = AuthState(user = auth.currentUser)
    }
}
