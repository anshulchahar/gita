package com.schepor.gita.util

/**
 * A generic sealed class to represent the result of an operation
 * Helps with proper error handling and UI state management
 */
sealed class Resource<T>(
    val data: T? = null,
    val message: String? = null
) {
    class Success<T>(data: T) : Resource<T>(data)
    class Error<T>(message: String, data: T? = null) : Resource<T>(data, message)
    class Loading<T>(data: T? = null) : Resource<T>(data)
}

/**
 * Extension function to safely get data from Resource
 */
fun <T> Resource<T>.getOrNull(): T? = when (this) {
    is Resource.Success -> data
    else -> null
}

/**
 * Extension function to check if Resource is loading
 */
fun <T> Resource<T>.isLoading(): Boolean = this is Resource.Loading

/**
 * Extension function to check if Resource is success
 */
fun <T> Resource<T>.isSuccess(): Boolean = this is Resource.Success

/**
 * Extension function to check if Resource is error
 */
fun <T> Resource<T>.isError(): Boolean = this is Resource.Error
