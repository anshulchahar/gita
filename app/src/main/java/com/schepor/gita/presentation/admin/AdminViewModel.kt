package com.schepor.gita.presentation.admin

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.schepor.gita.data.seed.ContentSeeder
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class SeedState(
    val isLoading: Boolean = false,
    val isSuccess: Boolean = false,
    val error: String? = null,
    val message: String? = null
)

@HiltViewModel
class AdminViewModel @Inject constructor(
    private val contentSeeder: ContentSeeder
) : ViewModel() {

    private val _seedState = MutableStateFlow(SeedState())
    val seedState: StateFlow<SeedState> = _seedState.asStateFlow()

    fun seedContent() {
        viewModelScope.launch {
            try {
                _seedState.value = _seedState.value.copy(
                    isLoading = true,
                    error = null,
                    message = "Seeding content..."
                )
                
                contentSeeder.seedAll()
                
                _seedState.value = _seedState.value.copy(
                    isLoading = false,
                    isSuccess = true,
                    message = "Content seeded successfully!"
                )
            } catch (e: Exception) {
                _seedState.value = _seedState.value.copy(
                    isLoading = false,
                    isSuccess = false,
                    error = e.message ?: "Failed to seed content"
                )
            }
        }
    }
    
    fun clearAllData() {
        viewModelScope.launch {
            try {
                _seedState.value = _seedState.value.copy(
                    isLoading = true,
                    error = null,
                    message = "Clearing all data..."
                )
                
                contentSeeder.clearAllContent()
                
                _seedState.value = _seedState.value.copy(
                    isLoading = false,
                    isSuccess = true,
                    message = "All data cleared!"
                )
            } catch (e: Exception) {
                _seedState.value = _seedState.value.copy(
                    isLoading = false,
                    isSuccess = false,
                    error = e.message ?: "Failed to clear data"
                )
            }
        }
    }
    
    fun forceSeed() {
        viewModelScope.launch {
            try {
                _seedState.value = _seedState.value.copy(
                    isLoading = true,
                    error = null,
                    message = "Clearing old data and re-seeding..."
                )
                
                contentSeeder.forceSeed()
                
                _seedState.value = _seedState.value.copy(
                    isLoading = false,
                    isSuccess = true,
                    message = "Data cleared and re-seeded successfully!"
                )
            } catch (e: Exception) {
                _seedState.value = _seedState.value.copy(
                    isLoading = false,
                    isSuccess = false,
                    error = e.message ?: "Failed to force seed"
                )
            }
        }
    }

    fun clearState() {
        _seedState.value = SeedState()
    }
}
