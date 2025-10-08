package com.schepor.gita.data.repository

import com.google.firebase.firestore.FirebaseFirestore
import com.schepor.gita.domain.model.User
import com.schepor.gita.util.Resource
import kotlinx.coroutines.channels.awaitClose
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.callbackFlow
import kotlinx.coroutines.tasks.await
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class UserRepository @Inject constructor(
    private val firestore: FirebaseFirestore
) {
    private val usersCollection = firestore.collection("users")

    /**
     * Create or update user in Firestore
     */
    suspend fun createUser(user: User): Resource<User> {
        return try {
            usersCollection.document(user.userId).set(user).await()
            Resource.Success(user)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to create user")
        }
    }

    /**
     * Get user by ID
     */
    suspend fun getUser(userId: String): Resource<User> {
        return try {
            val snapshot = usersCollection.document(userId).get().await()
            val user = snapshot.toObject(User::class.java)
            if (user != null) {
                Resource.Success(user)
            } else {
                Resource.Error("User not found")
            }
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to get user")
        }
    }

    /**
     * Get user as Flow (real-time updates)
     */
    fun getUserFlow(userId: String): Flow<Resource<User>> = callbackFlow {
        val listenerRegistration = usersCollection.document(userId)
            .addSnapshotListener { snapshot, error ->
                if (error != null) {
                    trySend(Resource.Error(error.message ?: "Failed to listen to user"))
                    return@addSnapshotListener
                }

                val user = snapshot?.toObject(User::class.java)
                if (user != null) {
                    trySend(Resource.Success(user))
                } else {
                    trySend(Resource.Error("User not found"))
                }
            }

        awaitClose { listenerRegistration.remove() }
    }

    /**
     * Update user profile
     */
    suspend fun updateUser(userId: String, updates: Map<String, Any>): Resource<Unit> {
        return try {
            usersCollection.document(userId).update(updates).await()
            Resource.Success(Unit)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to update user")
        }
    }

    /**
     * Update user progress
     */
    suspend fun updateProgress(
        userId: String,
        chapterId: String,
        lessonId: String,
        score: Int
    ): Resource<Unit> {
        return try {
            val progressUpdate = mapOf(
                "progress.$chapterId.$lessonId.completed" to true,
                "progress.$chapterId.$lessonId.score" to score,
                "progress.$chapterId.$lessonId.completedAt" to System.currentTimeMillis(),
                "totalLessonsCompleted" to com.google.firebase.firestore.FieldValue.increment(1),
                "wisdomPoints" to com.google.firebase.firestore.FieldValue.increment(score.toLong())
            )
            usersCollection.document(userId).update(progressUpdate).await()
            Resource.Success(Unit)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to update progress")
        }
    }

    /**
     * Update daily streak
     */
    suspend fun updateStreak(userId: String): Resource<Unit> {
        return try {
            val userDoc = usersCollection.document(userId).get().await()
            val user = userDoc.toObject(User::class.java)
            
            if (user != null) {
                val now = System.currentTimeMillis()
                val lastActive = user.lastActiveAt.toDate().time
                val oneDayMillis = 24 * 60 * 60 * 1000
                
                val updates = mutableMapOf<String, Any>(
                    "lastActiveAt" to com.google.firebase.Timestamp(now / 1000, 0)
                )
                
                // Check if streak should continue or reset
                if (now - lastActive < oneDayMillis * 2) {
                    // Continue streak
                    val newStreak = user.gamification.currentStreak + 1
                    updates["gamification.currentStreak"] = newStreak
                    updates["gamification.longestStreak"] = maxOf(user.gamification.longestStreak, newStreak)
                } else if (now - lastActive >= oneDayMillis * 2) {
                    // Reset streak
                    updates["gamification.currentStreak"] = 1
                }
                
                usersCollection.document(userId).update(updates).await()
            }
            
            Resource.Success(Unit)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to update streak")
        }
    }

    /**
     * Save lesson completion with full progress tracking
     */
    suspend fun saveLessonCompletion(
        userId: String,
        chapterId: String,
        lessonId: String,
        score: Int,
        totalQuestions: Int,
        xpReward: Int
    ): Resource<Unit> {
        return try {
            val userDoc = usersCollection.document(userId).get().await()
            val user = userDoc.toObject(User::class.java)
            
            if (user == null) {
                return Resource.Error("User not found")
            }
            
            val now = com.google.firebase.Timestamp.now()
            val scorePercentage = if (totalQuestions > 0) (score * 100) / totalQuestions else 0
            
            // Calculate XP based on score percentage
            val xpEarned = (xpReward * scorePercentage) / 100
            
            // Calculate streak
            val lastActiveMillis = user.lastActiveAt.toDate().time
            val nowMillis = now.toDate().time
            val oneDayMillis = 24 * 60 * 60 * 1000
            val daysSinceLastActive = (nowMillis - lastActiveMillis) / oneDayMillis
            
            val newStreak = when {
                daysSinceLastActive < 1 -> user.gamification.currentStreak // Same day
                daysSinceLastActive < 2 -> user.gamification.currentStreak + 1 // Next day
                else -> 1 // Streak broken, reset to 1
            }
            
            val longestStreak = maxOf(user.gamification.longestStreak, newStreak)
            
            // Check if perfect score
            val isPerfectScore = score == totalQuestions
            val perfectScores = if (isPerfectScore) {
                user.gamification.perfectScores + 1
            } else {
                user.gamification.perfectScores
            }
            
            // Get existing progress for this lesson (if any)
            val existingProgress = user.progress["${chapterId}_$lessonId"]
            val attempts = (existingProgress?.attempts ?: 0) + 1
            
            // Build update map
            val updates = mapOf(
                "progress.${chapterId}_$lessonId.completedAt" to now,
                "progress.${chapterId}_$lessonId.score" to scorePercentage,
                "progress.${chapterId}_$lessonId.attempts" to attempts,
                "progress.${chapterId}_$lessonId.timeSpent" to 0, // TODO: Track actual time
                "gamification.wisdomPoints" to user.gamification.wisdomPoints + xpEarned,
                "gamification.currentStreak" to newStreak,
                "gamification.longestStreak" to longestStreak,
                "gamification.totalLessonsCompleted" to user.gamification.totalLessonsCompleted + 1,
                "gamification.perfectScores" to perfectScores,
                "gamification.lastCompletedDate" to now.toDate().toString(),
                "lastActiveAt" to now
            )
            
            usersCollection.document(userId).update(updates).await()
            Resource.Success(Unit)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to save lesson completion")
        }
    }

    /**
     * Delete user
     */
    suspend fun deleteUser(userId: String): Resource<Unit> {
        return try {
            usersCollection.document(userId).delete().await()
            Resource.Success(Unit)
        } catch (e: Exception) {
            Resource.Error(e.message ?: "Failed to delete user")
        }
    }
}
