package com.schepor.gita.presentation.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.schepor.gita.data.repository.ContentRepository
import com.schepor.gita.domain.model.Chapter
import com.schepor.gita.util.Resource
import dagger.hilt.android.lifecycle.HiltViewModel
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

data class HomeState(
    val isLoading: Boolean = false,
    val chapters: List<Chapter> = emptyList(),
    val error: String? = null
)

@HiltViewModel
class HomeViewModel @Inject constructor(
    private val contentRepository: ContentRepository
) : ViewModel() {

    private val _homeState = MutableStateFlow(HomeState())
    val homeState: StateFlow<HomeState> = _homeState.asStateFlow()

    init {
        loadChapters()
    }

    fun loadChapters() {
        viewModelScope.launch {
            _homeState.value = _homeState.value.copy(isLoading = true, error = null)
            
            when (val result = contentRepository.getChapters()) {
                is Resource.Success -> {
                    _homeState.value = _homeState.value.copy(
                        isLoading = false,
                        chapters = result.data ?: emptyList()
                    )
                }
                is Resource.Error -> {
                    _homeState.value = _homeState.value.copy(
                        isLoading = false,
                        error = result.message
                    )
                }
                is Resource.Loading -> {
                    _homeState.value = _homeState.value.copy(isLoading = true)
                }
            }
        }
    }
}
