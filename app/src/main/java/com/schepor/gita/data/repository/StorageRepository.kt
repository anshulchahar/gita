package com.schepor.gita.data.repository

import android.net.Uri
import com.google.firebase.storage.FirebaseStorage
import com.google.firebase.storage.StorageReference
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

/**
 * Repository for Firebase Storage operations
 * Handles file uploads, downloads, and deletions
 */
@Singleton
class StorageRepository @Inject constructor(
    private val storage: FirebaseStorage
) {
    
    private val storageRef: StorageReference = storage.reference
    
    /**
     * Upload user profile picture
     * @param userId The user's ID
     * @param imageUri URI of the image to upload
     * @return Download URL of the uploaded image
     */
    suspend fun uploadProfilePicture(userId: String, imageUri: Uri): Result<String> {
        return try {
            val profileRef = storageRef.child("users/$userId/profile.jpg")
            
            // Upload the file
            profileRef.putFile(imageUri).await()
            
            // Get download URL
            val downloadUrl = profileRef.downloadUrl.await()
            
            Result.success(downloadUrl.toString())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Download profile picture URL
     * @param userId The user's ID
     * @return Download URL of the profile picture
     */
    suspend fun getProfilePictureUrl(userId: String): Result<String> {
        return try {
            val profileRef = storageRef.child("users/$userId/profile.jpg")
            val downloadUrl = profileRef.downloadUrl.await()
            
            Result.success(downloadUrl.toString())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Delete user profile picture
     * @param userId The user's ID
     */
    suspend fun deleteProfilePicture(userId: String): Result<Unit> {
        return try {
            val profileRef = storageRef.child("users/$userId/profile.jpg")
            profileRef.delete().await()
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Get chapter banner image URL
     * @param chapterId The chapter ID
     * @return Download URL of the chapter banner
     */
    suspend fun getChapterBannerUrl(chapterId: String): Result<String> {
        return try {
            val bannerRef = storageRef.child("chapters/$chapterId/banner.jpg")
            val downloadUrl = bannerRef.downloadUrl.await()
            
            Result.success(downloadUrl.toString())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Get lesson image URL
     * @param lessonId The lesson ID
     * @param imageName Name of the image file
     * @return Download URL of the lesson image
     */
    suspend fun getLessonImageUrl(lessonId: String, imageName: String): Result<String> {
        return try {
            val imageRef = storageRef.child("lessons/$lessonId/$imageName")
            val downloadUrl = imageRef.downloadUrl.await()
            
            Result.success(downloadUrl.toString())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Get achievement badge URL
     * @param userId The user's ID
     * @param badgeId The badge ID
     * @return Download URL of the badge
     */
    suspend fun getBadgeUrl(userId: String, badgeId: String): Result<String> {
        return try {
            val badgeRef = storageRef.child("badges/$userId/$badgeId.png")
            val downloadUrl = badgeRef.downloadUrl.await()
            
            Result.success(downloadUrl.toString())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Upload user content (notes, bookmarks, etc.)
     * @param userId The user's ID
     * @param contentId ID of the content
     * @param fileUri URI of the file to upload
     * @return Download URL of the uploaded content
     */
    suspend fun uploadUserContent(
        userId: String, 
        contentId: String, 
        fileUri: Uri
    ): Result<String> {
        return try {
            val contentRef = storageRef.child("user-content/$userId/$contentId")
            
            // Upload the file
            contentRef.putFile(fileUri).await()
            
            // Get download URL
            val downloadUrl = contentRef.downloadUrl.await()
            
            Result.success(downloadUrl.toString())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Delete user content
     * @param userId The user's ID
     * @param contentId ID of the content to delete
     */
    suspend fun deleteUserContent(userId: String, contentId: String): Result<Unit> {
        return try {
            val contentRef = storageRef.child("user-content/$userId/$contentId")
            contentRef.delete().await()
            
            Result.success(Unit)
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
    
    /**
     * Get app asset URL (icons, backgrounds, etc.)
     * @param assetPath Path to the asset
     * @return Download URL of the asset
     */
    suspend fun getAssetUrl(assetPath: String): Result<String> {
        return try {
            val assetRef = storageRef.child("assets/$assetPath")
            val downloadUrl = assetRef.downloadUrl.await()
            
            Result.success(downloadUrl.toString())
        } catch (e: Exception) {
            Result.failure(e)
        }
    }
}
